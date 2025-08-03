//
//  ConversationMessage.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation

struct ConversationMessage: Identifiable, Codable {
    var id = UUID()
    let content: String
    let isFromAgent: Bool
    let timestamp: Date
    let messageType: MessageType
    var mood: Int? // Only for user responses
    var engagementLevel: UserResponse.EngagementLevel?
    
    enum MessageType: String, CaseIterable, Codable {
        case question = "question"
        case response = "response"
        case moodRequest = "mood_request"
        case followUp = "follow_up"
        case greeting = "greeting"
        case closing = "closing"
        
        var displayName: String {
            switch self {
            case .question: return "Question"
            case .response: return "Response"
            case .moodRequest: return "Mood Check"
            case .followUp: return "Follow-up"
            case .greeting: return "Greeting"
            case .closing: return "Closing"
            }
        }
    }
    
    init(content: String, isFromAgent: Bool, messageType: MessageType, mood: Int? = nil) {
        self.content = content
        self.isFromAgent = isFromAgent
        self.messageType = messageType
        self.timestamp = Date()
        self.mood = mood
    }
    
    // Helper initializers
    static func agentMessage(_ content: String, type: MessageType = .question) -> ConversationMessage {
        ConversationMessage(content: content, isFromAgent: true, messageType: type)
    }
    
    static func userMessage(_ content: String, mood: Int? = nil) -> ConversationMessage {
        ConversationMessage(content: content, isFromAgent: false, messageType: .response, mood: mood)
    }
    
    static func moodRequest() -> ConversationMessage {
        ConversationMessage(
            content: "How would you rate your current mood on a scale of 1-10?",
            isFromAgent: true,
            messageType: .moodRequest
        )
    }
    
    // Computed properties
    var isQuestion: Bool {
        isFromAgent && (messageType == .question || messageType == .followUp)
    }
    
    var isMoodRequest: Bool {
        messageType == .moodRequest
    }
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - Conversation Session
struct ConversationSession: Identifiable, Codable {
    var id = UUID()
    let startTime: Date
    var endTime: Date?
    var messages: [ConversationMessage]
    var initialPrompt: ConversationPrompt?
    var userMoodRating: Int?
    var sessionSummary: String?
    
    init(initialPrompt: ConversationPrompt? = nil) {
        self.startTime = Date()
        self.messages = []
        self.initialPrompt = initialPrompt
        
        // Add greeting message
        if let prompt = initialPrompt {
            self.messages.append(.agentMessage(prompt.question, type: .greeting))
        }
    }
    
    mutating func addMessage(_ message: ConversationMessage) {
        messages.append(message)
    }
    
    mutating func endSession(summary: String? = nil) {
        endTime = Date()
        sessionSummary = summary
    }
    
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    var isActive: Bool {
        endTime == nil
    }
    
    var userMessages: [ConversationMessage] {
        messages.filter { !$0.isFromAgent }
    }
    
    var agentMessages: [ConversationMessage] {
        messages.filter { $0.isFromAgent }
    }
}
