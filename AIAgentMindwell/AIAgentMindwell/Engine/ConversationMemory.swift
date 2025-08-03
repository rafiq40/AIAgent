//
//  ConversationMemory.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation

class ConversationMemory: ObservableObject {
    private var sessionMemory: [String: Any] = [:]
    private var conversationHistory: [ConversationExchange] = []
    private var emotionalHistory: [EmotionalSnapshot] = []
    private var topicHistory: Set<String> = []
    private var questionHistory: [String] = []
    
    // MARK: - Memory Management
    
    func remember(key: String, value: Any) {
        sessionMemory[key] = value
    }
    
    func recall(key: String) -> Any? {
        return sessionMemory[key]
    }
    
    func forgetKey(_ key: String) {
        sessionMemory.removeValue(forKey: key)
    }
    
    func clearSessionMemory() {
        sessionMemory.removeAll()
        conversationHistory.removeAll()
        emotionalHistory.removeAll()
        topicHistory.removeAll()
        questionHistory.removeAll()
    }
    
    // MARK: - Conversation Tracking
    
    func recordExchange(userMessage: String, agentResponse: String, emotions: [String: Double], mood: Int) {
        let exchange = ConversationExchange(
            userMessage: userMessage,
            agentResponse: agentResponse,
            timestamp: Date(),
            emotions: emotions,
            mood: mood
        )
        
        conversationHistory.append(exchange)
        
        // Record emotional snapshot
        let emotionalSnapshot = EmotionalSnapshot(
            emotions: emotions,
            mood: mood,
            timestamp: Date(),
            context: extractContext(from: userMessage)
        )
        emotionalHistory.append(emotionalSnapshot)
        
        // Extract and remember topics
        let topics = extractTopics(from: userMessage)
        topicHistory.formUnion(topics)
        
        // Remember this exchange for pattern analysis
        analyzeAndRememberPatterns(exchange)
    }
    
    func recordQuestion(_ question: String) {
        questionHistory.append(question)
        
        // Keep only recent questions to avoid memory bloat
        if questionHistory.count > 20 {
            questionHistory.removeFirst()
        }
    }
    
    // MARK: - Topic Analysis
    
    func hasDiscussed(topic: String) -> Bool {
        let lowercaseTopic = topic.lowercased()
        return topicHistory.contains { $0.lowercased().contains(lowercaseTopic) } ||
               conversationHistory.contains { exchange in
                   exchange.userMessage.lowercased().contains(lowercaseTopic) ||
                   exchange.agentResponse.lowercased().contains(lowercaseTopic)
               }
    }
    
    func getDiscussedTopics() -> [String] {
        return Array(topicHistory)
    }
    
    func hasAskedSimilarQuestion(_ question: String) -> Bool {
        let questionWords = Set(question.lowercased().components(separatedBy: .whitespacesAndNewlines))
        
        return questionHistory.contains { previousQuestion in
            let previousWords = Set(previousQuestion.lowercased().components(separatedBy: .whitespacesAndNewlines))
            let intersection = questionWords.intersection(previousWords)
            return intersection.count >= min(3, questionWords.count / 2) // At least half the words match
        }
    }
    
    // MARK: - Emotional Pattern Analysis
    
    func getEmotionalPattern() -> EmotionalPattern {
        guard !emotionalHistory.isEmpty else { return .stable }
        
        let recentSnapshots = Array(emotionalHistory.suffix(5))
        let moods = recentSnapshots.map { $0.mood }
        
        if moods.count < 2 {
            return .stable
        }
        
        let firstMood = moods.first!
        let lastMood = moods.last!
        let moodChange = lastMood - firstMood
        
        // Calculate trend
        var improvingCount = 0
        var decliningCount = 0
        
        for i in 1..<moods.count {
            if moods[i] > moods[i-1] {
                improvingCount += 1
            } else if moods[i] < moods[i-1] {
                decliningCount += 1
            }
        }
        
        if improvingCount > decliningCount && moodChange > 1 {
            return .improving
        } else if decliningCount > improvingCount && moodChange < -1 {
            return .declining
        } else if hasVolatileEmotions(recentSnapshots) {
            return .volatile
        } else {
            return .stable
        }
    }
    
    func getDominantEmotions() -> [String] {
        guard !emotionalHistory.isEmpty else { return [] }
        
        var emotionCounts: [String: Int] = [:]
        
        for snapshot in emotionalHistory {
            for emotion in snapshot.emotions.keys {
                emotionCounts[emotion, default: 0] += 1
            }
        }
        
        return emotionCounts.sorted { $0.value > $1.value }
                          .prefix(5)
                          .map { $0.key }
    }
    
    func getEmotionalTrend() -> EmotionalTrend {
        guard emotionalHistory.count >= 2 else { return .stable }
        
        let recent = Array(emotionalHistory.suffix(3))
        let earlier = Array(emotionalHistory.prefix(max(1, emotionalHistory.count - 3)))
        
        let recentScore = calculateEmotionalScore(recent)
        let earlierScore = calculateEmotionalScore(earlier)
        
        if recentScore > earlierScore + 0.3 {
            return .improving
        } else if recentScore < earlierScore - 0.3 {
            return .declining
        } else {
            return .stable
        }
    }
    
    // MARK: - Conversation Insights
    
    func getConversationInsights() -> ConversationInsights {
        let totalExchanges = conversationHistory.count
        let averageMood = conversationHistory.isEmpty ? 5.0 : 
                         Double(conversationHistory.map { $0.mood }.reduce(0, +)) / Double(totalExchanges)
        
        let wordCounts = conversationHistory.map { $0.userMessage.components(separatedBy: .whitespacesAndNewlines).count }
        let averageWordCount = wordCounts.isEmpty ? 0.0 : Double(wordCounts.reduce(0, +)) / Double(wordCounts.count)
        
        let engagementLevel = determineEngagementLevel(averageWordCount: averageWordCount, 
                                                     emotionCount: getDominantEmotions().count)
        
        return ConversationInsights(
            totalExchanges: totalExchanges,
            averageMood: averageMood,
            averageWordCount: averageWordCount,
            dominantEmotions: getDominantEmotions(),
            discussedTopics: getDiscussedTopics(),
            emotionalPattern: getEmotionalPattern(),
            engagementLevel: engagementLevel,
            conversationDuration: getConversationDuration()
        )
    }
    
    func shouldOfferDeepDive() -> Bool {
        guard conversationHistory.count >= 3 else { return false }
        
        let recentExchanges = Array(conversationHistory.suffix(3))
        let hasConsistentTopic = recentExchanges.allSatisfy { exchange in
            recentExchanges.first?.containsSimilarTopic(to: exchange) ?? false
        }
        
        let hasEmotionalDepth = recentExchanges.contains { !$0.emotions.isEmpty }
        
        return hasConsistentTopic && hasEmotionalDepth
    }
    
    func generateContextualPrompt() -> String? {
        guard !conversationHistory.isEmpty else { return nil }
        
        let recentExchange = conversationHistory.last!
        let emotionalPattern = getEmotionalPattern()
        let dominantEmotions = getDominantEmotions()
        
        // Generate prompts based on patterns
        switch emotionalPattern {
        case .improving:
            return "I can sense something shifting positively for you. What's creating that change?"
        case .declining:
            return "I notice this feels heavier than when we started. What's weighing on you most?"
        case .volatile:
            return "You're experiencing a lot of different emotions. What's behind all these feelings?"
        case .stable:
            if let dominantEmotion = dominantEmotions.first {
                return generateEmotionSpecificPrompt(for: dominantEmotion)
            }
        }
        
        return nil
    }
    
    // MARK: - Private Helper Methods
    
    private func extractTopics(from message: String) -> Set<String> {
        let topicKeywords = [
            "work", "job", "career", "boss", "colleague", "meeting", "project",
            "family", "parent", "child", "sibling", "spouse", "partner", "relationship",
            "friend", "friendship", "social", "people", "person",
            "health", "doctor", "medical", "therapy", "medication", "exercise",
            "money", "financial", "budget", "debt", "savings", "bills",
            "school", "education", "study", "exam", "grade", "teacher",
            "home", "house", "apartment", "living", "roommate", "neighbor",
            "hobby", "interest", "passion", "creative", "art", "music", "book",
            "travel", "vacation", "trip", "adventure", "explore",
            "future", "goal", "dream", "plan", "hope", "aspiration",
            "past", "memory", "childhood", "history", "experience",
            "stress", "anxiety", "depression", "worry", "fear", "panic",
            "happiness", "joy", "excitement", "celebration", "success", "achievement"
        ]
        
        let lowercaseMessage = message.lowercased()
        var topics: Set<String> = []
        
        for keyword in topicKeywords {
            if lowercaseMessage.contains(keyword) {
                topics.insert(keyword)
            }
        }
        
        return topics
    }
    
    private func extractContext(from message: String) -> String {
        // Extract key contextual information
        let words = message.components(separatedBy: .whitespacesAndNewlines)
        let contextWords = words.filter { word in
            word.count > 3 && !["that", "this", "with", "have", "been", "were", "they", "them", "their"].contains(word.lowercased())
        }
        
        return contextWords.prefix(5).joined(separator: " ")
    }
    
    private func analyzeAndRememberPatterns(_ exchange: ConversationExchange) {
        // Remember response patterns
        let responseLength = exchange.userMessage.components(separatedBy: .whitespacesAndNewlines).count
        remember(key: "last_response_length", value: responseLength)
        
        // Remember emotional patterns
        if !exchange.emotions.isEmpty {
            remember(key: "last_emotions", value: exchange.emotions)
        }
        
        // Remember mood patterns
        remember(key: "last_mood", value: exchange.mood)
        
        // Track conversation depth
        let currentDepth = (recall(key: "conversation_depth") as? Int) ?? 0
        remember(key: "conversation_depth", value: currentDepth + 1)
    }
    
    private func hasVolatileEmotions(_ snapshots: [EmotionalSnapshot]) -> Bool {
        guard snapshots.count >= 3 else { return false }
        
        let moodChanges = zip(snapshots.dropLast(), snapshots.dropFirst()).map { abs($0.mood - $1.mood) }
        let averageChange = Double(moodChanges.reduce(0, +)) / Double(moodChanges.count)
        
        return averageChange > 2.0 // Significant mood swings
    }
    
    private func calculateEmotionalScore(_ snapshots: [EmotionalSnapshot]) -> Double {
        guard !snapshots.isEmpty else { return 0.0 }
        
        var totalScore = 0.0
        var count = 0
        
        for snapshot in snapshots {
            for (emotion, intensity) in snapshot.emotions {
                if EmotionalIntelligence.isPositiveEmotion(emotion) {
                    totalScore += intensity
                } else if EmotionalIntelligence.isNegativeEmotion(emotion) {
                    totalScore -= intensity
                }
                count += 1
            }
        }
        
        return count > 0 ? totalScore / Double(count) : 0.0
    }
    
    private func determineEngagementLevel(averageWordCount: Double, emotionCount: Int) -> UserResponse.EngagementLevel {
        if averageWordCount > 100 && emotionCount > 3 {
            return .deep
        } else if averageWordCount > 30 && emotionCount > 1 {
            return .engaged
        } else {
            return .minimal
        }
    }
    
    private func getConversationDuration() -> TimeInterval {
        guard let firstExchange = conversationHistory.first,
              let lastExchange = conversationHistory.last else { return 0 }
        
        return lastExchange.timestamp.timeIntervalSince(firstExchange.timestamp)
    }
    
    private func generateEmotionSpecificPrompt(for emotion: String) -> String? {
        switch emotion {
        case "anxious", "worried", "nervous", "stressed":
            return "I've noticed anxiety coming up for you. What's your mind most concerned about?"
        case "sad", "depressed", "down", "blue":
            return "There's been sadness in our conversation. What's your heart processing right now?"
        case "happy", "excited", "joyful", "content":
            return "I love the joy I'm hearing from you. What's been bringing you this happiness?"
        case "angry", "frustrated", "irritated", "mad":
            return "I can sense some frustration. What's been challenging your patience?"
        case "tired", "exhausted", "drained", "weary":
            return "You've mentioned feeling tired. What's been taking so much of your energy?"
        case "lonely", "isolated", "alone", "disconnected":
            return "Loneliness has come up in our conversation. What would help you feel more connected?"
        default:
            return nil
        }
    }
}

// MARK: - Supporting Types

struct ConversationExchange {
    let userMessage: String
    let agentResponse: String
    let timestamp: Date
    let emotions: [String: Double]
    let mood: Int
    
    func containsSimilarTopic(to other: ConversationExchange) -> Bool {
        let thisWords = Set(userMessage.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let otherWords = Set(other.userMessage.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let intersection = thisWords.intersection(otherWords)
        
        return intersection.count >= 2 // At least 2 words in common
    }
}

struct EmotionalSnapshot {
    let emotions: [String: Double]
    let mood: Int
    let timestamp: Date
    let context: String
}

enum EmotionalPattern: String, CaseIterable {
    case improving = "improving"
    case declining = "declining"
    case stable = "stable"
    case volatile = "volatile"
    
    var displayName: String {
        switch self {
        case .improving: return "Improving"
        case .declining: return "Declining"
        case .stable: return "Stable"
        case .volatile: return "Volatile"
        }
    }
    
    var emoji: String {
        switch self {
        case .improving: return "📈"
        case .declining: return "📉"
        case .stable: return "➡️"
        case .volatile: return "🎢"
        }
    }
    
    var description: String {
        switch self {
        case .improving: return "Emotional state is getting better"
        case .declining: return "Emotional state is getting more difficult"
        case .stable: return "Emotional state is consistent"
        case .volatile: return "Emotional state is fluctuating significantly"
        }
    }
}

struct ConversationInsights {
    let totalExchanges: Int
    let averageMood: Double
    let averageWordCount: Double
    let dominantEmotions: [String]
    let discussedTopics: [String]
    let emotionalPattern: EmotionalPattern
    let engagementLevel: UserResponse.EngagementLevel
    let conversationDuration: TimeInterval
    
    var formattedDuration: String {
        let minutes = Int(conversationDuration) / 60
        let seconds = Int(conversationDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var moodEmoji: String {
        UserResponse.moodEmojis[Int(averageMood.rounded())] ?? "😐"
    }
}
