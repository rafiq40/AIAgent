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
