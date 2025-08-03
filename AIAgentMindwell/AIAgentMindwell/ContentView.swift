//
//  ContentView.swift
//  AIAgentMindwell
//
//  Created by Rafal on 03/08/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingConversation = false
    @State private var conversationContext = ConversationContext()
    @State private var mindWellBridge = MindWellBridge.shared
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserResponseEntity.timestamp, ascending: false)],
        animation: .default)
    private var responses: FetchedResults<UserResponseEntity>

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("AI Agent Mindwell")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your Personal Emotional Check-in Companion")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Main conversation button
                Button(action: startConversation) {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.pink)
                        
                        Text("Start Daily Check-in")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Let's explore how you're feeling today")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
                
                // Recent responses section
                if !responses.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Check-ins")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(Array(responses.prefix(5)), id: \.objectID) { response in
                                    RecentResponseCard(response: response)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // Stats section
                if !responses.isEmpty {
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Total Check-ins",
                            value: "\(responses.count)",
                            icon: "calendar"
                        )
                        
                        StatCard(
                            title: "This Week",
                            value: "\(responsesThisWeek)",
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        
                        StatCard(
                            title: "Avg Mood",
                            value: String(format: "%.1f", averageMood),
                            icon: "heart.fill"
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .sheet(isPresented: $showingConversation) {
                ConversationView(context: conversationContext)
            }
        }
    }
    
    private func startConversation() {
        conversationContext = ConversationContext()
        
        // Get personalized prompt based on time and user patterns
        let personalizedPrompt = getContextualPrompt()
        conversationContext.startConversation(with: personalizedPrompt)
        
        showingConversation = true
    }
    
    private func getContextualPrompt() -> ConversationPrompt {
        let currentTime = TimeContext.current()
        
        // Try to get a personalized prompt first
        if let personalizedPrompt = mindWellBridge.getPersonalizedPrompt(for: conversationContext) {
            return personalizedPrompt
        }
        
        // Fallback to contextual prompts based on time and recent patterns
        let recentMood = getRecentAverageMood()
        let timeBasedPrompts = PromptDatabase.allPrompts.filter { $0.timeOfDay == currentTime }
        
        // Select based on recent mood patterns
        let moodAppropriatePrompts = timeBasedPrompts.filter { prompt in
            switch recentMood {
            case 1...3: // Recent low moods - use supportive prompts
                return prompt.emotionalTone == .empathetic || prompt.emotionalTone == .warm || prompt.category == .coping
            case 7...10: // Recent high moods - use energetic or gratitude prompts
                return prompt.emotionalTone == .energetic || prompt.category == .gratitude || prompt.category == .future
            default: // Neutral - use gentle, open-ended prompts
                return prompt.conversationStyle == .gentle || prompt.category == .openEnded
            }
        }
        
        // Return appropriate prompt or fallback
        return moodAppropriatePrompts.randomElement() ?? 
               timeBasedPrompts.randomElement() ?? 
               PromptDatabase.allPrompts.randomElement()!
    }
    
    private func getRecentAverageMood() -> Double {
        let recentResponses = Array(responses.prefix(5)) // Convert to Array for safety
        guard !recentResponses.isEmpty else { return 5.0 }
        
        // Validate mood values and filter out invalid ones
        let validMoods = recentResponses.compactMap { response -> Int? in
            let mood = Int(response.mood)
            return (mood >= 1 && mood <= 10) ? mood : nil
        }
        
        guard !validMoods.isEmpty else { return 5.0 }
        
        let totalMood = validMoods.reduce(0, +)
        let count = validMoods.count
        
        // Additional safety check before division
        guard count > 0 else { return 5.0 }
        
        let average = Double(totalMood) / Double(count)
        
        // Ensure result is finite and within valid range
        guard average.isFinite && average >= 1.0 && average <= 10.0 else { return 5.0 }
        
        return average
    }
    
    private var responsesThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return responses.filter { response in
            guard let timestamp = response.timestamp else { return false }
            return timestamp >= weekAgo
        }.count
    }
    
    private var averageMood: Double {
        let responsesArray = Array(responses) // Convert to Array for safety
        guard !responsesArray.isEmpty else { return 5.0 }
        
        // Validate mood values and filter out invalid ones
        let validMoods = responsesArray.compactMap { response -> Int? in
            let mood = Int(response.mood)
            return (mood >= 1 && mood <= 10) ? mood : nil
        }
        
        guard !validMoods.isEmpty else { return 5.0 }
        
        let totalMood = validMoods.reduce(0, +)
        let count = validMoods.count
        
        // Additional safety check before division
        guard count > 0 else { return 5.0 }
        
        let average = Double(totalMood) / Double(count)
        
        // Ensure result is finite and within valid range
        guard average.isFinite && average >= 1.0 && average <= 10.0 else { return 5.0 }
        
        return average
    }
}

struct RecentResponseCard: View {
    let response: UserResponseEntity
    
    var body: some View {
        HStack(spacing: 12) {
            // Mood indicator
            Circle()
                .fill(moodColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(response.response?.prefix(60) ?? "")
                    .font(.subheadline)
                    .lineLimit(2)
                
                HStack {
                    Text(formatDate(response.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Mood: \(response.mood)/10")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var moodColor: Color {
        switch response.mood {
        case 1...3: return .red
        case 4...6: return .orange
        case 7...10: return .green
        default: return .gray
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDate(date, inSameDayAs: Date()) {
            formatter.dateFormat = "HH:mm"
            return "Today \(formatter.string(from: date))"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()) {
            formatter.dateFormat = "HH:mm"
            return "Yesterday \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ConversationView: View {
    let context: ConversationContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var viewModel: ConversationViewModel
    @State private var messageText = ""
    
    init(context: ConversationContext) {
        self.context = context
        self._viewModel = StateObject(wrappedValue: ConversationViewModel())
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                ConversationHeaderView(
                    session: viewModel.currentSession,
                    isTyping: viewModel.isTyping
                )
                
                if viewModel.conversationEnded {
                    // Show conversation end view
                    ScrollView {
                        if let session = viewModel.currentSession {
                            ConversationEndView(
                                session: session,
                                onStartNew: startNewConversation,
                                onClose: { dismiss() }
                            )
                        }
                    }
                } else {
                    // Chat interface
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubbleView(message: message)
                                        .id(message.id)
                                }
                                
                                // Typing indicator
                                if viewModel.isTyping {
                                    TypingIndicatorView()
                                        .id("typing")
                                }
                                
                                // Mood slider
                                if viewModel.showMoodSlider {
                                    MoodSliderView(
                                        moodRating: $viewModel.currentMoodRating,
                                        onSubmit: viewModel.submitMoodRating
                                    )
                                    .id("mood-slider")
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .onChange(of: viewModel.messages.count) { _, _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    if viewModel.showMoodSlider {
                                        proxy.scrollTo("mood-slider", anchor: .bottom)
                                    } else if viewModel.isTyping {
                                        proxy.scrollTo("typing", anchor: .bottom)
                                    } else if let lastMessage = viewModel.messages.last {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .onChange(of: viewModel.isTyping) { _, _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    if viewModel.showMoodSlider {
                                        proxy.scrollTo("mood-slider", anchor: .bottom)
                                    } else if viewModel.isTyping {
                                        proxy.scrollTo("typing", anchor: .bottom)
                                    } else if let lastMessage = viewModel.messages.last {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .onChange(of: viewModel.showMoodSlider) { _, _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    if viewModel.showMoodSlider {
                                        proxy.scrollTo("mood-slider", anchor: .bottom)
                                    } else if viewModel.isTyping {
                                        proxy.scrollTo("typing", anchor: .bottom)
                                    } else if let lastMessage = viewModel.messages.last {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Message input
                    if !viewModel.conversationEnded {
                        MessageInputView(
                            messageText: $messageText,
                            onSend: viewModel.sendUserMessage,
                            isEnabled: viewModel.canSendMessage
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                if !viewModel.conversationEnded {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("End") {
                            Task {
                                await viewModel.endConversation()
                            }
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            setupConversation()
        }
        .onDisappear {
            viewModel.resetConversation()
        }
    }
    
    private func setupConversation() {
        viewModel.viewContext = viewContext
        
        if let prompt = context.currentPrompt {
            viewModel.startConversation(with: prompt)
        } else {
            // Fallback to a random prompt
            let currentTime = TimeContext.current()
            if let randomPrompt = PromptDatabase.getRandomPrompt(for: currentTime) {
                viewModel.startConversation(with: randomPrompt)
            }
        }
    }
    
    private func startNewConversation() {
        viewModel.resetConversation()
        setupConversation()
    }
    
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
