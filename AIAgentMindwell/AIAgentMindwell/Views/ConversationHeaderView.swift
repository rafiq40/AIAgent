//
//  ConversationHeaderView.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import SwiftUI

struct ConversationHeaderView: View {
    let session: ConversationSession?
    let isTyping: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // AI Agent Avatar
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Agent Mindwell")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if isTyping {
                        Text("Typing...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        Text("Your emotional wellness companion")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Session info
                if let session = session {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Check-in")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formatSessionTime(session.startTime))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
        }
        .background(Color(.systemBackground))
    }
    
    private func formatSessionTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ConversationHeaderView(
        session: ConversationSession(),
        isTyping: false
    )
}
