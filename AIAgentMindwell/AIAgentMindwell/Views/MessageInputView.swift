//
//  MessageInputView.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import SwiftUI

struct MessageInputView: View {
    @Binding var messageText: String
    let onSend: (String) -> Void
    let isEnabled: Bool
    
    @State private var textHeight: CGFloat = 36
    @FocusState private var isTextFieldFocused: Bool
    
    private let maxHeight: CGFloat = 120
    private let minHeight: CGFloat = 36
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: 12) {
                // Text input area
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .frame(height: max(minHeight, min(textHeight, maxHeight)))
                    
                    TextEditor(text: $messageText)
                        .focused($isTextFieldFocused)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                        .frame(height: max(minHeight, min(textHeight, maxHeight)))
                        .onChange(of: messageText) { _, newValue in
                            updateTextHeight()
                        }
                        .disabled(!isEnabled)
                    
                    // Placeholder text
                    if messageText.isEmpty {
                        Text("Share your thoughts...")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
                
                // Send button
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(canSend ? .blue : .gray)
                }
                .disabled(!canSend)
                .animation(.easeInOut(duration: 0.2), value: canSend)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
        .onAppear {
            // Auto-focus when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }
    
    private var canSend: Bool {
        isEnabled && !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func sendMessage() {
        guard canSend else { return }
        
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        onSend(trimmedMessage)
        messageText = ""
        textHeight = minHeight
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func updateTextHeight() {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let textView = UITextView()
        textView.font = font
        textView.text = messageText
        
        let size = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 80, height: .infinity))
        textHeight = max(minHeight, min(size.height + 16, maxHeight))
    }
}


#Preview {
    VStack {
        ConversationHeaderView(
            session: ConversationSession(initialPrompt: nil),
            isTyping: false
        )
        
        Spacer()
        
        MessageInputView(
            messageText: .constant(""),
            onSend: { message in
                print("Sent: \(message)")
            },
            isEnabled: true
        )
    }
}
