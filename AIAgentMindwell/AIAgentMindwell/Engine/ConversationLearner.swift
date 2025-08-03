//
//  ConversationLearner.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation
import SwiftUI

class ConversationLearner: ObservableObject {
    @AppStorage("user_patterns") private var userPatternsData: Data = Data()
    private var userPattern: UserPattern
    private let responseAnalyzer = ResponseAnalyzer()
    
    // Learning configuration
    private let maxEmotionalWords = 50
    private let maxMoodPatternWords = 20
    private let learningRate = 0.1
    
    init() {
        // Initialize userPattern first
        self.userPattern = UserPattern()
        
        // Then try to load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "user_patterns"),
           let decoded = try? JSONDecoder().decode(UserPattern.self, from: data) {
            self.userPattern = decoded
        }
    }
    
    // MARK: - Main Learning Method
    
    func analyzeResponse(_ response: UserResponse) {
        // 1. Analyze response length preference
        updateResponseLengthPreference(response)
        
        // 2. Extract emotional keywords
        extractAndUpdateEmotionalKeywords(response)
        
        // 3. Determine conversation style preference
        updateStylePreference(response)
        
        // 4. Update mood-word associations
        updateMoodPatterns(response)
        
        // 5. Update time preferences
        updateTimePreferences(response)
        
        // 6. Update conversation depth preference
        updateConversationDepth(response)
        
        // 7. Update category preferences
        updateCategoryPreferences(response)
        
        // 8. Update user pattern with response
        userPattern.updateWithResponse(response)
        
        // 9. Save learned patterns
        saveUserPattern()
    }
    
    // MARK: - Learning Methods
    
    private func updateResponseLengthPreference(_ response: UserResponse) {
        let wordCount = response.wordCount
        
        let detectedLength: ResponseLength
        switch wordCount {
        case 0..<50: detectedLength = .short
        case 50..<150: detectedLength = .medium
        default: detectedLength = .long
        }
        
        // Gradually shift preference based on consistent patterns and engagement
        if response.engagementLevel == .engaged || response.engagementLevel == .deep {
            // Smooth transition to new preference
            if detectedLength != userPattern.responseLength {
                // Only change if we see consistent pattern
                userPattern.responseLength = detectedLength
            }
        }
    }
    
    private func extractAndUpdateEmotionalKeywords(_ response: UserResponse) {
        let emotionalWords = response.keyEmotions
        
        for word in emotionalWords {
            userPattern.emotionalKeywords[word, default: 0] += 1
        }
        
        // Keep only top most frequent emotional words
        if userPattern.emotionalKeywords.count > maxEmotionalWords {
            let sortedWords = userPattern.emotionalKeywords.sorted { $0.value > $1.value }
            let topWords = Array(sortedWords.prefix(maxEmotionalWords))
            userPattern.emotionalKeywords = Dictionary(topWords, uniquingKeysWith: { $1 })
        }
    }
    
    private func updateStylePreference(_ response: UserResponse) {
        // Analyze response characteristics to infer preferred conversation style
        let wordCount = response.wordCount
        let emotionalWords = response.keyEmotions.count
        let engagementLevel = response.engagementLevel
        
        // Infer preferred style based on response patterns
        var preferredStyle: ConversationPrompt.ConversationStyle = userPattern.preferredStyle
        
        switch engagementLevel {
        case .deep:
            if wordCount > 100 && emotionalWords > 3 {
                preferredStyle = .supportive // Deep responses suggest preference for supportive style
            } else if emotionalWords > 2 {
                preferredStyle = .gentle // Emotional but not lengthy suggests gentle approach
            }
        case .engaged:
            if emotionalWords > 1 {
                preferredStyle = .curious // Engaged responses suggest curiosity works
            }
        case .minimal:
            preferredStyle = .casual // Brief responses might prefer casual approach
        }
        
        // Gradually shift preference
        if preferredStyle != userPattern.preferredStyle {
            userPattern.preferredStyle = preferredStyle
        }
    }
    
    private func updateMoodPatterns(_ response: UserResponse) {
        let words = responseAnalyzer.extractKeyWords(from: response.response)
        userPattern.moodPatterns[response.mood, default: []].append(contentsOf: words)
        
        // Keep only recent patterns per mood
        for mood in userPattern.moodPatterns.keys {
            if let moodWords = userPattern.moodPatterns[mood], moodWords.count > maxMoodPatternWords {
                userPattern.moodPatterns[mood] = Array(moodWords.suffix(maxMoodPatternWords))
            }
        }
    }
    
    private func updateTimePreferences(_ response: UserResponse) {
        let currentTime = TimeContext.current()
        let currentPreference = userPattern.timePreferences[currentTime] ?? 0.25
        
        // Increase preference for times when user is more engaged
        let engagementBonus: Double = switch response.engagementLevel {
        case .deep: 0.1
        case .engaged: 0.05
        case .minimal: -0.02 // Slight decrease for minimal engagement
        }
        
        let newPreference = max(0.1, min(1.0, currentPreference + engagementBonus))
        userPattern.timePreferences[currentTime] = newPreference
        
        // Normalize preferences to sum to 1.0
        normalizeTimePreferences()
        
        // Update most active time
        userPattern.mostActiveTimeOfDay = userPattern.timePreferences.max(by: { $0.value < $1.value })?.key ?? .morning
    }
    
    private func normalizeTimePreferences() {
        let total = userPattern.timePreferences.values.reduce(0, +)
        
        // Ensure total is finite and greater than zero
        guard total.isFinite && total > 0 else {
            // Reset to default equal preferences if total is invalid
            userPattern.timePreferences = [
                .morning: 0.25,
                .afternoon: 0.25,
                .evening: 0.25,
                .night: 0.25
            ]
            return
        }
        
        // Normalize each preference
        for key in userPattern.timePreferences.keys {
            let currentValue = userPattern.timePreferences[key] ?? 0
            let normalizedValue = currentValue / total
            
            // Ensure normalized value is finite and within reasonable bounds
            if normalizedValue.isFinite && normalizedValue >= 0 && normalizedValue <= 1.0 {
                userPattern.timePreferences[key] = normalizedValue
            } else {
                userPattern.timePreferences[key] = 0.25 // Default fallback
            }
        }
        
        // Final validation - ensure all values sum to approximately 1.0
        let finalTotal = userPattern.timePreferences.values.reduce(0, +)
        if !finalTotal.isFinite || abs(finalTotal - 1.0) > 0.1 {
            // Reset to defaults if normalization failed
            userPattern.timePreferences = [
                .morning: 0.25,
                .afternoon: 0.25,
                .evening: 0.25,
                .night: 0.25
            ]
        }
    }
    
    private func updateConversationDepth(_ response: UserResponse) {
        let currentDepth = userPattern.conversationDepth
        let responseDepth = inferConversationDepth(from: response)
        
        // Gradually adjust depth preference based on engagement
        switch (currentDepth, responseDepth, response.engagementLevel) {
        case (.surface, .moderate, .engaged), (.surface, .deep, .deep):
            userPattern.conversationDepth = .moderate
        case (.moderate, .deep, .deep):
            userPattern.conversationDepth = .deep
        case (.deep, .surface, .minimal), (.moderate, .surface, .minimal):
            // User might be overwhelmed, reduce depth
            if currentDepth == .deep {
                userPattern.conversationDepth = .moderate
            } else {
                userPattern.conversationDepth = .surface
            }
        default:
            break // Keep current depth
        }
    }
    
    private func inferConversationDepth(from response: UserResponse) -> UserPattern.ConversationDepth {
        let wordCount = response.wordCount
        let emotionalWords = response.keyEmotions.count
        
        if wordCount > 100 && emotionalWords > 3 {
            return .deep
        } else if wordCount > 50 && emotionalWords > 1 {
            return .moderate
        } else {
            return .surface
        }
    }
    
    private func updateCategoryPreferences(_ response: UserResponse) {
        // This would require knowing which category the prompt belonged to
        // For now, we'll infer preferences based on response characteristics
        
        let emotionalWords = response.keyEmotions
        let mood = response.mood
        
        // Infer category preferences based on response patterns
        if emotionalWords.contains(where: { ["grateful", "thankful", "blessed"].contains($0) }) {
            if !userPattern.preferredCategories.contains(.gratitude) {
                userPattern.preferredCategories.append(.gratitude)
            }
        }
        
        if response.wordCount > 100 && emotionalWords.count > 2 {
            if !userPattern.preferredCategories.contains(.reflective) {
                userPattern.preferredCategories.append(.reflective)
            }
        }
        
        if mood <= 4 && emotionalWords.contains(where: { ["stressed", "anxious", "overwhelmed"].contains($0) }) {
            if !userPattern.preferredCategories.contains(.coping) {
                userPattern.preferredCategories.append(.coping)
            }
        }
        
        // Limit preferred categories to avoid over-specialization
        if userPattern.preferredCategories.count > 4 {
            userPattern.preferredCategories = Array(userPattern.preferredCategories.prefix(4))
        }
    }
    
    // MARK: - Personalized Prompt Selection
    
    func getPersonalizedPrompt(for context: ConversationContext) -> ConversationPrompt? {
        let selector = PromptSelector(userPattern: userPattern)
        return selector.selectBestPrompt(for: context)
    }
    
    func getPersonalizedPrompts(for timeContext: TimeContext, count: Int = 3) -> [ConversationPrompt] {
        let selector = PromptSelector(userPattern: userPattern)
        return selector.selectBestPrompts(for: timeContext, count: count)
    }
    
    // MARK: - Learning Analytics
    
    func getLearningInsights() -> LearningInsights {
        return LearningInsights(
            totalResponses: userPattern.totalResponses,
            averageResponseLength: userPattern.averageResponseLength,
            preferredStyle: userPattern.preferredStyle,
            preferredTone: userPattern.preferredTone,
            conversationDepth: userPattern.conversationDepth,
            topEmotionalWords: userPattern.topEmotionalWords,
            mostActiveTime: userPattern.mostActiveTimeOfDay,
            averageMood: userPattern.averageMood,
            engagementTrend: userPattern.engagementTrend,
            personalityInsights: userPattern.personalityInsights
        )
    }
    
    func getCompatibilityScore(for prompt: ConversationPrompt) -> Double {
        return userPattern.getCompatibilityScore(for: prompt)
    }
    
    // MARK: - Data Persistence
    
    private func saveUserPattern() {
        if let encoded = try? JSONEncoder().encode(userPattern) {
            userPatternsData = encoded
        }
    }
    
    func exportUserPattern() -> Data? {
        return try? JSONEncoder().encode(userPattern)
    }
    
    func importUserPattern(from data: Data) -> Bool {
        if let decoded = try? JSONDecoder().decode(UserPattern.self, from: data) {
            userPattern = decoded
            saveUserPattern()
            return true
        }
        return false
    }
    
    func resetLearning() {
        userPattern = UserPattern()
        saveUserPattern()
    }
    
    // MARK: - Advanced Learning Features
    
    func predictOptimalPromptTime() -> TimeContext {
        return userPattern.preferredTimeOfDay
    }
    
    func shouldOfferDeepDivePrompt() -> Bool {
        return userPattern.conversationDepth == .deep && userPattern.engagementTrend != .declining
    }
    
    func getEmotionalTriggerWords() -> [String] {
        return userPattern.topEmotionalWords
    }
}

// MARK: - Supporting Types

struct LearningInsights {
    let totalResponses: Int
    let averageResponseLength: Double
    let preferredStyle: ConversationPrompt.ConversationStyle
    let preferredTone: ConversationPrompt.EmotionalTone
    let conversationDepth: UserPattern.ConversationDepth
    let topEmotionalWords: [String]
    let mostActiveTime: TimeContext
    let averageMood: Double
    let engagementTrend: UserPattern.EngagementTrend
    let personalityInsights: [String]
    
    var learningProgress: Double {
        // Calculate learning progress based on total responses
        let maxResponses = 50.0 // Consider fully learned after 50 responses
        return min(1.0, Double(totalResponses) / maxResponses)
    }
    
    var isWellLearned: Bool {
        return totalResponses >= 10 && learningProgress > 0.2
    }
}

// Enhanced Response Analyzer
extension ResponseAnalyzer {
    func extractKeyWords(from text: String) -> [String] {
        let words = text.lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 && !isStopWord($0) } // Filter out stop words
        
        return Array(Set(words)) // Remove duplicates
    }
    
    private func isStopWord(_ word: String) -> Bool {
        let stopWords: Set<String> = [
            "that", "this", "with", "have", "will", "been", "from", "they", "know",
            "want", "been", "good", "much", "some", "time", "very", "when", "come",
            "here", "just", "like", "long", "make", "many", "over", "such", "take",
            "than", "them", "well", "were", "what", "your"
        ]
        return stopWords.contains(word)
    }
    
    func analyzeEngagementLevel(_ response: UserResponse) -> UserResponse.EngagementLevel {
        let wordCount = response.wordCount
        let emotionalWords = response.keyEmotions.count
        let responseTime = response.responseTime
        
        // Consider multiple factors for engagement
        var engagementScore = 0.0
        
        // Word count factor
        if wordCount > 100 {
            engagementScore += 0.4
        } else if wordCount > 30 {
            engagementScore += 0.2
        }
        
        // Emotional word factor
        if emotionalWords > 3 {
            engagementScore += 0.3
        } else if emotionalWords > 1 {
            engagementScore += 0.15
        }
        
        // Response time factor (more time = more thought)
        if responseTime > 60 { // More than 1 minute
            engagementScore += 0.2
        } else if responseTime > 30 {
            engagementScore += 0.1
        }
        
        // Determine engagement level
        if engagementScore >= 0.6 {
            return .deep
        } else if engagementScore >= 0.3 {
            return .engaged
        } else {
            return .minimal
        }
    }
}
