//
//  TypingIndicatorView.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // AI Agent Avatar (smaller)
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                )
            
            // Typing bubble
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.secondary.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0 + animationOffset)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationOffset
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray5))
            .cornerRadius(20)
            
            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            animationOffset = 0.3
        }
        .onDisappear {
            animationOffset = 0
        }
    }
}

#Preview {
    TypingIndicatorView()
        .padding()
}
