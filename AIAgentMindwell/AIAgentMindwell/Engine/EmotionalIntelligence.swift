//
//  EmotionalIntelligence.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation

class EmotionalIntelligence {
    
    // MARK: - Enhanced Emotion Detection
    
    static func extractRichEmotions(from text: String) -> [String: Double] {
        let emotionMapping: [String: Double] = [
            // Anxiety family
            "anxious": 0.9, "worried": 0.8, "nervous": 0.7, "stressed": 0.9,
            "overwhelmed": 1.0, "panicked": 1.0, "fearful": 0.8,
            "tense": 0.6, "uneasy": 0.5, "restless": 0.6, "agitated": 0.7,
            
            // Sadness family  
            "sad": 0.8, "depressed": 1.0, "down": 0.6, "blue": 0.5,
            "devastated": 1.0, "heartbroken": 1.0, "empty": 0.8, "hopeless": 1.0,
            "melancholy": 0.7, "grief": 0.9, "sorrow": 0.8, "despondent": 0.9,
            "dejected": 0.7, "gloomy": 0.6, "miserable": 0.9,
            
            // Joy family
            "happy": 0.8, "excited": 0.9, "thrilled": 1.0, "ecstatic": 1.0,
            "delighted": 0.9, "cheerful": 0.7, "content": 0.6, "joyful": 0.9,
            "elated": 1.0, "euphoric": 1.0, "blissful": 0.9, "gleeful": 0.8,
            "upbeat": 0.7, "radiant": 0.8,
            
            // Anger family
            "angry": 0.8, "furious": 1.0, "mad": 0.7, "irritated": 0.6,
            "frustrated": 0.8, "rage": 1.0, "livid": 1.0, "irate": 0.9,
            "annoyed": 0.5, "aggravated": 0.7, "incensed": 0.9, "outraged": 1.0,
            "resentful": 0.8, "bitter": 0.7, "hostile": 0.8,
            
            // Fear family
            "scared": 0.8, "afraid": 0.7, "frightened": 0.8, "terrified": 1.0,
            "petrified": 1.0, "horrified": 0.9, "alarmed": 0.7, "startled": 0.5,
            "intimidated": 0.6, "apprehensive": 0.6, "dread": 0.9,
            
            // Love family
            "loved": 0.9, "cherished": 0.9, "adored": 1.0, "appreciated": 0.7,
            "valued": 0.6, "treasured": 0.8, "beloved": 0.9, "devoted": 0.8,
            "affectionate": 0.7, "tender": 0.6, "caring": 0.7,
            
            // Guilt/Shame family
            "guilty": 0.8, "ashamed": 0.9, "embarrassed": 0.7, "regretful": 0.8,
            "remorseful": 0.9, "mortified": 1.0, "humiliated": 0.9, "sheepish": 0.5,
            "contrite": 0.7, "repentant": 0.8,
            
            // Exhaustion family
            "tired": 0.6, "exhausted": 0.9, "drained": 0.8, "weary": 0.7,
            "fatigued": 0.8, "depleted": 0.9, "worn": 0.7, "spent": 0.8,
            "burned": 0.9, "wiped": 0.7,
            
            // Confusion family
            "confused": 0.6, "lost": 0.8, "uncertain": 0.6, "puzzled": 0.5,
            "bewildered": 0.7, "perplexed": 0.6, "baffled": 0.6, "unclear": 0.5,
            "mixed": 0.4, "torn": 0.7,
            
            // Peace family
            "calm": 0.6, "peaceful": 0.8, "serene": 0.9, "tranquil": 0.8,
            "relaxed": 0.7, "centered": 0.7, "balanced": 0.6, "grounded": 0.7,
            "zen": 0.8, "still": 0.6,
            
            // Gratitude family
            "grateful": 0.8, "thankful": 0.7, "blessed": 0.8, "appreciative": 0.7,
            "fortunate": 0.6, "lucky": 0.5, "indebted": 0.6,
            
            // Loneliness family
            "lonely": 0.8, "isolated": 0.9, "alone": 0.6, "disconnected": 0.8,
            "abandoned": 1.0, "forsaken": 0.9, "solitary": 0.6, "excluded": 0.7,
            
            // Hope family
            "hopeful": 0.7, "optimistic": 0.6, "positive": 0.5, "encouraged": 0.7,
            "inspired": 0.8, "motivated": 0.7, "determined": 0.6, "confident": 0.7,
            
            // Surprise family
            "surprised": 0.5, "shocked": 0.8, "amazed": 0.7, "astonished": 0.8,
            "stunned": 0.9, "flabbergasted": 0.8, "astounded": 0.8
        ]
        
        var detectedEmotions: [String: Double] = [:]
        let lowercaseText = text.lowercased()
        
        for (emotion, intensity) in emotionMapping {
            if lowercaseText.contains(emotion) {
                detectedEmotions[emotion] = intensity
            }
        }
        
        return detectedEmotions
    }
    
    // MARK: - Emotional Analysis
    
    static func analyzeEmotionalState(from emotions: [String: Double]) -> EmotionalState {
        guard !emotions.isEmpty else { return .neutral }
        
        let totalIntensity = emotions.values.reduce(0, +)
        let averageIntensity = totalIntensity / Double(emotions.count)
        
        // Categorize emotions
        let positiveEmotions = emotions.filter { isPositiveEmotion($0.key) }
        let negativeEmotions = emotions.filter { isNegativeEmotion($0.key) }
        let neutralEmotions = emotions.filter { isNeutralEmotion($0.key) }
        
        let positiveIntensity = positiveEmotions.values.reduce(0, +)
        let negativeIntensity = negativeEmotions.values.reduce(0, +)
        
        // Determine dominant emotional state
        if negativeIntensity > positiveIntensity * 1.5 {
            if averageIntensity >= 0.8 {
                return .highlyNegative
            } else {
                return .negative
            }
        } else if positiveIntensity > negativeIntensity * 1.5 {
            if averageIntensity >= 0.8 {
                return .highlyPositive
            } else {
                return .positive
            }
        } else if !emotions.isEmpty {
            return .mixed
        } else {
            return .neutral
        }
    }
    
    static func getEmotionalTrend(currentEmotions: [String: Double], previousEmotions: [String: Double]) -> EmotionalTrend {
        let currentState = analyzeEmotionalState(from: currentEmotions)
        let previousState = analyzeEmotionalState(from: previousEmotions)
        
        let currentScore = getEmotionalScore(from: currentEmotions)
        let previousScore = getEmotionalScore(from: previousEmotions)
        
        if currentScore > previousScore + 0.2 {
            return .improving
        } else if currentScore < previousScore - 0.2 {
            return .declining
        } else {
            return .stable
        }
    }
    
    static func detectCrisisIndicators(from text: String, mood: Int) -> CrisisLevel {
        let crisisKeywords = [
            "hopeless", "worthless", "better off dead", "can't go on",
            "ending it all", "hurt myself", "suicide", "kill myself",
            "no point", "give up", "end it", "not worth living",
            "want to die", "hate myself", "can't take it", "too much pain"
        ]
        
        let lowercaseText = text.lowercased()
        let hasCrisisLanguage = crisisKeywords.contains { lowercaseText.contains($0) }
        let hasExtremeMood = mood <= 1
        
        if hasCrisisLanguage && hasExtremeMood {
            return .high
        } else if hasCrisisLanguage || hasExtremeMood {
            return .moderate
        } else if mood <= 2 {
            return .low
        } else {
            return .none
        }
    }
    
    static func generateEmpatheticResponse(for emotions: [String: Double], mood: Int) -> String? {
        let dominantEmotion = emotions.max(by: { $0.value < $1.value })
        
        guard let emotion = dominantEmotion else { return nil }
        
        switch emotion.key {
        case let e where isAnxietyEmotion(e):
            return generateAnxietyResponse(intensity: emotion.value)
        case let e where isSadnessEmotion(e):
            return generateSadnessResponse(intensity: emotion.value)
        case let e where isJoyEmotion(e):
            return generateJoyResponse(intensity: emotion.value)
        case let e where isAngerEmotion(e):
            return generateAngerResponse(intensity: emotion.value)
        case let e where isFearEmotion(e):
            return generateFearResponse(intensity: emotion.value)
        case let e where isExhaustionEmotion(e):
            return generateExhaustionResponse(intensity: emotion.value)
        default:
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    static func isPositiveEmotion(_ emotion: String) -> Bool {
        let positiveEmotions = ["happy", "excited", "thrilled", "ecstatic", "delighted", "cheerful", "content", "joyful", "elated", "euphoric", "blissful", "gleeful", "upbeat", "optimistic", "radiant", "loved", "cherished", "adored", "appreciated", "valued", "treasured", "beloved", "devoted", "affectionate", "tender", "caring", "calm", "peaceful", "serene", "tranquil", "relaxed", "centered", "balanced", "grounded", "zen", "still", "grateful", "thankful", "blessed", "appreciative", "fortunate", "lucky", "hopeful", "positive", "encouraged", "inspired", "motivated", "determined", "confident"]
        return positiveEmotions.contains(emotion)
    }
    
    static func isNegativeEmotion(_ emotion: String) -> Bool {
        let negativeEmotions = ["anxious", "worried", "nervous", "stressed", "overwhelmed", "panicked", "terrified", "fearful", "tense", "uneasy", "restless", "agitated", "sad", "depressed", "down", "blue", "devastated", "heartbroken", "empty", "hopeless", "melancholy", "grief", "sorrow", "despondent", "dejected", "gloomy", "miserable", "angry", "furious", "mad", "irritated", "frustrated", "rage", "livid", "irate", "annoyed", "aggravated", "incensed", "outraged", "resentful", "bitter", "hostile", "scared", "afraid", "frightened", "petrified", "horrified", "alarmed", "intimidated", "apprehensive", "dread", "guilty", "ashamed", "embarrassed", "regretful", "remorseful", "mortified", "humiliated", "tired", "exhausted", "drained", "weary", "fatigued", "depleted", "worn", "spent", "burned", "wiped", "lonely", "isolated", "alone", "disconnected", "abandoned", "forsaken", "excluded"]
        return negativeEmotions.contains(emotion)
    }
    
    private static func isNeutralEmotion(_ emotion: String) -> Bool {
        let neutralEmotions = ["confused", "lost", "uncertain", "puzzled", "bewildered", "perplexed", "baffled", "unclear", "mixed", "torn", "surprised", "shocked", "amazed", "astonished", "stunned", "flabbergasted", "astounded"]
        return neutralEmotions.contains(emotion)
    }
    
    private static func isAnxietyEmotion(_ emotion: String) -> Bool {
        let anxietyEmotions = ["anxious", "worried", "nervous", "stressed", "overwhelmed", "panicked", "terrified", "fearful", "tense", "uneasy", "restless", "agitated"]
        return anxietyEmotions.contains(emotion)
    }
    
    private static func isSadnessEmotion(_ emotion: String) -> Bool {
        let sadnessEmotions = ["sad", "depressed", "down", "blue", "devastated", "heartbroken", "empty", "hopeless", "melancholy", "grief", "sorrow", "despondent", "dejected", "gloomy", "miserable"]
        return sadnessEmotions.contains(emotion)
    }
    
    private static func isJoyEmotion(_ emotion: String) -> Bool {
        let joyEmotions = ["happy", "excited", "thrilled", "ecstatic", "delighted", "cheerful", "content", "joyful", "elated", "euphoric", "blissful", "gleeful", "upbeat", "optimistic", "radiant"]
        return joyEmotions.contains(emotion)
    }
    
    private static func isAngerEmotion(_ emotion: String) -> Bool {
        let angerEmotions = ["angry", "furious", "mad", "irritated", "frustrated", "rage", "livid", "irate", "annoyed", "aggravated", "incensed", "outraged", "resentful", "bitter", "hostile"]
        return angerEmotions.contains(emotion)
    }
    
    private static func isFearEmotion(_ emotion: String) -> Bool {
        let fearEmotions = ["scared", "afraid", "frightened", "terrified", "petrified", "horrified", "alarmed", "startled", "intimidated", "apprehensive", "dread"]
        return fearEmotions.contains(emotion)
    }
    
    private static func isExhaustionEmotion(_ emotion: String) -> Bool {
        let exhaustionEmotions = ["tired", "exhausted", "drained", "weary", "fatigued", "depleted", "worn", "spent", "burned", "wiped"]
        return exhaustionEmotions.contains(emotion)
    }
    
    private static func getEmotionalScore(from emotions: [String: Double]) -> Double {
        guard !emotions.isEmpty else { return 0.0 }
        
        var score = 0.0
        for (emotion, intensity) in emotions {
            if isPositiveEmotion(emotion) {
                score += intensity
            } else if isNegativeEmotion(emotion) {
                score -= intensity
            }
        }
        
        return score / Double(emotions.count)
    }
    
    // MARK: - Response Generators
    
    private static func generateAnxietyResponse(intensity: Double) -> String {
        if intensity >= 0.8 {
            let responses = [
                "I can feel the intensity of that anxiety. What's your heart most worried about right now?",
                "That level of worry sounds overwhelming. What thoughts are racing through your mind?",
                "I hear how anxious you're feeling. What would help you feel more grounded in this moment?"
            ]
            return responses.randomElement() ?? responses[0]
        } else {
            let responses = [
                "I notice some anxiety in your words. What's creating that nervous energy?",
                "That worry makes sense. What's behind those anxious feelings?",
                "I can hear that unease. What's your mind trying to tell you?"
            ]
            return responses.randomElement() ?? responses[0]
        }
    }
    
    private static func generateSadnessResponse(intensity: Double) -> String {
        if intensity >= 0.8 {
            let responses = [
                "I'm so sorry you're carrying this heavy sadness. What's weighing most on your heart?",
                "That depth of sadness is real and valid. What does your heart need right now?",
                "I can feel how much pain you're in. What would feel most supportive in this moment?"
            ]
            return responses.randomElement() ?? responses[0]
        } else {
            let responses = [
                "I hear that sadness in your words. What's sitting heavy with you today?",
                "That melancholy feeling is understandable. What's behind those sad feelings?",
                "I notice you're feeling down. What's your heart trying to process?"
            ]
            return responses.randomElement() ?? responses[0]
        }
    }
    
    private static func generateJoyResponse(intensity: Double) -> String {
        if intensity >= 0.8 {
            let responses = [
                "Your joy is absolutely radiant! What's creating this beautiful happiness?",
                "I can feel your excitement through your words! What's bringing you such delight?",
                "This level of happiness is wonderful to witness! What's making your heart so full?"
            ]
            return responses.randomElement() ?? responses[0]
        } else {
            let responses = [
                "I love hearing that happiness in your voice! What's bringing you joy today?",
                "That contentment is beautiful. What's creating those good feelings?",
                "Your positive energy is lovely. What's been the highlight of your day?"
            ]
            return responses.randomElement() ?? responses[0]
        }
    }
    
    private static func generateAngerResponse(intensity: Double) -> String {
        if intensity >= 0.8 {
            let responses = [
                "I can feel the intensity of that anger. What's triggered such strong feelings?",
                "That rage is powerful. What injustice or frustration is fueling this?",
                "Your anger is valid and important. What needs to be heard or changed?"
            ]
            return responses.randomElement() ?? responses[0]
        } else {
            let responses = [
                "I hear that frustration. What's been irritating or disappointing you?",
                "That annoyance makes sense. What's been rubbing you the wrong way?",
                "I can sense your irritation. What's been challenging your patience?"
            ]
            return responses.randomElement() ?? responses[0]
        }
    }
    
    private static func generateFearResponse(intensity: Double) -> String {
        if intensity >= 0.8 {
            let responses = [
                "That fear sounds really intense. What's creating such strong alarm?",
                "I can feel how scared you are. What's making you feel so unsafe?",
                "That terror is overwhelming. What's threatening your sense of security?"
            ]
            return responses.randomElement() ?? responses[0]
        } else {
            let responses = [
                "I hear that nervousness. What's making you feel uneasy?",
                "That apprehension is understandable. What's creating those worried feelings?",
                "I can sense your concern. What's making you feel uncertain?"
            ]
            return responses.randomElement() ?? responses[0]
        }
    }
    
    private static func generateExhaustionResponse(intensity: Double) -> String {
        if intensity >= 0.8 {
            let responses = [
                "That exhaustion sounds complete. What's been draining all your energy?",
                "I can feel how depleted you are. What's been taking so much out of you?",
                "That level of tiredness is profound. What does your body and soul need most?"
            ]
            return responses.randomElement() ?? responses[0]
        } else {
            let responses = [
                "I hear that weariness. What's been tiring you out lately?",
                "That fatigue is real. What's been demanding so much of your energy?",
                "I can sense you're worn down. What would help restore you?"
            ]
            return responses.randomElement() ?? responses[0]
        }
    }
}

// MARK: - Supporting Types

enum EmotionalState: String, CaseIterable {
    case highlyPositive = "highly_positive"
    case positive = "positive"
    case neutral = "neutral"
    case mixed = "mixed"
    case negative = "negative"
    case highlyNegative = "highly_negative"
    
    var displayName: String {
        switch self {
        case .highlyPositive: return "Highly Positive"
        case .positive: return "Positive"
        case .neutral: return "Neutral"
        case .mixed: return "Mixed"
        case .negative: return "Negative"
        case .highlyNegative: return "Highly Negative"
        }
    }
    
    var emoji: String {
        switch self {
        case .highlyPositive: return "🌟"
        case .positive: return "😊"
        case .neutral: return "😐"
        case .mixed: return "🤔"
        case .negative: return "😔"
        case .highlyNegative: return "💔"
        }
    }
}

enum EmotionalTrend: String, CaseIterable {
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
}

enum CrisisLevel: String, CaseIterable {
    case none = "none"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        }
    }
    
    var requiresIntervention: Bool {
        switch self {
        case .none, .low: return false
        case .moderate, .high: return true
        }
    }
}
