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
    private let maxFollowUps = 6 // Increased for longer conversations
    
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
        
        // Calculate response time (simulate realistic timing)
        let responseTime = Double.random(in: 2.0...15.0) // 2-15 seconds
        
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Generate proper dayId
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        let dayId = dayFormatter.string(from: Date())
        
        // Extract key emotions from response
        let keyEmotions = extractKeyEmotions(from: content)
        
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
        
        // Learn from the response
        conversationLearner.analyzeResponse(userResponse)
        
        // Save to Core Data if available
        saveUserResponse(userResponse)
        
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
        let content = response.response.lowercased()
        let mood = response.mood
        
        // Enhanced contextual follow-ups that feel more caring and personalized
        
        // Stress and overwhelm - more empathetic responses
        if content.contains("stressed") || content.contains("overwhelmed") {
            let stressFollowUps = [
                "I can hear that you're carrying a lot right now. What's weighing on you most?",
                "That sounds really challenging. What's one thing that might help lighten that load?",
                "I'm here with you in this. What's behind that feeling of overwhelm?"
            ]
            return stressFollowUps.randomElement()
        }
        
        // Anxiety and worry - gentle, supportive approach
        else if content.contains("anxious") || content.contains("worried") || content.contains("nervous") {
            let anxietyFollowUps = [
                "I hear that anxiety in your words. What thoughts are swirling around in your mind?",
                "Anxiety can feel so consuming. What's your heart most worried about right now?",
                "That nervous energy makes sense. What would help you feel more grounded?"
            ]
            return anxietyFollowUps.randomElement()
        }
        
        // Sadness and low mood - compassionate responses
        else if content.contains("sad") || content.contains("down") || content.contains("depressed") || mood <= 3 {
            let sadnessFollowUps = [
                "I'm sorry you're feeling this way. What's sitting heavy on your heart?",
                "That sounds really difficult. What does that sadness want you to know?",
                "I'm here with you in this low moment. What would feel most supportive right now?"
            ]
            return sadnessFollowUps.randomElement()
        }
        
        // Happiness and positive emotions - celebrating with them
        else if content.contains("happy") || content.contains("good") || content.contains("great") || content.contains("excited") || mood >= 7 {
            let happyFollowUps = [
                "I love hearing that joy in your words! What's bringing that lightness today?",
                "That's wonderful to hear! What made today feel so good?",
                "Your happiness is contagious! What's been the best part of your day?"
            ]
            return happyFollowUps.randomElement()
        }
        
        // Tiredness and exhaustion - nurturing responses
        else if content.contains("tired") || content.contains("exhausted") || content.contains("drained") {
            let tiredFollowUps = [
                "It sounds like you've been giving so much of yourself. What's been draining your energy?",
                "That exhaustion is real. What would help restore you right now?",
                "I hear how tired you are. What does your body and heart need most?"
            ]
            return tiredFollowUps.randomElement()
        }
        
        // Work-related stress - specific support
        else if content.contains("work") || content.contains("job") || content.contains("boss") || content.contains("meeting") {
            let workFollowUps = [
                "Work can be such a source of stress. What's the most challenging part right now?",
                "I hear you. What would help you feel more supported at work?",
                "That work situation sounds tough. How are you taking care of yourself through it?"
            ]
            return workFollowUps.randomElement()
        }
        
        // Relationship mentions - caring inquiry
        else if content.contains("friend") || content.contains("family") || content.contains("partner") || content.contains("relationship") {
            let relationshipFollowUps = [
                "Relationships can bring such complex feelings. How are you navigating that?",
                "That sounds meaningful. What's that relationship teaching you about yourself?",
                "People matter so much. How is that connection affecting your heart?"
            ]
            return relationshipFollowUps.randomElement()
        }
        
        // Longer, thoughtful responses - acknowledging their openness
        else if response.response.count > 100 {
            let thoughtfulFollowUps = [
                "Thank you for sharing so openly with me. What feels most important in all of that?",
                "I can feel the depth in what you're sharing. What stands out most to you?",
                "There's so much wisdom in your reflection. What are you learning about yourself?"
            ]
            return thoughtfulFollowUps.randomElement()
        }
        
        // Medium responses - gentle curiosity
        else if response.response.count > 30 {
            let mediumFollowUps = [
                "I'm curious to know more. What else is on your mind?",
                "That resonates. How does that feel in your body right now?",
                "Tell me more about that. What's beneath the surface?"
            ]
            return mediumFollowUps.randomElement()
        }
        
        return nil
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
    
    // MARK: - Helper Methods
    
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
