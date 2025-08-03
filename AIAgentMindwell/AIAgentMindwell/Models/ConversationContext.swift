//
//  ConversationContext.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation
import SwiftUI

@Observable
class ConversationContext {
    let dayId: String
    var currentPrompt: ConversationPrompt?
    var conversationHistory: [ConversationExchange] = []
    var userMood: Int = 5
    var detectedEmotions: [String] = []
    var conversationFlow: ConversationFlow = .initial
    var startTime: Date = Date()
    var isActive: Bool = false
    var totalResponseTime: TimeInterval = 0
    
    init(dayId: String = DateFormatter.dayFormatter.string(from: Date())) {
        self.dayId = dayId
        self.startTime = Date()
    }
    
    struct ConversationExchange: Identifiable, Codable {
        let id: String
        let prompt: String
        let response: String
        let timestamp: Date
        let mood: Int
        let responseTime: TimeInterval
        
        init(prompt: String, response: String, timestamp: Date = Date(), mood: Int = 5, responseTime: TimeInterval = 0) {
            self.id = UUID().uuidString
            self.prompt = prompt
            self.response = response
            self.timestamp = timestamp
            self.mood = mood
            self.responseTime = responseTime
        }
    }
    
    enum ConversationFlow: String, CaseIterable, Codable {
        case initial = "initial"           // First question
        case followUp = "follow_up"        // Based on response
        case deepDive = "deep_dive"        // User wants to explore more
        case closing = "closing"           // Wrapping up
        
        var displayName: String {
            switch self {
            case .initial: return "Initial"
            case .followUp: return "Follow-up"
            case .deepDive: return "Deep Dive"
            case .closing: return "Closing"
            }
        }
        
        var description: String {
            switch self {
            case .initial: return "Starting the conversation"
            case .followUp: return "Following up on previous response"
            case .deepDive: return "Exploring deeper into emotions"
            case .closing: return "Wrapping up the conversation"
            }
        }
        
        var icon: String {
            switch self {
            case .initial: return "play.circle"
            case .followUp: return "arrow.right.circle"
            case .deepDive: return "magnifyingglass.circle"
            case .closing: return "checkmark.circle"
            }
        }
    }
    
    // MARK: - Conversation Management
    
    func startConversation(with prompt: ConversationPrompt) {
        currentPrompt = prompt
        conversationFlow = .initial
        isActive = true
        startTime = Date()
        conversationHistory.removeAll()
        detectedEmotions.removeAll()
    }
    
    func addExchange(prompt: String, response: String, mood: Int, responseTime: TimeInterval = 0) {
        let exchange = ConversationExchange(
            prompt: prompt,
            response: response,
            timestamp: Date(),
            mood: mood,
            responseTime: responseTime
        )
        
        conversationHistory.append(exchange)
        userMood = mood
        totalResponseTime += responseTime
        
        // Extract emotions from response
        let analyzer = ResponseAnalyzer()
        let emotions = analyzer.extractEmotionalWords(from: response)
        detectedEmotions.append(contentsOf: emotions)
        detectedEmotions = Array(Set(detectedEmotions)) // Remove duplicates
    }
    
    func moveToFollowUp() {
        conversationFlow = .followUp
    }
    
    func moveToDeepDive() {
        conversationFlow = .deepDive
    }
    
    func endConversation() {
        conversationFlow = .closing
        isActive = false
    }
    
    // MARK: - Analysis Properties
    
    var conversationDuration: TimeInterval {
        Date().timeIntervalSince(startTime)
    }
    
    var exchangeCount: Int {
        conversationHistory.count
    }
    
    var averageResponseTime: TimeInterval {
        guard exchangeCount > 0 else { return 0 }
        return totalResponseTime / Double(exchangeCount)
    }
    
    var moodProgression: [Int] {
        conversationHistory.map { $0.mood }
    }
    
    var moodTrend: MoodTrend {
        guard conversationHistory.count >= 2 else { return .stable }
        
        let first = conversationHistory.first?.mood ?? 5
        let last = conversationHistory.last?.mood ?? 5
        
        if last > first + 1 {
            return .improving
        } else if last < first - 1 {
            return .declining
        } else {
            return .stable
        }
    }
    
    var engagementLevel: UserResponse.EngagementLevel {
        guard !conversationHistory.isEmpty else { return .minimal }
        
        let totalWords = conversationHistory.reduce(0) { total, exchange in
            total + exchange.response.components(separatedBy: .whitespacesAndNewlines).count
        }
        
        let averageWords = totalWords / conversationHistory.count
        let emotionCount = detectedEmotions.count
        
        if averageWords > 100 && emotionCount > 3 {
            return .deep
        } else if averageWords > 30 && emotionCount > 1 {
            return .engaged
        } else {
            return .minimal
        }
    }
    
    var lastResponse: String? {
        conversationHistory.last?.response
    }
    
    var lastMood: Int {
        conversationHistory.last?.mood ?? userMood
    }
    
    // MARK: - Conversation Insights
    
    var conversationSummary: ConversationSummary {
        ConversationSummary(
            dayId: dayId,
            duration: conversationDuration,
            exchangeCount: exchangeCount,
            finalMood: lastMood,
            moodTrend: moodTrend,
            engagementLevel: engagementLevel,
            keyEmotions: Array(detectedEmotions.prefix(5)),
            conversationFlow: conversationFlow
        )
    }
    
    func shouldOfferFollowUp() -> Bool {
        guard let currentPrompt = currentPrompt,
              let lastResponse = lastResponse else { return false }
        
        // Check if response contains trigger words
        let triggerFound = currentPrompt.followUpTriggers.contains { trigger in
            lastResponse.lowercased().contains(trigger.lowercased())
        }
        
        return triggerFound && !currentPrompt.followUps.isEmpty && conversationFlow == .initial
    }
    
    func getFollowUpQuestion() -> String? {
        guard let currentPrompt = currentPrompt,
              shouldOfferFollowUp() else { return nil }
        
        return currentPrompt.followUps.randomElement()
    }
    
    func reset() {
        currentPrompt = nil
        conversationHistory.removeAll()
        userMood = 5
        detectedEmotions.removeAll()
        conversationFlow = .initial
        startTime = Date()
        isActive = false
        totalResponseTime = 0
    }
}

// MARK: - Supporting Types

enum MoodTrend: String, CaseIterable, Codable {
    case improving = "improving"
    case stable = "stable"
    case declining = "declining"
    
    var displayName: String {
        switch self {
        case .improving: return "Improving"
        case .stable: return "Stable"
        case .declining: return "Declining"
        }
    }
    
    var emoji: String {
        switch self {
        case .improving: return "📈"
        case .stable: return "➡️"
        case .declining: return "📉"
        }
    }
    
    var color: String {
        switch self {
        case .improving: return "green"
        case .stable: return "blue"
        case .declining: return "red"
        }
    }
}

struct ConversationSummary: Codable, Identifiable {
    let id: String
    let dayId: String
    let duration: TimeInterval
    let exchangeCount: Int
    let finalMood: Int
    let moodTrend: MoodTrend
    let engagementLevel: UserResponse.EngagementLevel
    let keyEmotions: [String]
    let conversationFlow: ConversationContext.ConversationFlow
    let timestamp: Date
    
    init(dayId: String, duration: TimeInterval, exchangeCount: Int, finalMood: Int, moodTrend: MoodTrend, engagementLevel: UserResponse.EngagementLevel, keyEmotions: [String], conversationFlow: ConversationContext.ConversationFlow) {
        self.id = UUID().uuidString
        self.dayId = dayId
        self.duration = duration
        self.exchangeCount = exchangeCount
        self.finalMood = finalMood
        self.moodTrend = moodTrend
        self.engagementLevel = engagementLevel
        self.keyEmotions = keyEmotions
        self.conversationFlow = conversationFlow
        self.timestamp = Date()
    }
    
    var durationFormatted: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var moodEmoji: String {
        UserResponse.moodEmojis[finalMood] ?? "😐"
    }
}

// MARK: - Response Analyzer (Basic Implementation)

class ResponseAnalyzer {
    private let emotionalWords: Set<String> = [
        // Positive emotions
        "happy", "joy", "excited", "grateful", "content", "peaceful", "calm", "loved",
        "confident", "hopeful", "optimistic", "energetic", "satisfied", "fulfilled",
        "proud", "relieved", "motivated", "inspired", "cheerful", "delighted",
        
        // Negative emotions  
        "sad", "anxious", "worried", "stressed", "overwhelmed", "frustrated", "angry",
        "lonely", "tired", "exhausted", "disappointed", "confused", "scared", "nervous",
        "depressed", "upset", "irritated", "annoyed", "hurt", "discouraged",
        
        // Neutral/complex emotions
        "mixed", "uncertain", "curious", "thoughtful", "reflective", "nostalgic",
        "surprised", "determined", "focused", "contemplative", "pensive", "introspective"
    ]
    
    func extractEmotionalWords(from text: String) -> [String] {
        let words = text.lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespacesAndNewlines)
        
        return words.filter { emotionalWords.contains($0) }
    }
}
