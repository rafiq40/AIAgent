//
//  UserPattern.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation
import SwiftUI

@Observable
class UserPattern: Codable {
    var preferredStyle: ConversationPrompt.ConversationStyle = .gentle
    var preferredTone: ConversationPrompt.EmotionalTone = .warm
    var responseLength: ResponseLength = .medium
    var preferredCategories: [ConversationPrompt.PromptCategory] = []
    var emotionalKeywords: [String: Int] = [:] // Word frequency
    var conversationDepth: ConversationDepth = .surface
    var timePreferences: [TimeContext: Double] = [:]
    var moodPatterns: [Int: [String]] = [:] // mood -> common words
    var lastUpdated: Date = Date()
    
    // Learning metrics
    var totalResponses: Int = 0
    var averageResponseLength: Double = 0.0
    var mostActiveTimeOfDay: TimeContext = .morning
    var averageMood: Double = 5.0
    var engagementTrend: EngagementTrend = .stable
    
    init() {
        // Initialize with default preferences
        self.preferredCategories = [.openEnded, .reflective]
        self.timePreferences = [
            .morning: 0.25,
            .afternoon: 0.25,
            .evening: 0.25,
            .night: 0.25
        ]
    }
    
    enum ConversationDepth: String, CaseIterable, Codable {
        case surface = "surface"     // Basic emotions
        case moderate = "moderate"   // Some reflection
        case deep = "deep"          // Detailed analysis
        
        var displayName: String {
            switch self {
            case .surface: return "Surface"
            case .moderate: return "Moderate"
            case .deep: return "Deep"
            }
        }
        
        var description: String {
            switch self {
            case .surface: return "Prefers brief, surface-level conversations"
            case .moderate: return "Enjoys moderate reflection and exploration"
            case .deep: return "Engages in deep, detailed emotional analysis"
            }
        }
    }
    
    enum EngagementTrend: String, CaseIterable, Codable {
        case declining = "declining"
        case stable = "stable"
        case improving = "improving"
        
        var displayName: String {
            switch self {
            case .declining: return "Declining"
            case .stable: return "Stable"
            case .improving: return "Improving"
            }
        }
        
        var emoji: String {
            switch self {
            case .declining: return "📉"
            case .stable: return "➡️"
            case .improving: return "📈"
            }
        }
    }
    
    // MARK: - Learning Methods
    
    func updateWithResponse(_ response: UserResponse) {
        totalResponses += 1
        lastUpdated = Date()
        
        // Update response length preference
        updateResponseLengthPreference(response)
        
        // Update emotional keywords
        updateEmotionalKeywords(response.keyEmotions)
        
        // Update mood patterns
        updateMoodPatterns(response)
        
        // Update time preferences
        updateTimePreferences(response)
        
        // Update conversation depth
        updateConversationDepth(response)
        
        // Update average mood
        updateAverageMood(response.mood)
        
        // Update engagement trend
        updateEngagementTrend(response)
    }
    
    private func updateResponseLengthPreference(_ response: UserResponse) {
        let detectedLength = response.responseLength
        
        // Gradually shift preference based on consistent patterns
        if response.engagementLevel == .engaged || response.engagementLevel == .deep {
            responseLength = detectedLength
        }
        
        // Update average response length with safety checks
        guard totalResponses > 0 else {
            averageResponseLength = Double(response.wordCount)
            return
        }
        
        let newAverage = (averageResponseLength * Double(totalResponses - 1) + Double(response.wordCount)) / Double(totalResponses)
        
        // Ensure the result is finite and reasonable
        if newAverage.isFinite && newAverage >= 0 && newAverage <= 10000 { // Max 10k words seems reasonable
            averageResponseLength = newAverage
        } else {
            // Fallback to current response word count if calculation fails
            averageResponseLength = Double(response.wordCount)
        }
    }
    
    private func updateEmotionalKeywords(_ emotions: [String]) {
        for emotion in emotions {
            emotionalKeywords[emotion, default: 0] += 1
        }
        
        // Keep only top 50 most frequent emotional words
        if emotionalKeywords.count > 50 {
            let sortedWords = emotionalKeywords.sorted { $0.value > $1.value }
            let topWords = Array(sortedWords.prefix(50))
            emotionalKeywords = Dictionary(topWords, uniquingKeysWith: { $1 })
        }
    }
    
    private func updateMoodPatterns(_ response: UserResponse) {
        let words = extractKeyWords(from: response.response)
        moodPatterns[response.mood, default: []].append(contentsOf: words)
        
        // Keep only recent patterns (last 20 entries per mood)
        for mood in moodPatterns.keys {
            if let moodWords = moodPatterns[mood], moodWords.count > 20 {
                moodPatterns[mood] = Array(moodWords.suffix(20))
            }
        }
    }
    
    private func updateTimePreferences(_ response: UserResponse) {
        let currentTime = TimeContext.current()
        let currentPreference = timePreferences[currentTime] ?? 0.25
        
        // Increase preference for times when user is more engaged
        let engagementBonus = response.engagementLevel == .deep ? 0.1 : 
                             response.engagementLevel == .engaged ? 0.05 : 0.0
        
        timePreferences[currentTime] = min(1.0, currentPreference + engagementBonus)
        
        // Normalize preferences to sum to 1.0
        let total = timePreferences.values.reduce(0, +)
        if total > 0 {
            for key in timePreferences.keys {
                timePreferences[key] = (timePreferences[key] ?? 0) / total
            }
        }
        
        // Update most active time
        mostActiveTimeOfDay = timePreferences.max(by: { $0.value < $1.value })?.key ?? .morning
    }
    
    private func updateConversationDepth(_ response: UserResponse) {
        switch response.engagementLevel {
        case .minimal:
            if conversationDepth == .deep {
                conversationDepth = .moderate
            } else if conversationDepth == .moderate {
                conversationDepth = .surface
            }
        case .engaged:
            if conversationDepth == .surface {
                conversationDepth = .moderate
            }
        case .deep:
            conversationDepth = .deep
        }
    }
    
    private func updateAverageMood(_ mood: Int) {
        guard totalResponses > 0 else {
            averageMood = Double(mood)
            return
        }
        
        let newAverage = (averageMood * Double(totalResponses - 1) + Double(mood)) / Double(totalResponses)
        
        // Ensure the result is finite and within valid range
        if newAverage.isFinite && newAverage >= 1.0 && newAverage <= 10.0 {
            averageMood = newAverage
        } else {
            // Fallback to current mood if calculation fails
            averageMood = Double(mood)
        }
    }
    
    private func updateEngagementTrend(_ response: UserResponse) {
        // Simple trend analysis based on recent engagement
        // In a real implementation, this would analyze the last 5-10 responses
        switch response.engagementLevel {
        case .minimal:
            if engagementTrend == .improving {
                engagementTrend = .stable
            } else if engagementTrend == .stable {
                engagementTrend = .declining
            }
        case .engaged:
            engagementTrend = .stable
        case .deep:
            if engagementTrend == .declining {
                engagementTrend = .stable
            } else if engagementTrend == .stable {
                engagementTrend = .improving
            }
        }
    }
    
    private func extractKeyWords(from text: String) -> [String] {
        let words = text.lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 } // Only meaningful words
        
        return Array(Set(words)) // Remove duplicates
    }
    
    // MARK: - Preference Analysis
    
    var topEmotionalWords: [String] {
        emotionalKeywords.sorted { $0.value > $1.value }
            .prefix(10)
            .map { $0.key }
    }
    
    var preferredTimeOfDay: TimeContext {
        mostActiveTimeOfDay
    }
    
    func getMoodWords(for mood: Int) -> [String] {
        moodPatterns[mood] ?? []
    }
    
    func getCompatibilityScore(for prompt: ConversationPrompt) -> Double {
        var score = 1.0
        
        // Style compatibility
        if prompt.conversationStyle == preferredStyle {
            score += 0.3
        }
        
        // Tone compatibility
        if prompt.emotionalTone == preferredTone {
            score += 0.2
        }
        
        // Category preference
        if preferredCategories.contains(prompt.category) {
            score += 0.2
        }
        
        // Time preference
        let timeScore = timePreferences[prompt.timeOfDay] ?? 0.25
        score += timeScore * 0.3
        
        return min(2.0, score) // Cap at 2.0
    }
    
    // MARK: - Insights
    
    var personalityInsights: [String] {
        var insights: [String] = []
        
        if averageResponseLength > 100 {
            insights.append("Enjoys detailed conversations")
        } else if averageResponseLength < 30 {
            insights.append("Prefers brief interactions")
        }
        
        if averageMood > 7 {
            insights.append("Generally positive mood")
        } else if averageMood < 4 {
            insights.append("Often experiences lower moods")
        }
        
        if conversationDepth == .deep {
            insights.append("Engages in deep self-reflection")
        } else if conversationDepth == .surface {
            insights.append("Prefers surface-level check-ins")
        }
        
        return insights
    }
}
