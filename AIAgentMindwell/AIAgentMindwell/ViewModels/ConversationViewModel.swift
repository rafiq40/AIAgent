//
//  ConversationViewModel.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class ConversationViewModel: ObservableObject {
    @Published var currentSession: ConversationSession?
    @Published var isTyping = false
    @Published var showMoodSlider = false
    @Published var currentMoodRating: Double = 5.0
    @Published var isProcessingResponse = false
    @Published var conversationEnded = false
    
    private let mindWellBridge = MindWellBridge.shared
    private let conversationLearner = ConversationLearner()
    var viewContext: NSManagedObjectContext?
    
    // Conversation flow state
    private var followUpCount = 0
    private let maxFollowUps = 20 // NEW - Allow much longer conversations
    
    // Enhanced conversation components
    private let conversationMemory = ConversationMemory()
    @Published private var lastResponseTime = Date()
    private var previousEmotions: [String: Double] = [:]
    
    init(viewContext: NSManagedObjectContext? = nil) {
        self.viewContext = viewContext
    }
    
    // MARK: - Conversation Management
    
    func startConversation(with prompt: ConversationPrompt) {
        currentSession = ConversationSession(initialPrompt: prompt)
        followUpCount = 0
        conversationEnded = false
        
        // Add a brief delay to simulate agent "thinking"
        Task {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            // The initial message is already added in ConversationSession init
        }
    }
    
    func sendUserMessage(_ content: String) {
        guard var session = currentSession, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isProcessingResponse = true
        
        // Add user message
        let userMessage = ConversationMessage.userMessage(content, mood: showMoodSlider ? Int(currentMoodRating) : nil)
        session.addMessage(userMessage)
        currentSession = session
        
        // Process the response
        Task {
            await processUserResponse(content, mood: showMoodSlider ? Int(currentMoodRating) : nil)
        }
    }
    
    func submitMoodRating() {
        guard var session = currentSession else { return }
        
        let moodMessage = ConversationMessage.userMessage("My mood is \(Int(currentMoodRating))/10", mood: Int(currentMoodRating))
        session.addMessage(moodMessage)
        session.userMoodRating = Int(currentMoodRating)
        currentSession = session
        
        showMoodSlider = false
        
        Task {
            await processUserResponse("Mood rating: \(Int(currentMoodRating))", mood: Int(currentMoodRating))
        }
    }
    
    private func processUserResponse(_ content: String, mood: Int?) async {
        guard let session = currentSession,
              let initialPrompt = session.initialPrompt else {
            isProcessingResponse = false
            return
        }
        
        // Calculate response time based on user behavior
        let responseTime = Date().timeIntervalSince(lastResponseTime)
        
        // Enhanced emotion detection using EmotionalIntelligence
        let richEmotions = EmotionalIntelligence.extractRichEmotions(from: content)
        let emotionalState = EmotionalIntelligence.analyzeEmotionalState(from: richEmotions)
        let crisisLevel = EmotionalIntelligence.detectCrisisIndicators(from: content, mood: mood ?? 5)
        
        // Check for crisis situation
        if crisisLevel.requiresIntervention {
            await handleCrisisResponse(content: content, mood: mood ?? 5, crisisLevel: crisisLevel)
            isProcessingResponse = false
            return
        }
        
        // Calculate dynamic response delay based on emotional content
        let responseDelay = calculateResponseDelay(content: content, emotions: richEmotions, mood: mood ?? 5)
        try? await Task.sleep(nanoseconds: responseDelay)
        
        // Generate proper dayId
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        let dayId = dayFormatter.string(from: Date())
        
        // Convert rich emotions to simple array for UserResponse compatibility
        let keyEmotions = Array(richEmotions.keys)
        
        // Create UserResponse for learning
        let userResponse = UserResponse(
            promptId: initialPrompt.id,
            response: content,
            mood: mood ?? 5,
            timestamp: Date(),
            dayId: dayId,
            conversationLength: session.messages.count,
            engagementLevel: determineEngagementLevel(from: content),
            keyEmotions: keyEmotions,
            responseTime: responseTime
        )
        
        // Record in conversation memory
        conversationMemory.recordExchange(
            userMessage: content,
            agentResponse: "", // Will be filled when we generate response
            emotions: richEmotions,
            mood: mood ?? 5
        )
        
        // Learn from the response
        conversationLearner.analyzeResponse(userResponse)
        
        // Save to Core Data if available
        saveUserResponse(userResponse)
        
        // Store current emotions for trend analysis
        previousEmotions = richEmotions
        
        // Generate follow-up or end conversation
        await generateNextStep(for: userResponse, prompt: initialPrompt)
        
        isProcessingResponse = false
    }
    
    private func generateNextStep(for response: UserResponse, prompt: ConversationPrompt) async {
        guard var session = currentSession else { return }
        
        // Show typing indicator
        isTyping = true
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        isTyping = false
        
        // Check if we should ask for mood rating
        if session.userMoodRating == nil && !showMoodSlider {
            let moodMessage = ConversationMessage.moodRequest()
            session.addMessage(moodMessage)
            currentSession = session
            showMoodSlider = true
            return
        }
        
        // Try to generate a follow-up question
        if followUpCount < maxFollowUps {
            // Check if this is actually a good follow-up based on trigger words
            let triggerFound = prompt.followUpTriggers.contains { trigger in
                response.response.lowercased().contains(trigger.lowercased())
            }
            
            if triggerFound && !prompt.followUps.isEmpty {
                let followUpQuestion = prompt.followUps.randomElement() ?? "Tell me more about that."
                let followUpMessage = ConversationMessage.agentMessage(followUpQuestion, type: .followUp)
                session.addMessage(followUpMessage)
                currentSession = session
                followUpCount += 1
                return
            }
            
            // Generate contextual follow-up based on response content
            if let contextualFollowUp = generateContextualFollowUp(for: response, prompt: prompt) {
                let followUpMessage = ConversationMessage.agentMessage(contextualFollowUp, type: .followUp)
                session.addMessage(followUpMessage)
                currentSession = session
                followUpCount += 1
                return
            }
        }
        
        // End the conversation
        await endConversationInternal()
    }
    
    private func generateContextualFollowUp(for response: UserResponse, prompt: ConversationPrompt) -> String? {
        // Use enhanced emotion detection
        let richEmotions = EmotionalIntelligence.extractRichEmotions(from: response.response)
        let emotionalState = EmotionalIntelligence.analyzeEmotionalState(from: richEmotions)
        let emotionalTrend = EmotionalIntelligence.getEmotionalTrend(currentEmotions: richEmotions, previousEmotions: previousEmotions)
        
        // Check conversation memory for context
        let emotionalPattern = conversationMemory.getEmotionalPattern()
        let hasDiscussedSimilarTopic = conversationMemory.hasDiscussed(topic: response.response)
        
        // Generate contextual prompt from memory first
        if let memoryPrompt = conversationMemory.generateContextualPrompt() {
            conversationMemory.recordQuestion(memoryPrompt)
            return memoryPrompt
        }
        
        // Use EmotionalIntelligence for empathetic responses
        if let empatheticResponse = EmotionalIntelligence.generateEmpatheticResponse(for: richEmotions, mood: response.mood) {
            conversationMemory.recordQuestion(empatheticResponse)
            return empatheticResponse
        }
        
        // Enhanced contextual follow-ups based on emotional trends
        switch emotionalTrend {
        case .improving:
            let improvingFollowUps = [
                "I can sense something shifting positively for you. What's creating that change?",
                "There's a lightness emerging in your words. What's helping you feel better?",
                "I notice your energy lifting. What's been supporting this positive shift?"
            ]
            let followUp = improvingFollowUps.randomElement()!
            conversationMemory.recordQuestion(followUp)
            return followUp
            
        case .declining:
            let decliningFollowUps = [
                "I notice this feels heavier than when we started. What's weighing on you most?",
                "Something seems to be pulling you down. What's behind that shift?",
                "I can feel the weight increasing for you. What's making things feel harder?"
            ]
            let followUp = decliningFollowUps.randomElement()!
            conversationMemory.recordQuestion(followUp)
            return followUp
            
        case .stable:
            break // Continue to other logic
        }
        
        // Enhanced emotional state responses
        switch emotionalState {
        case .highlyNegative:
            let highNegativeFollowUps = [
                "I can feel the intensity of what you're going through. What's the hardest part right now?",
                "This sounds overwhelming. What would help you feel even a little bit safer?",
                "I'm here with you in this difficult moment. What does your heart need most?"
            ]
            let followUp = highNegativeFollowUps.randomElement()!
            conversationMemory.recordQuestion(followUp)
            return followUp
            
        case .highlyPositive:
            let highPositiveFollowUps = [
                "Your joy is absolutely radiant! What's creating this beautiful energy?",
                "I can feel your happiness through your words! What's making your heart so full?",
                "This level of positivity is wonderful to witness! What's been the source of this joy?"
            ]
            let followUp = highPositiveFollowUps.randomElement()!
            conversationMemory.recordQuestion(followUp)
            return followUp
            
        case .mixed:
            let mixedFollowUps = [
                "You're experiencing a lot of different emotions. What's behind all these feelings?",
                "I can sense the complexity of what you're feeling. What's the strongest emotion right now?",
                "There's so much happening emotionally for you. What feels most important to explore?"
            ]
            let followUp = mixedFollowUps.randomElement()!
            conversationMemory.recordQuestion(followUp)
            return followUp
            
        default:
            break // Continue to fallback logic
        }
        
        // Fallback to original logic with memory tracking
        let content = response.response.lowercased()
        let mood = response.mood
        
        // Avoid repetitive questions using memory
        let potentialFollowUps = generatePotentialFollowUps(content: content, mood: mood, response: response)
        
        for followUp in potentialFollowUps {
            if !conversationMemory.hasAskedSimilarQuestion(followUp) {
                conversationMemory.recordQuestion(followUp)
                return followUp
            }
        }
        
        // If all potential follow-ups have been used, generate a fresh perspective
        let freshPerspectiveFollowUps = [
            "What else is alive in your heart right now?",
            "If you could tell me one more thing, what would it be?",
            "What haven't we touched on that feels important?",
            "What's your intuition telling you about all of this?",
            "What would feel most helpful to explore together?"
        ]
        
        let followUp = freshPerspectiveFollowUps.randomElement()!
        conversationMemory.recordQuestion(followUp)
        return followUp
    }
    
    private func generatePotentialFollowUps(content: String, mood: Int, response: UserResponse) -> [String] {
        var followUps: [String] = []
        
        // Stress and overwhelm - more empathetic responses
        if content.contains("stressed") || content.contains("overwhelmed") {
            followUps.append(contentsOf: [
                "I can hear that you're carrying a lot right now. What's weighing on you most?",
                "That sounds really challenging. What's one thing that might help lighten that load?",
                "I'm here with you in this. What's behind that feeling of overwhelm?",
                "What's been the most stressful part of your day?",
                "How long have you been feeling this overwhelmed?"
            ])
        }
        
        // Anxiety and worry - gentle, supportive approach
        if content.contains("anxious") || content.contains("worried") || content.contains("nervous") {
            followUps.append(contentsOf: [
                "I hear that anxiety in your words. What thoughts are swirling around in your mind?",
                "Anxiety can feel so consuming. What's your heart most worried about right now?",
                "That nervous energy makes sense. What would help you feel more grounded?",
                "What's your anxiety trying to protect you from?",
                "When did you first notice this anxious feeling today?"
            ])
        }
        
        // Sadness and low mood - compassionate responses
        if content.contains("sad") || content.contains("down") || content.contains("depressed") || mood <= 3 {
            followUps.append(contentsOf: [
                "I'm sorry you're feeling this way. What's sitting heavy on your heart?",
                "That sounds really difficult. What does that sadness want you to know?",
                "I'm here with you in this low moment. What would feel most supportive right now?",
                "What's been the hardest part of feeling this way?",
                "Is there anything that brings you even a small moment of comfort?"
            ])
        }
        
        // Happiness and positive emotions - celebrating with them
        if content.contains("happy") || content.contains("good") || content.contains("great") || content.contains("excited") || mood >= 7 {
            followUps.append(contentsOf: [
                "I love hearing that joy in your words! What's bringing that lightness today?",
                "That's wonderful to hear! What made today feel so good?",
                "Your happiness is contagious! What's been the best part of your day?",
                "What's been fueling this positive energy?",
                "How does this happiness feel in your body?"
            ])
        }
        
        // Work-related stress - specific support
        if content.contains("work") || content.contains("job") || content.contains("boss") || content.contains("meeting") {
            followUps.append(contentsOf: [
                "Work can be such a source of stress. What's the most challenging part right now?",
                "I hear you. What would help you feel more supported at work?",
                "That work situation sounds tough. How are you taking care of yourself through it?",
                "What's been the most frustrating aspect of your work lately?",
                "How is this work stress affecting other areas of your life?"
            ])
        }
        
        // Longer, thoughtful responses - acknowledging their openness
        if response.response.count > 100 {
            followUps.append(contentsOf: [
                "Thank you for sharing so openly with me. What feels most important in all of that?",
                "I can feel the depth in what you're sharing. What stands out most to you?",
                "There's so much wisdom in your reflection. What are you learning about yourself?",
                "What part of what you shared resonates most deeply with you?",
                "In all of that, what feels like the core truth for you?"
            ])
        }
        
        // Medium responses - gentle curiosity
        if response.response.count > 30 {
            followUps.append(contentsOf: [
                "I'm curious to know more. What else is on your mind?",
                "That resonates. How does that feel in your body right now?",
                "Tell me more about that. What's beneath the surface?",
                "What would you like to explore more deeply?",
                "What's your heart telling you about this?"
            ])
        }
        
        return followUps
    }
    
    private func endConversationInternal() async {
        guard var session = currentSession else { return }
        
        // Generate personalized closing message based on conversation content
        let closingMessage = generatePersonalizedClosing(for: session)
        
        session.addMessage(closingMessage)
        session.endSession(summary: generateSessionSummary(session))
        currentSession = session
        conversationEnded = true
    }
    
    private func generatePersonalizedClosing(for session: ConversationSession) -> ConversationMessage {
        let userMessages = session.userMessages
        let mood = session.userMoodRating ?? 5
        let totalWords = userMessages.reduce(0) { $0 + $1.content.split(separator: " ").count }
        
        // Analyze the conversation to create a personalized closing
        let allContent = userMessages.map { $0.content.lowercased() }.joined(separator: " ")
        
        var closingMessage: String
        
        // Personalized closings based on conversation content and mood
        if mood <= 3 {
            // Low mood - extra compassionate with data saving notification
            let lowMoodClosings = [
                "Thank you for trusting me with your feelings today. I'm now saving your emotions and mood to better understand and support you. You don't have to carry this alone. I wish you a gentle rest of your day. 💙",
                "I'm grateful you shared what's in your heart. I'm storing today's insights to help me be more supportive next time. Please be extra gentle with yourself today. 🤗",
                "Your courage in opening up, even when things feel heavy, is remarkable. I'm saving your feelings to learn how to better care for you. Take care of yourself. 💜",
                "Thank you for letting me sit with you in this difficult moment. I'm now recording your emotions to understand you better. You matter, and your feelings are valid. 🌟"
            ]
            closingMessage = lowMoodClosings.randomElement() ?? lowMoodClosings[0]
        }
        else if mood >= 7 {
            // High mood - celebrating with data saving notification
            let highMoodClosings = [
                "I love the joy I heard in our conversation today! I'm saving your happiness and mood to remember what brings you lightness. Keep nurturing that beautiful energy. ✨",
                "Your happiness is contagious! I'm storing today's positive emotions to better understand what makes you thrive. Thank you for sharing that lightness with me. 🌟",
                "It's wonderful to connect with you when you're feeling so good. I'm recording your joy to help me support your wellbeing. Enjoy this beautiful moment! 😊",
                "The positivity in your words brightened my day too. I'm saving your mood and feelings to learn more about you. Keep shining! 🌞"
            ]
            closingMessage = highMoodClosings.randomElement() ?? highMoodClosings[0]
        }
        else if allContent.contains("work") || allContent.contains("job") || allContent.contains("stress") {
            // Work-related conversations with data saving
            let workClosings = [
                "Work can be so demanding. I'm saving your thoughts about work stress to better support you through these challenges. Remember to take care of yourself. You're doing great. 💪",
                "Thank you for sharing about your work challenges. I'm storing these insights to help me understand your work-life balance better. Don't forget to give yourself credit for all you handle. 🌟",
                "I hear how much you're juggling. I'm recording your feelings about work to learn how to better support you. Remember, your worth isn't defined by your productivity. Take care. 💙"
            ]
            closingMessage = workClosings.randomElement() ?? workClosings[0]
        }
        else if allContent.contains("anxious") || allContent.contains("worried") || allContent.contains("nervous") {
            // Anxiety-focused conversations with data saving
            let anxietyClosings = [
                "Thank you for sharing your worries with me. I'm saving your feelings about anxiety to better understand and support you. Remember, you've handled difficult things before. 🤗",
                "I hear that anxiety, and I want you to know it's okay to feel uncertain sometimes. I'm storing your emotions to learn how to help you feel more grounded. You're not alone. 💙",
                "Your awareness of your anxiety is actually a strength. I'm recording these insights to better support your emotional wellbeing. Be patient with yourself as you navigate this. 🌟"
            ]
            closingMessage = anxietyClosings.randomElement() ?? anxietyClosings[0]
        }
        else if totalWords > 100 {
            // Deep, thoughtful conversations with data saving
            let deepClosings = [
                "Thank you for sharing so thoughtfully with me today. I'm saving your reflections to better understand your emotional journey. Your self-awareness is truly beautiful. 🌟",
                "I'm moved by the depth of what you shared. I'm storing these insights about your feelings and mood to support you better. Your emotional awareness is a real gift. 💜",
                "The wisdom in your words today was profound. I'm recording your thoughts and emotions to learn more about who you are. Thank you for letting me witness your growth. ✨"
            ]
            closingMessage = deepClosings.randomElement() ?? deepClosings[0]
        }
        else {
            // General caring closings with data saving
            let generalClosings = [
                "Thank you for taking time to check in with yourself today. I'm now saving your feelings and mood to better understand and support you. That's an act of self-care. I wish you a wonderful day! 💙",
                "I appreciate you sharing with me. I'm storing today's emotions to learn how to be more helpful next time. Remember, I'm here whenever you need to talk. 🤗",
                "It's been meaningful to connect with you today. I'm saving your mood and feelings to better care for that beautiful heart of yours. Take care! 🌟",
                "Thank you for being open with me. I'm recording your emotional honesty to understand you better. Your feelings matter. Have a great rest of your day! 💜"
            ]
            closingMessage = generalClosings.randomElement() ?? generalClosings[0]
        }
        
        return ConversationMessage.agentMessage(closingMessage, type: .closing)
    }
    
    private func generateSessionSummary(_ session: ConversationSession) -> String {
        let userMessages = session.userMessages
        let totalWords = userMessages.reduce(0) { $0 + $1.content.split(separator: " ").count }
        let avgMood = session.userMoodRating ?? 5
        
        return "Session completed with \(userMessages.count) responses, \(totalWords) words shared, average mood: \(avgMood)/10"
    }
    
    // MARK: - Data Persistence
    
    private func saveUserResponse(_ response: UserResponse) {
        guard let context = viewContext else { return }
        
        let entity = UserResponseEntity(context: context)
        entity.response = response.response
        entity.mood = Int16(response.mood)
        entity.promptId = response.promptId
        entity.timestamp = response.timestamp
        entity.engagementLevel = response.engagementLevel.rawValue
        
        // Populate the missing required fields
        entity.dayId = response.dayId
        entity.conversationLength = Int16(response.conversationLength)
        entity.responseTime = response.responseTime
        entity.keyEmotions = response.keyEmotions as NSObject
        
        do {
            try context.save()
        } catch {
            print("Error saving user response: \(error)")
        }
    }
    
    // MARK: - Analysis Helper Methods
    
    private func extractKeyEmotions(from content: String) -> [String] {
        let emotionKeywords = [
            "happy", "joy", "excited", "cheerful", "content", "pleased", "delighted",
            "sad", "depressed", "down", "blue", "melancholy", "grief", "sorrow",
            "angry", "mad", "furious", "irritated", "annoyed", "frustrated", "rage",
            "anxious", "worried", "nervous", "stressed", "overwhelmed", "panic", "fear",
            "tired", "exhausted", "drained", "weary", "fatigued", "worn out",
            "calm", "peaceful", "relaxed", "serene", "tranquil", "centered",
            "confused", "lost", "uncertain", "unclear", "mixed up", "puzzled",
            "grateful", "thankful", "appreciative", "blessed", "fortunate",
            "lonely", "isolated", "alone", "disconnected", "abandoned",
            "hopeful", "optimistic", "positive", "encouraged", "inspired"
        ]
        
        let lowercaseContent = content.lowercased()
        let foundEmotions = emotionKeywords.filter { keyword in
            lowercaseContent.contains(keyword)
        }
        
        return Array(Set(foundEmotions)) // Remove duplicates
    }
    
    private func determineEngagementLevel(from content: String) -> UserResponse.EngagementLevel {
        let wordCount = content.split(separator: " ").count
        let hasEmotionalWords = !extractKeyEmotions(from: content).isEmpty
        
        if wordCount >= 20 || hasEmotionalWords {
            return .deep
        } else if wordCount >= 5 {
            return .engaged
        } else {
            return .minimal
        }
    }
    
    // MARK: - Enhanced Helper Methods
    
    // Track when user starts typing
    func userStartedTyping() {
        lastResponseTime = Date()
    }
    
    // Calculate dynamic response delay based on emotional content
    private func calculateResponseDelay(content: String, emotions: [String: Double], mood: Int) -> UInt64 {
        let baseDelay: UInt64 = 800_000_000 // 0.8 seconds
        var delay = baseDelay
        
        // Longer delay for emotional content
        if mood <= 3 {
            delay += 1_200_000_000 // Extra 1.2 seconds for sad responses
        }
        
        let wordCount = content.components(separatedBy: .whitespacesAndNewlines).count
        if wordCount > 100 {
            delay += 800_000_000 // Extra time for long responses
        }
        
        if emotions.count > 2 {
            delay += 600_000_000 // Extra time for emotional complexity
        }
        
        // Check for high-intensity emotions
        let hasHighIntensityEmotions = emotions.values.contains { $0 >= 0.8 }
        if hasHighIntensityEmotions {
            delay += 1_000_000_000 // Extra second for intense emotions
        }
        
        return delay
    }
    
    // Handle crisis situations with immediate support
    private func handleCrisisResponse(content: String, mood: Int, crisisLevel: CrisisLevel) async {
        guard var session = currentSession else { return }
        
        let crisisMessage = provideCrisisSupport(level: crisisLevel)
        let supportMessage = ConversationMessage.agentMessage(crisisMessage, type: .followUp)
        
        session.addMessage(supportMessage)
        currentSession = session
        
        // Record crisis intervention in memory
        conversationMemory.remember(key: "crisis_intervention", value: Date())
        conversationMemory.remember(key: "crisis_level", value: crisisLevel.rawValue)
        
        // Don't end conversation immediately - offer continued support
        followUpCount += 1
    }
    
    private func provideCrisisSupport(level: CrisisLevel) -> String {
        switch level {
        case .high:
            return """
            I'm really concerned about you and I'm so glad you trusted me with these feelings. 
            You matter tremendously, and there are people who want to help. 
            
            Please reach out to:
            • Crisis Text Line: Text HOME to 741741
            • National Suicide Prevention Lifeline: 988
            • Or your local emergency services: 911
            
            Would you like to talk about what's making things feel so difficult?
            """
        case .moderate:
            return """
            I hear how much pain you're in right now, and I want you to know that you're not alone. 
            These feelings are temporary, even when they don't feel that way.
            
            If you need immediate support:
            • Crisis Text Line: Text HOME to 741741
            • National Suicide Prevention Lifeline: 988
            
            What's one small thing that might help you feel a little safer right now?
            """
        case .low:
            return """
            I can sense you're going through a really tough time. Your feelings are valid, 
            and it's okay to not be okay sometimes.
            
            Remember that support is available if you need it:
            • Crisis Text Line: Text HOME to 741741
            
            What's been the hardest part of today for you?
            """
        case .none:
            return "I'm here to support you. What would be most helpful right now?"
        }
    }
    
    func endConversation() async {
        await endConversationInternal()
    }
    
    func resetConversation() {
        currentSession = nil
        isTyping = false
        showMoodSlider = false
        currentMoodRating = 5.0
        isProcessingResponse = false
        conversationEnded = false
        followUpCount = 0
        conversationMemory.clearSessionMemory()
        previousEmotions.removeAll()
    }
    
    var canSendMessage: Bool {
        !isProcessingResponse && !showMoodSlider && !conversationEnded
    }
    
    var messages: [ConversationMessage] {
        currentSession?.messages ?? []
    }
    
    var hasActiveConversation: Bool {
        currentSession?.isActive ?? false
    }
}
