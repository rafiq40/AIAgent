//
//  MessageBubbleView.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: ConversationMessage
    
    var body: some View {
        HStack {
            if message.isFromAgent {
                // Agent message - left aligned
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        AgentAvatarView()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(message.content)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray5))
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Spacer().frame(width: 44) // Align with avatar
                        Text(message.formattedTimestamp)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            } else {
                // User message - right aligned
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack {
                                if let mood = message.mood {
                                    MoodIndicatorView(mood: mood)
                                }
                                
                                Text(message.content)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(18)
                            }
                        }
                        
                        UserAvatarView()
                    }
                    
                    HStack {
                        Spacer()
                        Text(message.formattedTimestamp)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer().frame(width: 44) // Align with avatar
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct AgentAvatarView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 36, height: 36)
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

struct UserAvatarView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.8), Color.blue.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 36, height: 36)
            
            Image(systemName: "person.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

struct MoodIndicatorView: View {
    let mood: Int
    
    var body: some View {
        HStack(spacing: 2) {
            Text("\(mood)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(moodColor)
            
            Image(systemName: moodIcon)
                .font(.caption)
                .foregroundColor(moodColor)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(moodColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var moodColor: Color {
        switch mood {
        case 1...3: return .red
        case 4...6: return .orange
        case 7...8: return .yellow
        case 9...10: return .green
        default: return .gray
        }
    }
    
    private var moodIcon: String {
        switch mood {
        case 1...2: return "face.dashed"
        case 3...4: return "face.dashed.fill"
        case 5...6: return "face.smiling"
        case 7...8: return "face.smiling.fill"
        case 9...10: return "face.smiling.inverse"
        default: return "face.smiling"
        }
    }
}


#Preview {
    VStack(spacing: 16) {
        MessageBubbleView(message: .agentMessage("Hello! How are you feeling today?", type: .greeting))
        
        MessageBubbleView(message: .userMessage("I'm feeling pretty good, thanks for asking!", mood: 7))
        
        TypingIndicatorView()
        
        MoodSliderView(moodRating: .constant(5.0)) {
            print("Mood submitted")
        }
    }
    .padding()
}
