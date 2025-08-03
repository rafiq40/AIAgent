# Enhanced Smart Prompting MVP - Learning Conversation System

## Project Goal
Create a conversational floating button that learns from user responses to provide increasingly personalized emotional check-ins. System adapts its conversation style based on user patterns and preferences.

## Core Requirements

### iOS 17.6+ Native Features
- **SwiftUI 5.0** with @Observable
- **Swift 5.9** async/await patterns
- **NavigationStack** with proper state management
- **Sheet presentation detents**
- **SF Symbols 5.0**
- **UserDefaults** with property wrappers

### Project Structure
```
SmartPromptEngine/
├── Models/
│   ├── ConversationPrompt.swift
│   ├── UserResponse.swift
│   ├── UserPattern.swift
│   └── ConversationContext.swift
├── Engine/
│   ├── ConversationLearner.swift
│   ├── PromptSelector.swift
│   └── ResponseAnalyzer.swift
├── Views/
│   ├── FloatingPromptButton.swift
│   ├── ConversationView.swift
│   └── AdaptivePromptView.swift
├── Data/
│   ├── PromptDatabase.swift
│   └── conversations.json
└── Integration/
    └── MindWellBridge.swift
```

## Enhanced Data Models

### ConversationPrompt
```swift
@Observable
class ConversationPrompt {
    let id: String
    let category: PromptCategory
    let timeOfDay: TimeContext
    let conversationStyle: ConversationStyle
    let question: String
    let followUpTriggers: [String] // Keywords that trigger follow-ups
    let followUps: [String]
    let emotionalTone: EmotionalTone
    var effectivenessScore: Double = 1.0
    
    enum PromptCategory: String, CaseIterable {
        case openEnded = "open_ended"           // "How are you feeling?"
        case specific = "specific"              // "What's making you anxious?"
        case reflective = "reflective"          // "Looking back at today..."
        case gratitude = "gratitude"            // "What are you grateful for?"
        case coping = "coping"                  // "What helps when you feel this way?"
        case future = "future"                  // "What do you hope for tomorrow?"
    }
    
    enum ConversationStyle: String, CaseIterable {
        case casual = "casual"                  // "Hey, how's it going?"
        case gentle = "gentle"                  // "Take a moment... how are you feeling?"
        case direct = "direct"                  // "What emotions are you experiencing?"
        case supportive = "supportive"          // "I'm here with you. What's happening?"
        case curious = "curious"                // "I'm wondering... what's on your mind?"
    }
    
    enum EmotionalTone: String, CaseIterable {
        case neutral = "neutral"
        case warm = "warm"
        case energetic = "energetic"
        case calm = "calm"
        case empathetic = "empathetic"
    }
}
```

### UserPattern
```swift
@Observable
class UserPattern {
    var preferredStyle: ConversationStyle = .gentle
    var preferredTone: EmotionalTone = .warm
    var responseLength: ResponseLength = .medium
    var preferredCategories: [PromptCategory] = []
    var emotionalKeywords: [String: Int] = [:] // Word frequency
    var conversationDepth: ConversationDepth = .surface
    var timePreferences: [TimeContext: Double] = [:]
    var moodPatterns: [Int: [String]] = [:] // mood -> common words
    
    enum ResponseLength: String, CaseIterable {
        case short = "short"     // <50 words
        case medium = "medium"   // 50-150 words
        case long = "long"       // >150 words
    }
    
    enum ConversationDepth: String, CaseIterable {
        case surface = "surface"     // Basic emotions
        case moderate = "moderate"   // Some reflection
        case deep = "deep"          // Detailed analysis
    }
}
```

### UserResponse
```swift
struct UserResponse: Codable {
    let promptId: String
    let response: String
    let mood: Int
    let timestamp: Date
    let dayId: String
    let conversationLength: Int // Number of exchanges
    let engagementLevel: EngagementLevel
    let keyEmotions: [String] // Extracted emotions
    let responseTime: TimeInterval // How long they spent
    
    enum EngagementLevel: String, Codable, CaseIterable {
        case minimal = "minimal"     // Quick response
        case engaged = "engaged"     // Thoughtful response
        case deep = "deep"          // Detailed, reflective
    }
}
```

### ConversationContext
```swift
@Observable
class ConversationContext {
    let dayId: String
    var currentPrompt: ConversationPrompt?
    var conversationHistory: [ConversationExchange] = []
    var userMood: Int = 5
    var detectedEmotions: [String] = []
    var conversationFlow: ConversationFlow = .initial
    
    struct ConversationExchange {
        let prompt: String
        let response: String
        let timestamp: Date
    }
    
    enum ConversationFlow: String, CaseIterable {
        case initial = "initial"           // First question
        case followUp = "follow_up"        // Based on response
        case deepDive = "deep_dive"        // User wants to explore more
        case closing = "closing"           // Wrapping up
    }
}
```

## Learning Engine

### ConversationLearner
```swift
@Observable
class ConversationLearner {
    @AppStorage("user_patterns") private var userPatternsData: Data = Data()
    private var userPattern: UserPattern
    private let responseAnalyzer = ResponseAnalyzer()
    
    init() {
        if let decoded = try? JSONDecoder().decode(UserPattern.self, from: userPatternsData) {
            self.userPattern = decoded
        } else {
            self.userPattern = UserPattern()
        }
    }
    
    func analyzeResponse(_ response: UserResponse) {
        // 1. Analyze response length preference
        updateResponseLengthPreference(response)
        
        // 2. Extract emotional keywords
        extractAndUpdateEmotionalKeywords(response)
        
        // 3. Determine conversation style preference
        updateStylePreference(response)
        
        // 4. Update mood-word associations
        updateMoodPatterns(response)
        
        // 5. Save learned patterns
        saveUserPattern()
    }
    
    private func updateResponseLengthPreference(_ response: UserResponse) {
        let wordCount = response.response.components(separatedBy: .whitespacesAndNewlines).count
        
        let detectedLength: UserPattern.ResponseLength
        switch wordCount {
        case 0..<50: detectedLength = .short
        case 50..<150: detectedLength = .medium
        default: detectedLength = .long
        }
        
        // Gradually shift preference based on consistent patterns
        if response.engagementLevel == .engaged || response.engagementLevel == .deep {
            userPattern.responseLength = detectedLength
        }
    }
    
    private func extractAndUpdateEmotionalKeywords(_ response: UserResponse) {
        let emotionalWords = responseAnalyzer.extractEmotionalWords(from: response.response)
        
        for word in emotionalWords {
            userPattern.emotionalKeywords[word, default: 0] += 1
        }
        
        // Keep only top 50 most frequent emotional words
        if userPattern.emotionalKeywords.count > 50 {
            let sortedWords = userPattern.emotionalKeywords.sorted { $0.value > $1.value }
            userPattern.emotionalKeywords = Dictionary(sortedWords.prefix(50), uniquingKeysWith: { $1 })
        }
    }
    
    private func updateMoodPatterns(_ response: UserResponse) {
        let words = responseAnalyzer.extractKeyWords(from: response.response)
        userPattern.moodPatterns[response.mood, default: []].append(contentsOf: words)
        
        // Keep only recent patterns (last 20 entries per mood)
        for mood in userPattern.moodPatterns.keys {
            if let moodWords = userPattern.moodPatterns[mood], moodWords.count > 20 {
                userPattern.moodPatterns[mood] = Array(moodWords.suffix(20))
            }
        }
    }
    
    func getPersonalizedPrompt(for context: ConversationContext) -> ConversationPrompt? {
        let selector = PromptSelector(userPattern: userPattern)
        return selector.selectBestPrompt(for: context)
    }
    
    private func saveUserPattern() {
        if let encoded = try? JSONEncoder().encode(userPattern) {
            userPatternsData = encoded
        }
    }
}
```

### ResponseAnalyzer
```swift
class ResponseAnalyzer {
    private let emotionalWords: Set<String> = [
        // Positive emotions
        "happy", "joy", "excited", "grateful", "content", "peaceful", "calm", "loved",
        "confident", "hopeful", "optimistic", "energetic", "satisfied", "fulfilled",
        
        // Negative emotions  
        "sad", "anxious", "worried", "stressed", "overwhelmed", "frustrated", "angry",
        "lonely", "tired", "exhausted", "disappointed", "confused", "scared", "nervous",
        
        // Neutral/complex emotions
        "mixed", "uncertain", "curious", "thoughtful", "reflective", "nostalgic",
        "surprised", "relieved", "motivated", "determined"
    ]
    
    func extractEmotionalWords(from text: String) -> [String] {
        let words = text.lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespacesAndNewlines)
        
        return words.filter { emotionalWords.contains($0) }
    }
    
    func extractKeyWords(from text: String) -> [String] {
        let words = text.lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 } // Only meaningful words
        
        return Array(Set(words)) // Remove duplicates
    }
    
    func analyzeEngagementLevel(_ response: UserResponse) -> UserResponse.EngagementLevel {
        let wordCount = response.response.components(separatedBy: .whitespacesAndNewlines).count
        let emotionalWords = extractEmotionalWords(from: response.response).count
        
        if wordCount > 100 && emotionalWords > 3 {
            return .deep
        } else if wordCount > 30 && emotionalWords > 1 {
            return .engaged
        } else {
            return .minimal
        }
    }
}
```

## Expanded Prompt Database (80 Prompts)

### PromptDatabase
```swift
class PromptDatabase {
    static let allPrompts: [ConversationPrompt] = [
        // MORNING - Open Ended (10 prompts)
        ConversationPrompt(
            id: "m_open_1",
            category: .openEnded,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            question: "Good morning! How are you feeling as this new day begins?",
            followUpTriggers: ["tired", "anxious", "excited", "nervous"],
            followUps: ["What's contributing to that feeling?", "Tell me more about that."],
            emotionalTone: .warm
        ),
        
        // MORNING - Specific (8 prompts)
        ConversationPrompt(
            id: "m_specific_1",
            category: .specific,
            timeOfDay: .morning,
            conversationStyle: .curious,
            question: "What emotions are you noticing as you start today?",
            followUpTriggers: ["anxiety", "stress", "worry", "excitement"],
            followUps: ["Where do you feel that in your body?", "What's behind that emotion?"],
            emotionalTone: .calm
        ),
        
        // MORNING - Reflective (5 prompts)
        ConversationPrompt(
            id: "m_reflective_1",
            category: .reflective,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            question: "Looking at the day ahead, what hopes do you have?",
            followUpTriggers: ["hope", "worry", "uncertain", "excited"],
            followUps: ["What would make today feel meaningful?"],
            emotionalTone: .warm
        ),
        
        // MORNING - Future Focused (5 prompts)
        ConversationPrompt(
            id: "m_future_1",
            category: .future,
            timeOfDay: .morning,
            conversationStyle: .energetic,
            question: "What are you looking forward to today?",
            followUpTriggers: ["nothing", "work", "meeting", "time"],
            followUps: ["What's one small thing that could bring you joy today?"],
            emotionalTone: .energetic
        ),
        
        // AFTERNOON - Open Ended (8 prompts)
        ConversationPrompt(
            id: "a_open_1",
            category: .openEnded,
            timeOfDay: .afternoon,
            conversationStyle: .casual,
            question: "Hey! How has your day been unfolding?",
            followUpTriggers: ["busy", "stressful", "good", "hard"],
            followUps: ["What's been the highlight so far?", "What's been challenging?"],
            emotionalTone: .neutral
        ),
        
        // AFTERNOON - Specific (6 prompts)
        ConversationPrompt(
            id: "a_specific_1",
            category: .specific,
            timeOfDay: .afternoon,
            conversationStyle: .direct,
            question: "What's the strongest emotion you've felt today?",
            followUpTriggers: ["anger", "joy", "frustration", "contentment"],
            followUps: ["What triggered that feeling?", "How are you handling that emotion?"],
            emotionalTone: .neutral
        ),
        
        // AFTERNOON - Coping (6 prompts)
        ConversationPrompt(
            id: "a_coping_1",
            category: .coping,
            timeOfDay: .afternoon,
            conversationStyle: .supportive,
            question: "If you're feeling stressed right now, what usually helps?",
            followUpTriggers: ["stressed", "overwhelmed", "tired", "frustrated"],
            followUps: ["Have you tried that today?", "What's one thing you could do right now?"],
            emotionalTone: .empathetic
        ),
        
        // EVENING - Reflective (12 prompts)
        ConversationPrompt(
            id: "e_reflective_1",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            question: "As you look back on today, what stands out emotionally?",
            followUpTriggers: ["nothing", "everything", "work", "relationships"],
            followUps: ["What made that moment significant?", "How do you feel about that now?"],
            emotionalTone: .warm
        ),
        
        // EVENING - Gratitude (8 prompts)
        ConversationPrompt(
            id: "e_gratitude_1",
            category: .gratitude,
            timeOfDay: .evening,
            conversationStyle: .warm,
            question: "What's something from today that you feel grateful for?",
            followUpTriggers: ["nothing", "people", "moments", "small"],
            followUps: ["Tell me more about that.", "How did that impact your day?"],
            emotionalTone: .warm
        ),
        
        // EVENING - Processing (8 prompts)
        ConversationPrompt(
            id: "e_processing_1",
            category: .openEnded,
            timeOfDay: .evening,
            conversationStyle: .empathetic,
            question: "How are you feeling as the day comes to a close?",
            followUpTriggers: ["tired", "satisfied", "worried", "peaceful"],
            followUps: ["What do you need right now?", "How can you honor that feeling?"],
            emotionalTone: .empathetic
        )
        
        // Continue with more prompts to reach 80 total...
        // Each category should have variety in style, tone, and approach
    ]
    
    static func getPromptsForCategory(_ category: ConversationPrompt.PromptCategory, 
                                    timeOfDay: TimeContext) -> [ConversationPrompt] {
        return allPrompts.filter { 
            $0.category == category && $0.timeOfDay == timeOfDay 
        }
    }
}
```

## Enhanced UI with Learning Integration

### ConversationView
```swift
struct ConversationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var conversationContext = ConversationContext(dayId: DateFormatter.dayFormatter.string(from: Date()))
    @State private var userResponse = ""
    @State private var selectedMood: Int = 5
    @State private var conversationLearner = ConversationLearner()
    @State private var showingFollowUp = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let currentPrompt = conversationContext.currentPrompt {
                    // Adaptive prompt display
                    AdaptivePromptView(
                        prompt: currentPrompt,
                        userResponse: $userResponse,
                        selectedMood: $selectedMood,
                        isTextFieldFocused: _isTextFieldFocused
                    )
                    
                    // Conversation history
                    if !conversationContext.conversationHistory.isEmpty {
                        ConversationHistoryView(history: conversationContext.conversationHistory)
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        if showingFollowUp && !currentPrompt.followUps.isEmpty {
                            Button("Ask me more") {
                                generateFollowUp()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Button("Save") {
                            saveConversation()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(userResponse.isEmpty)
                    }
                }
            }
            .padding()
            .navigationTitle("Daily Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                loadPersonalizedPrompt()
            }
        }
    }
    
    private func loadPersonalizedPrompt() {
        conversationContext.currentPrompt = conversationLearner.getPersonalizedPrompt(for: conversationContext)
    }
    
    private func generateFollowUp() {
        guard let currentPrompt = conversationContext.currentPrompt else { return }
        
        // Check if response contains trigger words
        let triggerFound = currentPrompt.followUpTriggers.first { trigger in
            userResponse.lowercased().contains(trigger.lowercased())
        }
        
        if let _ = triggerFound, !currentPrompt.followUps.isEmpty {
            let followUpQuestion = currentPrompt.followUps.randomElement() ?? "Tell me more about that."
            
            // Add to conversation history
            conversationContext.conversationHistory.append(
                ConversationContext.ConversationExchange(
                    prompt: currentPrompt.question,
                    response: userResponse,
                    timestamp: Date()
                )
            )
            
            // Create follow-up prompt
            let followUpPrompt = ConversationPrompt(
                id: "followup_\(UUID().uuidString)",
                category: currentPrompt.category,
                timeOfDay: currentPrompt.timeOfDay,
                conversationStyle: currentPrompt.conversationStyle,
                question: followUpQuestion,
                followUpTriggers: [],
                followUps: [],
                emotionalTone: currentPrompt.emotionalTone
            )
            
            conversationContext.currentPrompt = followUpPrompt
            userResponse = ""
            conversationContext.conversationFlow = .followUp
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
    }
    
    private func saveConversation() {
        guard let currentPrompt = conversationContext.currentPrompt else { return }
        
        let response = UserResponse(
            promptId: currentPrompt.id,
            response: userResponse,
            mood: selectedMood,
            timestamp: Date(),
            dayId: conversationContext.dayId,
            conversationLength: conversationContext.conversationHistory.count + 1,
            engagementLevel: ResponseAnalyzer().analyzeEngagementLevel(
                UserResponse(promptId: "", response: userResponse, mood: selectedMood, 
                           timestamp: Date(), dayId: "", conversationLength: 1, 
                           engagementLevel: .minimal, keyEmotions: [], responseTime: 0)
            ),
            keyEmotions: ResponseAnalyzer().extractEmotionalWords(from: userResponse),
            responseTime: 0 // Could track actual time spent
        )
        
        // Learn from this response
        conversationLearner.analyzeResponse(response)
        
        // Save via bridge
        MindWellBridge.shared.saveResponse(response)
        
        dismiss()
    }
}
```

## 3-Day Implementation Tasks

### Day 1: Enhanced Models & Learning Engine
**Tasks for AI Agent:**

1. **Create comprehensive data models**
   - Implement `ConversationPrompt` with all categories and styles
   - Create `UserPattern` with learning capabilities
   - Build `ConversationContext` for conversation flow
   - Create `UserResponse` with engagement tracking

2. **Build ConversationLearner**
   - Implement response analysis and pattern detection
   - Create user preference learning algorithms
   - Add emotional keyword extraction
   - Build mood-pattern association system

3. **Create ResponseAnalyzer**
   - Implement emotional word detection (40+ emotional keywords)
   - Build engagement level analysis
   - Create key word extraction methods
   - Add response length classification

4. **Expand PromptDatabase to 80 prompts**
   - 25 morning prompts (varied styles and categories)
   - 20 afternoon prompts (including coping strategies)
   - 35 evening prompts (reflection and gratitude focus)
   - Ensure variety in conversation styles and emotional tones

### Day 2: Adaptive UI & Conversation Flow
**Tasks for AI Agent:**

5. **Build AdaptivePromptView**
   - Create prompts that adapt to user's preferred style
   - Implement mood scale with enhanced interaction
   - Add responsive text input with proper focus management
   - Style according to iOS 17.6 guidelines

6. **Create ConversationView with learning integration**
   - Implement conversation flow management
   - Add follow-up question logic based on response analysis
   - Create conversation history display
   - Add personalized prompt loading

7. **Build FloatingPromptButton with smart notifications**
   - Create button that adapts based on user patterns
   - Add subtle animations for different conversation readiness
   - Implement time-based appearance logic
   - Style with iOS 17 native components

8. **Create ConversationHistoryView**
   - Display previous exchanges in current session
   - Show conversation progression
   - Add smooth transitions between questions

### Day 3: Advanced Learning & Integration
**Tasks for AI Agent:**

9. **Implement PromptSelector with AI-like selection**
   - Create intelligent prompt selection based on learned patterns
   - Add effectiveness scoring for prompts
   - Implement conversation style matching
   - Add variety algorithms to prevent repetition

10. **Enhanced MindWellBridge**
    - Add comprehensive response storage
    - Create learning data persistence
    - Implement conversation analytics
    - Add user pattern synchronization

11. **Advanced conversation features**
    - Add follow-up question generation based on triggers
    - Implement conversation depth adaptation
    - Create emotional keyword highlighting
    - Add conversation completion insights

12. **Testing & learning optimization**
    - Test learning algorithm effectiveness
    - Verify conversation flow feels natural
    - Test adaptation to different user styles
    - Create conversation analytics dashboard

## Learning Metrics to Track

### User Engagement Patterns
- **Response length trends** (getting longer/shorter over time)
- **Emotional vocabulary expansion** (using more varied emotional words)
- **Conversation depth preference** (surface vs deep discussions)
- **Time-of-day engagement** (when user is most conversational)
- **Follow-up question engagement** (how often they continue conversations)

### Conversation Effectiveness
- **Prompt response rates** (which prompts get answered vs skipped)
- **Emotional processing indicators** (mood changes during conversation)
- **Conversation completion rates** (how often they finish vs quit early)
- **Return engagement** (how often they come back for more conversation)

## Success Criteria
- ✅ System learns user's conversation style within 5-7 interactions
- ✅ Prompts become noticeably more personalized over time  
- ✅ Users engage in longer conversations as system adapts
- ✅ Follow-up questions feel relevant and natural
- ✅ 80 prompts provide sufficient variety to avoid repetition
- ✅ Learning patterns persist and improve conversation quality
- ✅ System feels increasingly like talking to someone who knows you

This creates a **truly conversational experience** that gets better over time, making users want to return daily for meaningful emotional check-ins.
