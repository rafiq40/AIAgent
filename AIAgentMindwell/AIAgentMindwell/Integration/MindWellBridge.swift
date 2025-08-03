//
//  MindWellBridge.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation
import CoreData
import SwiftUI

@Observable
class MindWellBridge {
    static let shared = MindWellBridge()
    
    private let persistenceController = PersistenceController.shared
    private let conversationLearner = ConversationLearner()
    
    // MARK: - Response Management
    
    func saveResponse(_ response: UserResponse) {
        let context = persistenceController.container.viewContext
        
        // Create Core Data entity
        let responseEntity = UserResponseEntity(context: context)
        responseEntity.promptId = response.promptId
        responseEntity.response = response.response
        responseEntity.mood = Int16(response.mood)
        responseEntity.timestamp = response.timestamp
        responseEntity.dayId = response.dayId
        responseEntity.conversationLength = Int16(response.conversationLength)
        responseEntity.engagementLevel = response.engagementLevel.rawValue
        responseEntity.keyEmotions = response.keyEmotions as NSObject
        responseEntity.responseTime = response.responseTime
        
        // Save to Core Data
        do {
            try context.save()
            
            // Update learning system
            conversationLearner.analyzeResponse(response)
            
            // Update prompt effectiveness if available
            updatePromptEffectiveness(promptId: response.promptId, response: response)
            
        } catch {
            print("Error saving response: \(error)")
        }
    }
    
    func getResponses(for dayId: String) -> [UserResponse] {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<UserResponseEntity> = UserResponseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "dayId == %@", dayId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserResponseEntity.timestamp, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard let promptId = entity.promptId,
                      let response = entity.response,
                      let timestamp = entity.timestamp,
                      let dayId = entity.dayId,
                      let engagementLevelString = entity.engagementLevel,
                      let engagementLevel = UserResponse.EngagementLevel(rawValue: engagementLevelString),
                      let keyEmotions = entity.keyEmotions as? [String] else {
                    return nil
                }
                
                return UserResponse(
                    promptId: promptId,
                    response: response,
                    mood: Int(entity.mood),
                    timestamp: timestamp,
                    dayId: dayId,
                    conversationLength: Int(entity.conversationLength),
                    engagementLevel: engagementLevel,
                    keyEmotions: keyEmotions,
                    responseTime: entity.responseTime
                )
            }
        } catch {
            print("Error fetching responses: \(error)")
            return []
        }
    }
    
    func getRecentResponses(limit: Int = 10) -> [UserResponse] {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<UserResponseEntity> = UserResponseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserResponseEntity.timestamp, ascending: false)]
        request.fetchLimit = limit
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard let promptId = entity.promptId,
                      let response = entity.response,
                      let timestamp = entity.timestamp,
                      let dayId = entity.dayId,
                      let engagementLevelString = entity.engagementLevel,
                      let engagementLevel = UserResponse.EngagementLevel(rawValue: engagementLevelString),
                      let keyEmotions = entity.keyEmotions as? [String] else {
                    return nil
                }
                
                return UserResponse(
                    promptId: promptId,
                    response: response,
                    mood: Int(entity.mood),
                    timestamp: timestamp,
                    dayId: dayId,
                    conversationLength: Int(entity.conversationLength),
                    engagementLevel: engagementLevel,
                    keyEmotions: keyEmotions,
                    responseTime: entity.responseTime
                )
            }
        } catch {
            print("Error fetching recent responses: \(error)")
            return []
        }
    }
    
    // MARK: - Conversation Management
    
    func saveConversationSummary(_ summary: ConversationSummary) {
        // In a full implementation, this would save conversation summaries
        // For now, we'll store the key information in UserDefaults
        let key = "conversation_summary_\(summary.dayId)"
        if let data = try? JSONEncoder().encode(summary) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func getConversationSummary(for dayId: String) -> ConversationSummary? {
        let key = "conversation_summary_\(dayId)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let summary = try? JSONDecoder().decode(ConversationSummary.self, from: data) else {
            return nil
        }
        return summary
    }
    
    // MARK: - Analytics & Insights
    
    func getMoodTrends(days: Int = 30) -> [MoodDataPoint] {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<UserResponseEntity> = UserResponseEntity.fetchRequest()
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserResponseEntity.timestamp, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            
            // Group by day and calculate average mood
            var moodByDay: [String: [Int]] = [:]
            
            for entity in entities {
                guard let timestamp = entity.timestamp else { continue }
                let dayId = DateFormatter.dayFormatter.string(from: timestamp)
                moodByDay[dayId, default: []].append(Int(entity.mood))
            }
            
            return moodByDay.compactMap { (dayId, moods) in
                guard let date = DateFormatter.dayFormatter.date(from: dayId) else { return nil }
                let averageMood = Double(moods.reduce(0, +)) / Double(moods.count)
                return MoodDataPoint(date: date, mood: averageMood, responseCount: moods.count)
            }.sorted { $0.date < $1.date }
            
        } catch {
            print("Error fetching mood trends: \(error)")
            return []
        }
    }
    
    func getEmotionalInsights(days: Int = 30) -> EmotionalInsights {
        let responses = getRecentResponses(limit: days * 3) // Approximate
        
        var emotionFrequency: [String: Int] = [:]
        var moodDistribution: [Int: Int] = [:]
        var engagementLevels: [UserResponse.EngagementLevel: Int] = [:]
        
        for response in responses {
            // Count emotions
            for emotion in response.keyEmotions {
                emotionFrequency[emotion, default: 0] += 1
            }
            
            // Count mood distribution
            moodDistribution[response.mood, default: 0] += 1
            
            // Count engagement levels
            engagementLevels[response.engagementLevel, default: 0] += 1
        }
        
        let topEmotions = emotionFrequency.sorted { $0.value > $1.value }.prefix(10).map { $0.key }
        let averageMood = responses.isEmpty ? 5.0 : Double(responses.map { $0.mood }.reduce(0, +)) / Double(responses.count)
        let mostCommonEngagement = engagementLevels.max { $0.value < $1.value }?.key ?? .minimal
        
        return EmotionalInsights(
            topEmotions: Array(topEmotions),
            averageMood: averageMood,
            moodDistribution: moodDistribution,
            mostCommonEngagement: mostCommonEngagement,
            totalResponses: responses.count,
            timeRange: days
        )
    }
    
    func getConversationStats() -> ConversationStats {
        let responses = getRecentResponses(limit: 100)
        
        let totalConversations = Set(responses.map { $0.dayId }).count
        let averageResponseLength = responses.isEmpty ? 0.0 : Double(responses.map { $0.wordCount }.reduce(0, +)) / Double(responses.count)
        let averageEngagementScore = calculateAverageEngagementScore(responses)
        let streakDays = calculateConversationStreak()
        
        return ConversationStats(
            totalConversations: totalConversations,
            averageResponseLength: averageResponseLength,
            averageEngagementScore: averageEngagementScore,
            streakDays: streakDays,
            lastConversationDate: responses.first?.timestamp
        )
    }
    
    // MARK: - Learning Integration
    
    func getLearningInsights() -> LearningInsights {
        return conversationLearner.getLearningInsights()
    }
    
    func getPersonalizedPrompt(for context: ConversationContext) -> ConversationPrompt? {
        return conversationLearner.getPersonalizedPrompt(for: context)
    }
    
    func getPersonalizedPrompts(for timeContext: TimeContext, count: Int = 3) -> [ConversationPrompt] {
        return conversationLearner.getPersonalizedPrompts(for: timeContext, count: count)
    }
    
    // MARK: - Data Export/Import
    
    func exportUserData() -> UserDataExport? {
        let responses = getRecentResponses(limit: 1000) // Get all responses
        let learningData = conversationLearner.exportUserPattern()
        
        guard let learningData = learningData else { return nil }
        
        return UserDataExport(
            responses: responses,
            learningData: learningData,
            exportDate: Date(),
            version: "1.0"
        )
    }
    
    func importUserData(_ exportData: UserDataExport) -> Bool {
        // Import learning data
        let learningSuccess = conversationLearner.importUserPattern(from: exportData.learningData)
        
        // Import responses (in a real implementation, you'd want to avoid duplicates)
        let context = persistenceController.container.viewContext
        
        for response in exportData.responses {
            let responseEntity = UserResponseEntity(context: context)
            responseEntity.promptId = response.promptId
            responseEntity.response = response.response
            responseEntity.mood = Int16(response.mood)
            responseEntity.timestamp = response.timestamp
            responseEntity.dayId = response.dayId
            responseEntity.conversationLength = Int16(response.conversationLength)
            responseEntity.engagementLevel = response.engagementLevel.rawValue
            responseEntity.keyEmotions = response.keyEmotions as NSObject
            responseEntity.responseTime = response.responseTime
        }
        
        do {
            try context.save()
            return learningSuccess
        } catch {
            print("Error importing user data: \(error)")
            return false
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func updatePromptEffectiveness(promptId: String, response: UserResponse) {
        // In a real implementation, this would update the effectiveness score
        // of prompts based on user engagement and response quality
        
        let effectivenessScore = calculatePromptEffectiveness(response: response)
        
        // Store effectiveness scores (simplified implementation)
        let key = "prompt_effectiveness_\(promptId)"
        let currentScore = UserDefaults.standard.double(forKey: key)
        let newScore = currentScore == 0 ? effectivenessScore : (currentScore + effectivenessScore) / 2.0
        UserDefaults.standard.set(newScore, forKey: key)
    }
    
    private func calculatePromptEffectiveness(response: UserResponse) -> Double {
        var score = 1.0
        
        // Engagement level factor
        switch response.engagementLevel {
        case .minimal: score += 0.0
        case .engaged: score += 0.3
        case .deep: score += 0.5
        }
        
        // Response length factor
        if response.wordCount > 50 {
            score += 0.2
        }
        
        // Emotional richness factor
        if response.keyEmotions.count > 2 {
            score += 0.2
        }
        
        // Response time factor (more time = more thoughtful)
        if response.responseTime > 30 {
            score += 0.1
        }
        
        return min(2.0, score) // Cap at 2.0
    }
    
    private func calculateAverageEngagementScore(_ responses: [UserResponse]) -> Double {
        guard !responses.isEmpty else { return 0.0 }
        
        let totalScore = responses.reduce(0.0) { total, response in
            switch response.engagementLevel {
            case .minimal: return total + 1.0
            case .engaged: return total + 2.0
            case .deep: return total + 3.0
            }
        }
        
        return totalScore / Double(responses.count)
    }
    
    private func calculateConversationStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var currentDate = today
        var streak = 0
        
        // Check each day going backwards
        for _ in 0..<365 { // Max 365 days
            let dayId = DateFormatter.dayFormatter.string(from: currentDate)
            let dayResponses = getResponses(for: dayId)
            
            if dayResponses.isEmpty {
                break
            } else {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            }
        }
        
        return streak
    }
}

// MARK: - Supporting Data Types

struct MoodDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let mood: Double
    let responseCount: Int
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct EmotionalInsights {
    let topEmotions: [String]
    let averageMood: Double
    let moodDistribution: [Int: Int]
    let mostCommonEngagement: UserResponse.EngagementLevel
    let totalResponses: Int
    let timeRange: Int
    
    var moodTrend: String {
        switch averageMood {
        case 0..<4: return "Generally Low"
        case 4..<6: return "Balanced"
        case 6..<8: return "Generally Positive"
        case 8...10: return "Very Positive"
        default: return "Unknown"
        }
    }
    
    var engagementTrend: String {
        switch mostCommonEngagement {
        case .minimal: return "Brief Check-ins"
        case .engaged: return "Thoughtful Reflection"
        case .deep: return "Deep Exploration"
        }
    }
}

struct ConversationStats {
    let totalConversations: Int
    let averageResponseLength: Double
    let averageEngagementScore: Double
    let streakDays: Int
    let lastConversationDate: Date?
    
    var engagementLevel: String {
        switch averageEngagementScore {
        case 0..<1.5: return "Low"
        case 1.5..<2.5: return "Moderate"
        case 2.5...3.0: return "High"
        default: return "Unknown"
        }
    }
    
    var responseStyle: String {
        switch averageResponseLength {
        case 0..<30: return "Brief"
        case 30..<100: return "Moderate"
        case 100...: return "Detailed"
        default: return "Unknown"
        }
    }
}

struct UserDataExport: Codable {
    let responses: [UserResponse]
    let learningData: Data
    let exportDate: Date
    let version: String
    
    var formattedExportDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: exportDate)
    }
}
