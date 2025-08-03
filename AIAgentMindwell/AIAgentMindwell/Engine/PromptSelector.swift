//
//  PromptSelector.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation

class PromptSelector {
    private let userPattern: UserPattern
    // Using static methods from PromptDatabase
    
    // Selection parameters
    private let varietyWeight = 0.3
    private let personalityWeight = 0.4
    private let timeWeight = 0.2
    private let effectivenessWeight = 0.1
    
    init(userPattern: UserPattern) {
        self.userPattern = userPattern
    }
    
    // MARK: - Main Selection Methods
    
    func selectBestPrompt(for context: ConversationContext) -> ConversationPrompt? {
        let currentTime = TimeContext.current()
        let availablePrompts = PromptDatabase.getRandomPrompt(for: currentTime) != nil ? [PromptDatabase.getRandomPrompt(for: currentTime)!] : []
        
        guard !availablePrompts.isEmpty else { return nil }
        
        // Score all prompts
        let scoredPrompts = availablePrompts.map { prompt in
            (prompt: prompt, score: calculatePromptScore(prompt, for: context))
        }
        
        // Sort by score and add variety
        let sortedPrompts = scoredPrompts.sorted { $0.score > $1.score }
        
        // Apply variety filter to avoid repetition
        let filteredPrompts = applyVarietyFilter(sortedPrompts, context: context)
        
        return filteredPrompts.first?.prompt
    }
    
    func selectBestPrompts(for timeContext: TimeContext, count: Int = 3) -> [ConversationPrompt] {
        let availablePrompts = PromptDatabase.allPrompts.filter { $0.timeOfDay == timeContext }
        
        guard !availablePrompts.isEmpty else { return [] }
        
        // Create a mock context for scoring
        let mockContext = ConversationContext()
        
        // Score all prompts
        let scoredPrompts = availablePrompts.map { prompt in
            (prompt: prompt, score: calculatePromptScore(prompt, for: mockContext))
        }
        
        // Sort by score
        let sortedPrompts = scoredPrompts.sorted { $0.score > $1.score }
        
        // Apply variety and return top prompts
        let varietyFiltered = applyVarietyFilter(sortedPrompts, context: mockContext)
        
        return Array(varietyFiltered.prefix(count).map { $0.prompt })
    }
    
    // MARK: - Scoring Algorithm
    
    private func calculatePromptScore(_ prompt: ConversationPrompt, for context: ConversationContext) -> Double {
        var score = 1.0
        
        // 1. Personality compatibility score
        let personalityScore = calculatePersonalityScore(prompt)
        score += personalityScore * personalityWeight
        
        // 2. Time preference score
        let timeScore = calculateTimeScore(prompt)
        score += timeScore * timeWeight
        
        // 3. Effectiveness score (based on past performance)
        let effectivenessScore = prompt.effectivenessScore
        score += (effectivenessScore - 1.0) * effectivenessWeight
        
        // 4. Context relevance score
        let contextScore = calculateContextScore(prompt, for: context)
        score += contextScore * 0.2
        
        // 5. Mood appropriateness score
        let moodScore = calculateMoodScore(prompt, for: context)
        score += moodScore * 0.15
        
        return score
    }
    
    private func calculatePersonalityScore(_ prompt: ConversationPrompt) -> Double {
        var score = 0.0
        
        // Style compatibility
        if prompt.conversationStyle == userPattern.preferredStyle {
            score += 0.4
        } else {
            // Partial compatibility for related styles
            score += getStyleCompatibility(prompt.conversationStyle, userPattern.preferredStyle) * 0.2
        }
        
        // Tone compatibility
        if prompt.emotionalTone == userPattern.preferredTone {
            score += 0.3
        } else {
            score += getToneCompatibility(prompt.emotionalTone, userPattern.preferredTone) * 0.15
        }
        
        // Category preference
        if userPattern.preferredCategories.contains(prompt.category) {
            score += 0.3
        } else if userPattern.preferredCategories.isEmpty {
            // If no preferences learned yet, give neutral score
            score += 0.1
        }
        
        return score
    }
    
    private func calculateTimeScore(_ prompt: ConversationPrompt) -> Double {
        let timePreference = userPattern.timePreferences[prompt.timeOfDay] ?? 0.25
        return timePreference * 2.0 // Scale to 0-2 range
    }
    
    private func calculateContextScore(_ prompt: ConversationPrompt, for context: ConversationContext) -> Double {
        var score = 0.0
        
        // Conversation flow appropriateness
        switch context.conversationFlow {
        case .initial:
            // Prefer open-ended or gentle prompts for initial conversation
            if prompt.category == .openEnded || prompt.conversationStyle == .gentle {
                score += 0.3
            }
        case .followUp:
            // Prefer specific or curious prompts for follow-ups
            if prompt.category == .specific || prompt.conversationStyle == .curious {
                score += 0.3
            }
        case .deepDive:
            // Prefer reflective or supportive prompts for deep conversations
            if prompt.category == .reflective || prompt.conversationStyle == .supportive {
                score += 0.3
            }
        case .closing:
            // Prefer gratitude or gentle prompts for closing
            if prompt.category == .gratitude || prompt.conversationStyle == .gentle {
                score += 0.3
            }
        }
        
        // Emotional context matching
        if !context.detectedEmotions.isEmpty {
            let emotionalWords = Set(context.detectedEmotions)
            let promptTriggers = Set(prompt.followUpTriggers)
            
            // Check for emotional alignment
            if !emotionalWords.isDisjoint(with: promptTriggers) {
                score += 0.2
            }
        }
        
        return score
    }
    
    private func calculateMoodScore(_ prompt: ConversationPrompt, for context: ConversationContext) -> Double {
        let currentMood = context.userMood
        
        // Adjust prompt selection based on mood
        switch currentMood {
        case 1...3: // Low mood
            if prompt.category == .coping || prompt.emotionalTone == .empathetic {
                return 0.3
            } else if prompt.category == .gratitude && prompt.emotionalTone == .warm {
                return 0.2
            }
        case 4...6: // Neutral mood
            if prompt.category == .openEnded || prompt.category == .reflective {
                return 0.2
            }
        case 7...10: // High mood
            if prompt.category == .gratitude || prompt.emotionalTone == .energetic {
                return 0.3
            } else if prompt.category == .future {
                return 0.2
            }
        default:
            break
        }
        
        return 0.1 // Default neutral score
    }
    
    // MARK: - Compatibility Helpers
    
    private func getStyleCompatibility(_ style1: ConversationPrompt.ConversationStyle, _ style2: ConversationPrompt.ConversationStyle) -> Double {
        // Define style compatibility matrix
        let compatibilityMatrix: [ConversationPrompt.ConversationStyle: [ConversationPrompt.ConversationStyle: Double]] = [
            .gentle: [.supportive: 0.8, .curious: 0.5, .casual: 0.3, .direct: 0.2],
            .supportive: [.gentle: 0.8, .curious: 0.6, .casual: 0.4, .direct: 0.3],
            .curious: [.gentle: 0.5, .supportive: 0.6, .direct: 0.7, .casual: 0.8],
            .casual: [.curious: 0.8, .direct: 0.6, .gentle: 0.3, .supportive: 0.4],
            .direct: [.curious: 0.7, .casual: 0.6, .supportive: 0.3, .gentle: 0.2]
        ]
        
        return compatibilityMatrix[style1]?[style2] ?? 0.0
    }
    
    private func getToneCompatibility(_ tone1: ConversationPrompt.EmotionalTone, _ tone2: ConversationPrompt.EmotionalTone) -> Double {
        let compatibilityMatrix: [ConversationPrompt.EmotionalTone: [ConversationPrompt.EmotionalTone: Double]] = [
            .warm: [.empathetic: 0.9, .calm: 0.7, .neutral: 0.5, .energetic: 0.4],
            .empathetic: [.warm: 0.9, .calm: 0.8, .neutral: 0.6, .energetic: 0.3],
            .calm: [.warm: 0.7, .empathetic: 0.8, .neutral: 0.9, .energetic: 0.2],
            .neutral: [.calm: 0.9, .warm: 0.5, .empathetic: 0.6, .energetic: 0.7],
            .energetic: [.neutral: 0.7, .warm: 0.4, .empathetic: 0.3, .calm: 0.2]
        ]
        
        return compatibilityMatrix[tone1]?[tone2] ?? 0.0
    }
    
    // MARK: - Variety Filter
    
    private func applyVarietyFilter(_ scoredPrompts: [(prompt: ConversationPrompt, score: Double)], context: ConversationContext) -> [(prompt: ConversationPrompt, score: Double)] {
        // Get recently used prompts (would need to track this in real implementation)
        let recentlyUsedCategories = getRecentlyUsedCategories(context: context)
        let recentlyUsedStyles = getRecentlyUsedStyles(context: context)
        
        return scoredPrompts.map { item in
            var adjustedScore = item.score
            
            // Reduce score for recently used categories
            if recentlyUsedCategories.contains(item.prompt.category) {
                adjustedScore *= (1.0 - varietyWeight)
            }
            
            // Reduce score for recently used styles
            if recentlyUsedStyles.contains(item.prompt.conversationStyle) {
                adjustedScore *= (1.0 - varietyWeight * 0.5)
            }
            
            return (prompt: item.prompt, score: adjustedScore)
        }.sorted { $0.score > $1.score }
    }
    
    private func getRecentlyUsedCategories(context: ConversationContext) -> Set<ConversationPrompt.PromptCategory> {
        // In a real implementation, this would track recently used prompts
        // For now, return empty set
        return Set()
    }
    
    private func getRecentlyUsedStyles(context: ConversationContext) -> Set<ConversationPrompt.ConversationStyle> {
        // In a real implementation, this would track recently used prompts
        // For now, return empty set
        return Set()
    }
    
    // MARK: - Advanced Selection Features
    
    func selectPromptForMood(_ mood: Int, timeContext: TimeContext) -> ConversationPrompt? {
        let availablePrompts = PromptDatabase.allPrompts.filter { $0.timeOfDay == timeContext }
        
        let moodAppropriatePrompts = availablePrompts.filter { prompt in
            switch mood {
            case 1...3: // Low mood
                return prompt.category == .coping || prompt.emotionalTone == .empathetic || prompt.emotionalTone == .warm
            case 4...6: // Neutral mood
                return prompt.category == .openEnded || prompt.category == .reflective
            case 7...10: // High mood
                return prompt.category == .gratitude || prompt.category == .future || prompt.emotionalTone == .energetic
            default:
                return true
            }
        }
        
        guard !moodAppropriatePrompts.isEmpty else {
            return availablePrompts.randomElement()
        }
        
        // Score the mood-appropriate prompts
        let mockContext = ConversationContext()
        mockContext.userMood = mood
        
        let scoredPrompts = moodAppropriatePrompts.map { prompt in
            (prompt: prompt, score: calculatePromptScore(prompt, for: mockContext))
        }
        
        return scoredPrompts.max(by: { $0.score < $1.score })?.prompt
    }
    
    // MARK: - Enhanced Contextual Prompt Generation
    
    func generateContextualPrompt(
        previousResponse: String,
        emotionalState: EmotionalState,
        conversationHistory: [String],
        emotionalTrend: EmotionalTrend
    ) -> String? {
        
        // Avoid repetitive questions
        let recentQuestions = conversationHistory.suffix(3)
        
        // Generate based on emotional trajectory
        switch emotionalTrend {
        case .improving:
            let improvingPrompts = [
                "I can sense something shifting positively for you. What's creating that change?",
                "There's a lightness emerging in your words. What's helping you feel better?",
                "I notice your energy lifting. What's been supporting this positive shift?",
                "Something beautiful seems to be happening for you. What's behind this change?"
            ]
            return selectUniquePrompt(from: improvingPrompts, avoiding: recentQuestions)
            
        case .declining:
            let decliningPrompts = [
                "I notice this feels heavier than when we started. What's weighing on you most?",
                "Something seems to be pulling you down. What's behind that shift?",
                "I can feel the weight increasing for you. What's making things feel harder?",
                "The energy feels different now. What's changed for you?"
            ]
            return selectUniquePrompt(from: decliningPrompts, avoiding: recentQuestions)
            
        case .stable:
            break // Continue to emotional state logic
        }
        
        // Generate based on current emotional state
        switch emotionalState {
        case .highlyPositive:
            let highPositivePrompts = [
                "Your joy is absolutely radiant! What's creating this beautiful energy?",
                "I can feel your happiness through your words! What's making your heart so full?",
                "This level of positivity is wonderful to witness! What's been the source of this joy?",
                "Your light is shining so brightly today. What's fueling this happiness?"
            ]
            return selectUniquePrompt(from: highPositivePrompts, avoiding: recentQuestions)
            
        case .positive:
            let positivePrompts = [
                "I love hearing that contentment in your voice. What's bringing you peace today?",
                "There's a warmth in your words. What's creating those good feelings?",
                "Your positive energy is lovely. What's been nurturing this mood?",
                "I can sense your inner smile. What's been going well for you?"
            ]
            return selectUniquePrompt(from: positivePrompts, avoiding: recentQuestions)
            
        case .mixed:
            let mixedPrompts = [
                "You're experiencing a lot of different emotions. What's behind all these feelings?",
                "I can sense the complexity of what you're feeling. What's the strongest emotion right now?",
                "There's so much happening emotionally for you. What feels most important to explore?",
                "Your heart seems to be holding many feelings at once. What needs attention most?"
            ]
            return selectUniquePrompt(from: mixedPrompts, avoiding: recentQuestions)
            
        case .negative:
            let negativePrompts = [
                "I can hear the difficulty in your words. What's been the hardest part today?",
                "Something feels heavy for you right now. What's weighing on your heart?",
                "I sense you're going through a tough time. What would feel most supportive?",
                "Your struggle is real and valid. What's been most challenging lately?"
            ]
            return selectUniquePrompt(from: negativePrompts, avoiding: recentQuestions)
            
        case .highlyNegative:
            let highNegativePrompts = [
                "I can feel the intensity of what you're going through. What's the hardest part right now?",
                "This sounds overwhelming. What would help you feel even a little bit safer?",
                "I'm here with you in this difficult moment. What does your heart need most?",
                "The pain in your words is palpable. What's been most unbearable?"
            ]
            return selectUniquePrompt(from: highNegativePrompts, avoiding: recentQuestions)
            
        case .neutral:
            let neutralPrompts = [
                "What's alive in your heart right now?",
                "How are you feeling in this moment?",
                "What's been on your mind today?",
                "What would you like to explore together?"
            ]
            return selectUniquePrompt(from: neutralPrompts, avoiding: recentQuestions)
        }
    }
    
    func generateEmotionSpecificPrompt(for dominantEmotion: String, intensity: Double) -> String? {
        switch dominantEmotion {
        case let emotion where isAnxietyEmotion(emotion):
            return generateAnxietyPrompt(intensity: intensity)
        case let emotion where isSadnessEmotion(emotion):
            return generateSadnessPrompt(intensity: intensity)
        case let emotion where isJoyEmotion(emotion):
            return generateJoyPrompt(intensity: intensity)
        case let emotion where isAngerEmotion(emotion):
            return generateAngerPrompt(intensity: intensity)
        case let emotion where isExhaustionEmotion(emotion):
            return generateExhaustionPrompt(intensity: intensity)
        case let emotion where isLonelinessEmotion(emotion):
            return generateLonelinessPrompt(intensity: intensity)
        default:
            return nil
        }
    }
    
    // MARK: - Emotion-Specific Prompt Generators
    
    private func generateAnxietyPrompt(intensity: Double) -> String {
        if intensity >= 0.8 {
            let highAnxietyPrompts = [
                "I can feel the intensity of that anxiety. What's your heart most worried about right now?",
                "That level of worry sounds overwhelming. What thoughts are racing through your mind?",
                "I hear how anxious you're feeling. What would help you feel more grounded in this moment?"
            ]
            return highAnxietyPrompts.randomElement()!
        } else {
            let moderateAnxietyPrompts = [
                "I notice some anxiety in your words. What's creating that nervous energy?",
                "That worry makes sense. What's behind those anxious feelings?",
                "I can hear that unease. What's your mind trying to tell you?"
            ]
            return moderateAnxietyPrompts.randomElement()!
        }
    }
    
    private func generateSadnessPrompt(intensity: Double) -> String {
        if intensity >= 0.8 {
            let deepSadnessPrompts = [
                "I'm so sorry you're carrying this heavy sadness. What's weighing most on your heart?",
                "That depth of sadness is real and valid. What does your heart need right now?",
                "I can feel how much pain you're in. What would feel most supportive in this moment?"
            ]
            return deepSadnessPrompts.randomElement()!
        } else {
            let moderateSadnessPrompts = [
                "I hear that sadness in your words. What's sitting heavy with you today?",
                "That melancholy feeling is understandable. What's behind those sad feelings?",
                "I notice you're feeling down. What's your heart trying to process?"
            ]
            return moderateSadnessPrompts.randomElement()!
        }
    }
    
    private func generateJoyPrompt(intensity: Double) -> String {
        if intensity >= 0.8 {
            let highJoyPrompts = [
                "Your joy is absolutely radiant! What's creating this beautiful happiness?",
                "I can feel your excitement through your words! What's bringing you such delight?",
                "This level of happiness is wonderful to witness! What's making your heart so full?"
            ]
            return highJoyPrompts.randomElement()!
        } else {
            let moderateJoyPrompts = [
                "I love hearing that happiness in your voice! What's bringing you joy today?",
                "That contentment is beautiful. What's creating those good feelings?",
                "Your positive energy is lovely. What's been the highlight of your day?"
            ]
            return moderateJoyPrompts.randomElement()!
        }
    }
    
    private func generateAngerPrompt(intensity: Double) -> String {
        if intensity >= 0.8 {
            let highAngerPrompts = [
                "I can feel the intensity of that anger. What's triggered such strong feelings?",
                "That rage is powerful. What injustice or frustration is fueling this?",
                "Your anger is valid and important. What needs to be heard or changed?"
            ]
            return highAngerPrompts.randomElement()!
        } else {
            let moderateAngerPrompts = [
                "I hear that frustration. What's been irritating or disappointing you?",
                "That annoyance makes sense. What's been rubbing you the wrong way?",
                "I can sense your irritation. What's been challenging your patience?"
            ]
            return moderateAngerPrompts.randomElement()!
        }
    }
    
    private func generateExhaustionPrompt(intensity: Double) -> String {
        if intensity >= 0.8 {
            let highExhaustionPrompts = [
                "That exhaustion sounds complete. What's been draining all your energy?",
                "I can feel how depleted you are. What's been taking so much out of you?",
                "That level of tiredness is profound. What does your body and soul need most?"
            ]
            return highExhaustionPrompts.randomElement()!
        } else {
            let moderateExhaustionPrompts = [
                "I hear that weariness. What's been tiring you out lately?",
                "That fatigue is real. What's been demanding so much of your energy?",
                "I can sense you're worn down. What would help restore you?"
            ]
            return moderateExhaustionPrompts.randomElement()!
        }
    }
    
    private func generateLonelinessPrompt(intensity: Double) -> String {
        if intensity >= 0.8 {
            let highLonelinessPrompts = [
                "That isolation sounds so painful. What's making you feel most alone?",
                "I can feel how disconnected you're feeling. What would help you feel less alone?",
                "That loneliness is profound. What kind of connection are you most longing for?"
            ]
            return highLonelinessPrompts.randomElement()!
        } else {
            let moderateLonelinessPrompts = [
                "I hear that loneliness. What's making you feel disconnected?",
                "That sense of being alone is real. What would help you feel more connected?",
                "I can sense that isolation. What kind of support would feel most meaningful?"
            ]
            return moderateLonelinessPrompts.randomElement()!
        }
    }
    
    // MARK: - Helper Methods for Enhanced Selection
    
    private func selectUniquePrompt(from prompts: [String], avoiding recentQuestions: ArraySlice<String>) -> String? {
        let availablePrompts = prompts.filter { prompt in
            !recentQuestions.contains { recent in
                calculateSimilarity(prompt, recent) > 0.7
            }
        }
        
        return availablePrompts.randomElement() ?? prompts.randomElement()
    }
    
    private func calculateSimilarity(_ text1: String, _ text2: String) -> Double {
        let words1 = Set(text1.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let words2 = Set(text2.lowercased().components(separatedBy: .whitespacesAndNewlines))
        
        let intersection = words1.intersection(words2)
        let union = words1.union(words2)
        
        return union.isEmpty ? 0.0 : Double(intersection.count) / Double(union.count)
    }
    
    // MARK: - Emotion Classification Helpers
    
    private func isAnxietyEmotion(_ emotion: String) -> Bool {
        let anxietyEmotions = ["anxious", "worried", "nervous", "stressed", "overwhelmed", "panicked", "terrified", "fearful", "tense", "uneasy", "restless", "agitated"]
        return anxietyEmotions.contains(emotion)
    }
    
    private func isSadnessEmotion(_ emotion: String) -> Bool {
        let sadnessEmotions = ["sad", "depressed", "down", "blue", "devastated", "heartbroken", "empty", "hopeless", "melancholy", "grief", "sorrow", "despondent", "dejected", "gloomy", "miserable"]
        return sadnessEmotions.contains(emotion)
    }
    
    private func isJoyEmotion(_ emotion: String) -> Bool {
        let joyEmotions = ["happy", "excited", "thrilled", "ecstatic", "delighted", "cheerful", "content", "joyful", "elated", "euphoric", "blissful", "gleeful", "upbeat", "optimistic", "radiant"]
        return joyEmotions.contains(emotion)
    }
    
    private func isAngerEmotion(_ emotion: String) -> Bool {
        let angerEmotions = ["angry", "furious", "mad", "irritated", "frustrated", "rage", "livid", "irate", "annoyed", "aggravated", "incensed", "outraged", "resentful", "bitter", "hostile"]
        return angerEmotions.contains(emotion)
    }
    
    private func isExhaustionEmotion(_ emotion: String) -> Bool {
        let exhaustionEmotions = ["tired", "exhausted", "drained", "weary", "fatigued", "depleted", "worn", "spent", "burned", "wiped"]
        return exhaustionEmotions.contains(emotion)
    }
    
    private func isLonelinessEmotion(_ emotion: String) -> Bool {
        let lonelinessEmotions = ["lonely", "isolated", "alone", "disconnected", "abandoned", "forsaken", "solitary", "excluded"]
        return lonelinessEmotions.contains(emotion)
    }
    
    func selectFollowUpPrompt(for originalPrompt: ConversationPrompt, response: String) -> ConversationPrompt? {
        guard !originalPrompt.followUps.isEmpty else { return nil }
        
        // Check if response contains trigger words
        let triggerFound = originalPrompt.followUpTriggers.contains { trigger in
            response.lowercased().contains(trigger.lowercased())
        }
        
        guard triggerFound else { return nil }
        
        // Create a follow-up prompt
        let followUpQuestion = originalPrompt.followUps.randomElement() ?? "Tell me more about that."
        
        return ConversationPrompt(
            id: "followup_\(UUID().uuidString)",
            question: followUpQuestion,
            category: originalPrompt.category,
            timeOfDay: originalPrompt.timeOfDay,
            conversationStyle: originalPrompt.conversationStyle,
            followUpTriggers: [],
            followUps: [],
            emotionalTone: originalPrompt.emotionalTone
        )
    }
    
    func getPromptRecommendations(count: Int = 5) -> [PromptRecommendation] {
        let currentTime = TimeContext.current()
        let availablePrompts = PromptDatabase.allPrompts.filter { $0.timeOfDay == currentTime }
        
        let mockContext = ConversationContext()
        
        let scoredPrompts = availablePrompts.map { prompt in
            let score = calculatePromptScore(prompt, for: mockContext)
            let compatibility = userPattern.getCompatibilityScore(for: prompt)
            
            return PromptRecommendation(
                prompt: prompt,
                score: score,
                compatibilityScore: compatibility,
                reason: generateRecommendationReason(prompt, score: score)
            )
        }
        
        return Array(scoredPrompts.sorted { $0.score > $1.score }.prefix(count))
    }
    
    private func generateRecommendationReason(_ prompt: ConversationPrompt, score: Double) -> String {
        var reasons: [String] = []
        
        if prompt.conversationStyle == userPattern.preferredStyle {
            reasons.append("matches your preferred \(prompt.conversationStyle.displayName.lowercased()) style")
        }
        
        if prompt.emotionalTone == userPattern.preferredTone {
            reasons.append("uses your preferred \(prompt.emotionalTone.displayName.lowercased()) tone")
        }
        
        if userPattern.preferredCategories.contains(prompt.category) {
            reasons.append("focuses on \(prompt.category.displayName.lowercased()) topics you enjoy")
        }
        
        let timePreference = userPattern.timePreferences[prompt.timeOfDay] ?? 0.25
        if timePreference > 0.3 {
            reasons.append("fits your active \(prompt.timeOfDay.displayName.lowercased()) time")
        }
        
        if reasons.isEmpty {
            return "Good general fit for your conversation preferences"
        } else {
            return reasons.joined(separator: ", ")
        }
    }
}

// MARK: - Supporting Types

struct PromptRecommendation {
    let prompt: ConversationPrompt
    let score: Double
    let compatibilityScore: Double
    let reason: String
    
    var formattedScore: String {
        String(format: "%.1f", score)
    }
    
    var compatibilityPercentage: Int {
        Int(compatibilityScore * 50) // Convert to percentage (max score is ~2.0)
    }
}
