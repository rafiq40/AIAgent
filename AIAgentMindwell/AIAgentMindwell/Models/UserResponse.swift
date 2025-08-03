//
//  UserResponse.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation

struct UserResponse: Codable, Identifiable {
    let id: String
    let promptId: String
    let response: String
    let mood: Int
    let timestamp: Date
    let dayId: String
    let conversationLength: Int // Number of exchanges
    let engagementLevel: EngagementLevel
    let keyEmotions: [String] // Extracted emotions
    let responseTime: TimeInterval // How long they spent
    
    init(promptId: String, response: String, mood: Int, timestamp: Date = Date(), dayId: String, conversationLength: Int, engagementLevel: EngagementLevel, keyEmotions: [String], responseTime: TimeInterval) {
        self.id = UUID().uuidString
        self.promptId = promptId
        self.response = response
        self.mood = mood
        self.timestamp = timestamp
        self.dayId = dayId
        self.conversationLength = conversationLength
        self.engagementLevel = engagementLevel
        self.keyEmotions = keyEmotions
        self.responseTime = responseTime
    }
    
    enum EngagementLevel: String, Codable, CaseIterable {
        case minimal = "minimal"     // Quick response
        case engaged = "engaged"     // Thoughtful response
        case deep = "deep"          // Detailed, reflective
        
        var displayName: String {
            switch self {
            case .minimal: return "Minimal"
            case .engaged: return "Engaged"
            case .deep: return "Deep"
            }
        }
        
        var description: String {
            switch self {
            case .minimal: return "Quick, brief response"
            case .engaged: return "Thoughtful, meaningful response"
            case .deep: return "Detailed, reflective response"
            }
        }
        
        var color: String {
            switch self {
            case .minimal: return "gray"
            case .engaged: return "blue"
            case .deep: return "green"
            }
        }
    }
    
    // Computed properties for analysis
    var wordCount: Int {
        response.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
    }
    
    var emotionalWordCount: Int {
        keyEmotions.count
    }
    
    var responseLength: ResponseLength {
        switch wordCount {
        case 0..<50: return .short
        case 50..<150: return .medium
        default: return .long
        }
    }
    
    var isPositiveMood: Bool {
        mood >= 6
    }
    
    var isNegativeMood: Bool {
        mood <= 4
    }
    
    var moodCategory: MoodCategory {
        switch mood {
        case 1...3: return .low
        case 4...6: return .neutral
        case 7...10: return .high
        default: return .neutral
        }
    }
}

enum ResponseLength: String, CaseIterable, Codable {
    case short = "short"     // <50 words
    case medium = "medium"   // 50-150 words
    case long = "long"       // >150 words
    
    var displayName: String {
        switch self {
        case .short: return "Short"
        case .medium: return "Medium"
        case .long: return "Long"
        }
    }
    
    var description: String {
        switch self {
        case .short: return "Brief response (< 50 words)"
        case .medium: return "Moderate response (50-150 words)"
        case .long: return "Detailed response (> 150 words)"
        }
    }
}

enum MoodCategory: String, CaseIterable, Codable {
    case low = "low"         // 1-3
    case neutral = "neutral" // 4-6
    case high = "high"       // 7-10
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .neutral: return "Neutral"
        case .high: return "High"
        }
    }
    
    var emoji: String {
        switch self {
        case .low: return "😔"
        case .neutral: return "😐"
        case .high: return "😊"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "red"
        case .neutral: return "yellow"
        case .high: return "green"
        }
    }
}

// Extension for mood scale display
extension UserResponse {
    static let moodEmojis: [Int: String] = [
        1: "😢", 2: "😔", 3: "😕", 4: "😐", 5: "🙂",
        6: "😊", 7: "😄", 8: "😁", 9: "🤗", 10: "🥳"
    ]
    
    var moodEmoji: String {
        Self.moodEmojis[mood] ?? "😐"
    }
    
    var moodDescription: String {
        switch mood {
        case 1: return "Very Low"
        case 2: return "Low"
        case 3: return "Somewhat Low"
        case 4: return "Below Average"
        case 5: return "Average"
        case 6: return "Above Average"
        case 7: return "Good"
        case 8: return "Very Good"
        case 9: return "Great"
        case 10: return "Excellent"
        default: return "Unknown"
        }
    }
}
