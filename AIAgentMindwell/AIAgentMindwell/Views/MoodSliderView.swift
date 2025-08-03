//
//  MoodSliderView.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import SwiftUI

struct MoodSliderView: View {
    @Binding var moodRating: Double
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // AI Agent message bubble
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
                
                // Message bubble
                VStack(alignment: .leading, spacing: 8) {
                    Text("How would you rate your current mood?")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray5))
                .cornerRadius(20)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Mood slider interface
            VStack(spacing: 16) {
                // Emoji indicators
                HStack {
                    Text("😢")
                        .font(.title2)
                    
                    Spacer()
                    
                    Text("😐")
                        .font(.title2)
                    
                    Spacer()
                    
                    Text("😊")
                        .font(.title2)
                }
                .padding(.horizontal, 20)
                
                // Slider
                HStack(spacing: 12) {
                    Text("😢")
                        .font(.title3)
                    
                    Slider(value: $moodRating, in: 1...10, step: 1)
                        .accentColor(sliderColor)
                    
                    Text("😊")
                        .font(.title3)
                }
                .padding(.horizontal)
                
                // Current mood display
                Text("Current mood: \(Int(moodRating))/10")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Submit button
                Button(action: onSubmit) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(25)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    private var sliderColor: Color {
        switch Int(moodRating) {
        case 1...3:
            return .red
        case 4...6:
            return .orange
        case 7...10:
            return .green
        default:
            return .blue
        }
    }
}

#Preview {
    MoodSliderView(
        moodRating: .constant(5.0),
        onSubmit: {}
    )
    .padding()
}
