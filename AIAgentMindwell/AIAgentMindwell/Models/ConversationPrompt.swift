//
//  ConversationPrompt.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation
import Observation

@Observable
class ConversationPrompt: Codable, Identifiable {
    
    let id: String
    let question: String
    let category: PromptCategory
    let timeOfDay: TimeContext
    let conversationStyle: ConversationStyle
    let followUpTriggers: [String] // Keywords that trigger follow-ups
    let followUps: [String]
    let emotionalTone: EmotionalTone
    var effectivenessScore: Double = 1.0
    
    enum PromptCategory: String, CaseIterable, Codable {
        case openEnded = "open_ended"           // "How are you feeling?"
        case specific = "specific"              // "What's making you anxious?"
        case reflective = "reflective"          // "Looking back at today..."
        case gratitude = "gratitude"            // "What are you grateful for?"
        case coping = "coping"                  // "What helps when you feel this way?"
        case future = "future"                  // "What do you hope for tomorrow?"
        
        var displayName: String {
            switch self {
            case .openEnded: return "Open-Ended"
            case .specific: return "Specific"
            case .reflective: return "Reflective"
            case .gratitude: return "Gratitude"
            case .coping: return "Coping"
            case .future: return "Future-Focused"
            }
        }
    }
    
    enum ConversationStyle: String, CaseIterable, Codable {
        case casual = "casual"                  // "Hey, how's it going?"
        case gentle = "gentle"                  // "Take a moment... how are you feeling?"
        case direct = "direct"                  // "What emotions are you experiencing?"
        case supportive = "supportive"          // "I'm here with you. What's happening?"
        case curious = "curious"                // "I'm wondering... what's on your mind?"
        
        var displayName: String {
            switch self {
            case .casual: return "Casual"
            case .gentle: return "Gentle"
            case .direct: return "Direct"
            case .supportive: return "Supportive"
            case .curious: return "Curious"
            }
        }
    }
    
    enum EmotionalTone: String, CaseIterable, Codable {
        case neutral = "neutral"
        case warm = "warm"
        case energetic = "energetic"
        case calm = "calm"
        case empathetic = "empathetic"
        
        var displayName: String {
            switch self {
            case .neutral: return "Neutral"
            case .warm: return "Warm"
            case .energetic: return "Energetic"
            case .calm: return "Calm"
            case .empathetic: return "Empathetic"
            }
        }
    }
    
    init(id: String, question: String, category: PromptCategory, timeOfDay: TimeContext, 
         conversationStyle: ConversationStyle, followUpTriggers: [String], 
         followUps: [String], emotionalTone: EmotionalTone) {
        self.id = id
        self.question = question
        self.category = category
        self.timeOfDay = timeOfDay
        self.conversationStyle = conversationStyle
        self.followUpTriggers = followUpTriggers
        self.followUps = followUps
        self.emotionalTone = emotionalTone
    }
}

enum TimeContext: String, CaseIterable, Codable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    case night = "night"
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }
    
    static func current() -> TimeContext {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<22: return .evening
        default: return .night
        }
    }
}

// Extension for DateFormatter
extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
