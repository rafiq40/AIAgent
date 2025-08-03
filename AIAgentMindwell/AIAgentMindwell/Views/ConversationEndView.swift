//
//  ConversationEndView.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import SwiftUI

struct ConversationEndView: View {
    let session: ConversationSession
    let onStartNew: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Success icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.green, .blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 40)
            
            // Title and message
            VStack(spacing: 12) {
                Text("Check-in Complete")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Thank you for sharing your thoughts with me today.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Session summary
            VStack(spacing: 16) {
                Text("Session Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let summary = session.sessionSummary {
                    Text(summary)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    // Fallback summary
                    let userMessages = session.userMessages
                    let totalWords = userMessages.reduce(0) { $0 + $1.content.split(separator: " ").count }
                    let avgMood = session.userMoodRating ?? 5
                    
                    Text("Session completed with \(userMessages.count) responses, \(totalWords) words shared, average mood: \(avgMood)/10")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: onStartNew) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Start New Check-in")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                Button(action: onClose) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

#Preview {
    let session = ConversationSession()
    ConversationEndView(
        session: session,
        onStartNew: {},
        onClose: {}
    )
}
