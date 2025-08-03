//
//  PromptDatabase.swift
//  AIAgentMindwell
//
//  Created by AI Agent on 03/08/2025.
//

import Foundation

class PromptDatabase {
    static let shared = PromptDatabase()
    
    private init() {}
    
    // MARK: - 80+ Comprehensive Prompts
    
    static let allPrompts: [ConversationPrompt] = [
        
        // MARK: - MORNING PROMPTS (28 total)
        
        // Morning - Open Ended (10 prompts)
        ConversationPrompt(
            id: "m_open_1",
            question: "Good morning! How are you feeling as this new day begins?",
            category: .openEnded,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            followUpTriggers: ["tired", "anxious", "excited", "nervous", "worried"],
            followUps: ["What's contributing to that feeling?", "Tell me more about that.", "What's on your mind this morning?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "m_open_2",
            question: "Hey there! What's your emotional weather like this morning?",
            category: .openEnded,
            timeOfDay: .morning,
            conversationStyle: .casual,
            followUpTriggers: ["cloudy", "stormy", "sunny", "foggy", "mixed"],
            followUps: ["What's creating that weather pattern?", "How does that feel in your body?"],
            emotionalTone: .energetic
        ),
        
        ConversationPrompt(
            id: "m_open_3",
            question: "Take a moment... how are you feeling right now?",
            category: .openEnded,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            followUpTriggers: ["overwhelmed", "peaceful", "rushed", "calm"],
            followUps: ["What would help you feel more centered?", "What's behind that feeling?"],
            emotionalTone: .calm
        ),
        
        ConversationPrompt(
            id: "m_open_4",
            question: "Morning check-in: What emotions are present for you today?",
            category: .openEnded,
            timeOfDay: .morning,
            conversationStyle: .direct,
            followUpTriggers: ["multiple", "confused", "clear", "mixed"],
            followUps: ["Which emotion feels strongest?", "How are you holding space for all of that?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "m_open_5",
            question: "I'm here with you. What's happening in your heart this morning?",
            category: .openEnded,
            timeOfDay: .morning,
            conversationStyle: .supportive,
            followUpTriggers: ["heavy", "light", "full", "empty", "aching"],
            followUps: ["You don't have to carry that alone.", "What does your heart need right now?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "m_open_6",
            question: "I'm wondering... what's the first emotion you noticed when you woke up?",
            category: .openEnded,
            timeOfDay: .morning,
            conversationStyle: .curious,
            followUpTriggers: ["dream", "sleep", "woke", "first"],
            followUps: ["What do you think that emotion is telling you?", "How has it shifted since then?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "m_open_7",
            question: "Good morning, friend. How's your inner world today?",
            category: .openEnded,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            followUpTriggers: ["chaotic", "quiet", "busy", "still", "turbulent"],
            followUps: ["What's creating that inner landscape?", "What would bring more peace to that space?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "m_open_8",
            question: "Starting fresh today - how are you feeling about that?",
            category: .openEnded,
            timeOfDay: .morning,
            conversationStyle: .casual,
            followUpTriggers: ["fresh", "new", "opportunity", "chance", "beginning"],
            followUps: ["What makes this feel like a fresh start?", "What are you hoping for today?"],
            emotionalTone: .energetic
        ),
        
        ConversationPrompt(
            id: "m_open_9",
            question: "Before the day gets busy, how are you really doing?",
            category: .openEnded,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            followUpTriggers: ["busy", "overwhelmed", "prepared", "ready", "stressed"],
            followUps: ["What would help you feel more prepared?", "How can you honor that feeling today?"],
            emotionalTone: .calm
        ),
        
        ConversationPrompt(
            id: "m_open_10",
            question: "What's alive in you this morning?",
            category: .openEnded,
            timeOfDay: .morning,
            conversationStyle: .curious,
            followUpTriggers: ["energy", "passion", "excitement", "creativity", "motivation"],
            followUps: ["How does that aliveness want to express itself?", "What feeds that energy in you?"],
            emotionalTone: .energetic
        ),
        
        // Morning - Specific (8 prompts)
        ConversationPrompt(
            id: "m_specific_1",
            question: "What emotions are you noticing as you start today?",
            category: .specific,
            timeOfDay: .morning,
            conversationStyle: .curious,
            followUpTriggers: ["anxiety", "stress", "worry", "excitement", "fear"],
            followUps: ["Where do you feel that in your body?", "What's behind that emotion?"],
            emotionalTone: .calm
        ),
        
        ConversationPrompt(
            id: "m_specific_2",
            question: "If your mood had a color this morning, what would it be?",
            category: .specific,
            timeOfDay: .morning,
            conversationStyle: .curious,
            followUpTriggers: ["dark", "bright", "gray", "colorful", "muted"],
            followUps: ["What gives that color its particular shade?", "How does that color make you feel?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "m_specific_3",
            question: "What's the strongest feeling you're carrying into today?",
            category: .specific,
            timeOfDay: .morning,
            conversationStyle: .direct,
            followUpTriggers: ["strong", "intense", "overwhelming", "powerful"],
            followUps: ["How long have you been carrying this feeling?", "What does this feeling need from you?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "m_specific_4",
            question: "What's your energy level telling you about how you're feeling?",
            category: .specific,
            timeOfDay: .morning,
            conversationStyle: .curious,
            followUpTriggers: ["low", "high", "drained", "energized", "tired"],
            followUps: ["What's contributing to that energy level?", "What would help restore your energy?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "m_specific_5",
            question: "If you could describe your emotional state in three words, what would they be?",
            category: .specific,
            timeOfDay: .morning,
            conversationStyle: .direct,
            followUpTriggers: ["confused", "clear", "mixed", "complex"],
            followUps: ["Which of those words feels most important right now?", "What's creating that combination?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "m_specific_6",
            question: "What emotion is asking for your attention this morning?",
            category: .specific,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            followUpTriggers: ["ignored", "attention", "notice", "acknowledge"],
            followUps: ["How long has it been asking for attention?", "What happens when you give it space?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "m_specific_7",
            question: "What's different about how you're feeling today compared to yesterday?",
            category: .specific,
            timeOfDay: .morning,
            conversationStyle: .curious,
            followUpTriggers: ["better", "worse", "different", "same", "shifted"],
            followUps: ["What do you think created that shift?", "How does that change feel?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "m_specific_8",
            question: "If your emotions were weather, what's the forecast for today?",
            category: .specific,
            timeOfDay: .morning,
            conversationStyle: .curious,
            followUpTriggers: ["storm", "sunshine", "clouds", "rain", "wind"],
            followUps: ["What's creating that weather pattern?", "What would help clear the skies?"],
            emotionalTone: .neutral
        ),
        
        // Morning - Reflective (5 prompts)
        ConversationPrompt(
            id: "m_reflective_1",
            question: "Looking at the day ahead, what hopes do you have?",
            category: .reflective,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            followUpTriggers: ["hope", "worry", "uncertain", "excited", "nervous"],
            followUps: ["What would make today feel meaningful?", "What's behind those hopes?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "m_reflective_2",
            question: "What do you need to feel emotionally supported today?",
            category: .reflective,
            timeOfDay: .morning,
            conversationStyle: .supportive,
            followUpTriggers: ["support", "alone", "connection", "understanding"],
            followUps: ["How can you give yourself that support?", "Who in your life provides that?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "m_reflective_3",
            question: "What would your wisest self tell you about how you're feeling right now?",
            category: .reflective,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            followUpTriggers: ["wise", "advice", "guidance", "inner"],
            followUps: ["What makes that wisdom feel true?", "How can you carry that wisdom with you today?"],
            emotionalTone: .calm
        ),
        
        ConversationPrompt(
            id: "m_reflective_4",
            question: "If you could send love to any part of yourself this morning, where would it go?",
            category: .reflective,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            followUpTriggers: ["hurt", "tired", "struggling", "heart", "mind"],
            followUps: ["What would that love feel like?", "What does that part of you need to hear?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "m_reflective_5",
            question: "What's one thing you're learning about yourself through your emotions lately?",
            category: .reflective,
            timeOfDay: .morning,
            conversationStyle: .curious,
            followUpTriggers: ["learning", "discovering", "understanding", "growing"],
            followUps: ["How does that learning feel?", "What does that teach you about what you need?"],
            emotionalTone: .neutral
        ),
        
        // Morning - Future Focused (5 prompts)
        ConversationPrompt(
            id: "m_future_1",
            question: "What are you looking forward to today?",
            category: .future,
            timeOfDay: .morning,
            conversationStyle: .casual,
            followUpTriggers: ["nothing", "work", "meeting", "time", "people"],
            followUps: ["What's one small thing that could bring you joy today?", "What makes that feel exciting?"],
            emotionalTone: .energetic
        ),
        
        ConversationPrompt(
            id: "m_future_2",
            question: "How do you want to feel by the end of today?",
            category: .future,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            followUpTriggers: ["peaceful", "accomplished", "connected", "tired", "satisfied"],
            followUps: ["What would help you feel that way?", "What steps could move you toward that feeling?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "m_future_3",
            question: "What's one way you could be kind to yourself today?",
            category: .future,
            timeOfDay: .morning,
            conversationStyle: .supportive,
            followUpTriggers: ["kind", "gentle", "care", "rest", "treat"],
            followUps: ["What makes that feel like kindness to you?", "When could you give yourself that gift today?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "m_future_4",
            question: "If you could plant one seed of intention for today, what would it be?",
            category: .future,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            followUpTriggers: ["intention", "hope", "goal", "wish", "desire"],
            followUps: ["What would help that intention grow?", "How will you nurture that seed today?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "m_future_5",
            question: "What's one thing you hope to feel grateful for by tonight?",
            category: .future,
            timeOfDay: .morning,
            conversationStyle: .gentle,
            followUpTriggers: ["grateful", "thankful", "appreciate", "blessing"],
            followUps: ["What would make that feel meaningful?", "How could you create space for gratitude today?"],
            emotionalTone: .warm
        ),
        
        // MARK: - AFTERNOON PROMPTS (20 total)
        
        // Afternoon - Open Ended (8 prompts)
        ConversationPrompt(
            id: "a_open_1",
            question: "Hey! How has your day been unfolding?",
            category: .openEnded,
            timeOfDay: .afternoon,
            conversationStyle: .casual,
            followUpTriggers: ["busy", "stressful", "good", "hard", "unexpected"],
            followUps: ["What's been the highlight so far?", "What's been challenging?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "a_open_2",
            question: "Midday check-in: How are you feeling right now?",
            category: .openEnded,
            timeOfDay: .afternoon,
            conversationStyle: .direct,
            followUpTriggers: ["tired", "energized", "overwhelmed", "focused"],
            followUps: ["What's contributing to that feeling?", "What do you need right now?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "a_open_3",
            question: "I'm curious - what's your emotional temperature right now?",
            category: .openEnded,
            timeOfDay: .afternoon,
            conversationStyle: .curious,
            followUpTriggers: ["hot", "cold", "warm", "cool", "burning"],
            followUps: ["What's heating things up or cooling them down?", "How does that temperature feel?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "a_open_4",
            question: "How's your heart doing in the middle of this day?",
            category: .openEnded,
            timeOfDay: .afternoon,
            conversationStyle: .gentle,
            followUpTriggers: ["heavy", "light", "full", "empty", "racing"],
            followUps: ["What's your heart trying to tell you?", "What would help your heart feel lighter?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "a_open_5",
            question: "What's the story your emotions are telling you today?",
            category: .openEnded,
            timeOfDay: .afternoon,
            conversationStyle: .curious,
            followUpTriggers: ["story", "narrative", "chapter", "plot"],
            followUps: ["What's the main theme of that story?", "How do you want this story to continue?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "a_open_6",
            question: "Taking a pause from the day - how are you really doing?",
            category: .openEnded,
            timeOfDay: .afternoon,
            conversationStyle: .supportive,
            followUpTriggers: ["pause", "really", "honestly", "actually"],
            followUps: ["What would it feel like to honor that truth?", "What do you need to acknowledge?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "a_open_7",
            question: "If your emotions could speak right now, what would they say?",
            category: .openEnded,
            timeOfDay: .afternoon,
            conversationStyle: .curious,
            followUpTriggers: ["speak", "voice", "message", "tell"],
            followUps: ["What tone would they use?", "What do they most want you to understand?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "a_open_8",
            question: "What's been the emotional rhythm of your day so far?",
            category: .openEnded,
            timeOfDay: .afternoon,
            conversationStyle: .curious,
            followUpTriggers: ["rhythm", "flow", "pattern", "ups", "downs"],
            followUps: ["What's creating that rhythm?", "How does that rhythm feel in your body?"],
            emotionalTone: .neutral
        ),
        
        // Afternoon - Specific (6 prompts)
        ConversationPrompt(
            id: "a_specific_1",
            question: "What's the strongest emotion you've felt today?",
            category: .specific,
            timeOfDay: .afternoon,
            conversationStyle: .direct,
            followUpTriggers: ["anger", "joy", "frustration", "contentment", "anxiety"],
            followUps: ["What triggered that feeling?", "How are you handling that emotion?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "a_specific_2",
            question: "What emotion has been your most frequent visitor today?",
            category: .specific,
            timeOfDay: .afternoon,
            conversationStyle: .curious,
            followUpTriggers: ["frequent", "visitor", "returning", "persistent"],
            followUps: ["What do you think it's trying to tell you?", "How do you usually greet this emotion?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "a_specific_3",
            question: "If you had to rate your emotional energy right now, what would it be?",
            category: .specific,
            timeOfDay: .afternoon,
            conversationStyle: .direct,
            followUpTriggers: ["low", "high", "medium", "drained", "charged"],
            followUps: ["What's influencing that energy level?", "What would help restore or maintain it?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "a_specific_4",
            question: "What's one emotion you've been trying to avoid today?",
            category: .specific,
            timeOfDay: .afternoon,
            conversationStyle: .gentle,
            followUpTriggers: ["avoid", "ignore", "push", "suppress"],
            followUps: ["What makes that emotion feel difficult?", "What would happen if you gave it some space?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "a_specific_5",
            question: "Which emotion feels most familiar to you today?",
            category: .specific,
            timeOfDay: .afternoon,
            conversationStyle: .curious,
            followUpTriggers: ["familiar", "usual", "common", "typical"],
            followUps: ["What makes this emotion feel like home?", "Is that familiarity comforting or concerning?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "a_specific_6",
            question: "What emotion would you like to feel more of right now?",
            category: .specific,
            timeOfDay: .afternoon,
            conversationStyle: .supportive,
            followUpTriggers: ["more", "want", "need", "crave"],
            followUps: ["What would help invite that emotion in?", "What does that emotion represent for you?"],
            emotionalTone: .warm
        ),
        
        // Afternoon - Coping (6 prompts)
        ConversationPrompt(
            id: "a_coping_1",
            question: "If you're feeling stressed right now, what usually helps?",
            category: .coping,
            timeOfDay: .afternoon,
            conversationStyle: .supportive,
            followUpTriggers: ["stressed", "overwhelmed", "tired", "frustrated"],
            followUps: ["Have you tried that today?", "What's one thing you could do right now?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "a_coping_2",
            question: "What's one way you could be gentle with yourself right now?",
            category: .coping,
            timeOfDay: .afternoon,
            conversationStyle: .gentle,
            followUpTriggers: ["gentle", "kind", "soft", "tender"],
            followUps: ["What would that gentleness look like?", "What's stopping you from being gentle with yourself?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "a_coping_3",
            question: "When you feel overwhelmed, what brings you back to center?",
            category: .coping,
            timeOfDay: .afternoon,
            conversationStyle: .supportive,
            followUpTriggers: ["overwhelmed", "center", "ground", "balance"],
            followUps: ["How could you access that centering right now?", "What does being centered feel like for you?"],
            emotionalTone: .calm
        ),
        
        ConversationPrompt(
            id: "a_coping_4",
            question: "What's your go-to strategy when emotions feel too big?",
            category: .coping,
            timeOfDay: .afternoon,
            conversationStyle: .direct,
            followUpTriggers: ["big", "intense", "overwhelming", "too much"],
            followUps: ["How well is that strategy working for you?", "What would help you feel more capable of handling big emotions?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "a_coping_5",
            question: "If you could give yourself exactly what you need right now, what would it be?",
            category: .coping,
            timeOfDay: .afternoon,
            conversationStyle: .supportive,
            followUpTriggers: ["need", "want", "require", "crave"],
            followUps: ["What's a small way you could give yourself that?", "What makes that feel like what you need?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "a_coping_6",
            question: "What would help you feel more emotionally steady right now?",
            category: .coping,
            timeOfDay: .afternoon,
            conversationStyle: .supportive,
            followUpTriggers: ["steady", "stable", "grounded", "balanced"],
            followUps: ["What does emotional steadiness feel like for you?", "What usually helps you find that steadiness?"],
            emotionalTone: .calm
        ),
        
        // MARK: - EVENING PROMPTS (32 total)
        
        // Evening - Reflective (12 prompts)
        ConversationPrompt(
            id: "e_reflective_1",
            question: "As you look back on today, what stands out emotionally?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["nothing", "everything", "work", "relationships", "moment"],
            followUps: ["What made that moment significant?", "How do you feel about that now?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_reflective_2",
            question: "What emotion visited you most often today?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .curious,
            followUpTriggers: ["visited", "frequent", "often", "recurring"],
            followUps: ["What do you think it was trying to tell you?", "How did you welcome or resist that visitor?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "e_reflective_3",
            question: "If today's emotions were a painting, what would it look like?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .curious,
            followUpTriggers: ["painting", "colors", "brushstrokes", "canvas"],
            followUps: ["What colors dominate the canvas?", "What story does that painting tell?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "e_reflective_4",
            question: "What did you learn about yourself through your emotions today?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .curious,
            followUpTriggers: ["learn", "discover", "realize", "understand"],
            followUps: ["How does that learning feel?", "What will you do with that insight?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "e_reflective_5",
            question: "Looking back, what emotion deserves more acknowledgment from today?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["acknowledgment", "recognition", "attention", "honor"],
            followUps: ["What would it mean to give that emotion its due?", "How can you honor that feeling now?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "e_reflective_6",
            question: "What's one way you grew emotionally today, even in a small way?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .supportive,
            followUpTriggers: ["grew", "growth", "learned", "developed"],
            followUps: ["What made that growth possible?", "How does that growth feel?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_reflective_7",
            question: "If you could have a conversation with how you felt this morning, what would you say?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["morning", "conversation", "say", "tell"],
            followUps: ["What has changed since then?", "What would your morning self want to know?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_reflective_8",
            question: "What emotion from today are you ready to release?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["release", "let go", "done", "finished"],
            followUps: ["What would it feel like to let that go?", "What helped you carry it through the day?"],
            emotionalTone: .calm
        ),
        
        ConversationPrompt(
            id: "e_reflective_9",
            question: "How did you show up for your emotions today?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .curious,
            followUpTriggers: ["show up", "present", "available", "there"],
            followUps: ["What does showing up for your emotions look like?", "How could you show up even better tomorrow?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "e_reflective_10",
            question: "What's one emotional pattern you noticed about yourself today?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .curious,
            followUpTriggers: ["pattern", "habit", "tendency", "recurring"],
            followUps: ["How do you feel about that pattern?", "What might that pattern be protecting or serving?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "e_reflective_11",
            question: "If today's emotions had a soundtrack, what would be the main song?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .curious,
            followUpTriggers: ["soundtrack", "song", "music", "melody"],
            followUps: ["What makes that song fit today?", "How does that music make you feel?"],
            emotionalTone: .neutral
        ),
        
        ConversationPrompt(
            id: "e_reflective_12",
            question: "What's one thing you wish you could tell someone about how you felt today?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["tell", "share", "express", "communicate"],
            followUps: ["What would it mean to share that?", "What's stopping you from sharing it?"],
            emotionalTone: .empathetic
        ),
        
        // Evening - Gratitude (8 prompts)
        ConversationPrompt(
            id: "e_gratitude_1",
            question: "What's something from today that you feel grateful for?",
            category: .gratitude,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["nothing", "people", "moments", "small", "everything"],
            followUps: ["Tell me more about that.", "How did that impact your day?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_gratitude_2",
            question: "What small moment from today brought you joy?",
            category: .gratitude,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["small", "moment", "joy", "happy", "smile"],
            followUps: ["What made that moment special?", "How can you create more moments like that?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_gratitude_3",
            question: "Who or what supported you emotionally today?",
            category: .gratitude,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["supported", "helped", "there", "friend", "family"],
            followUps: ["How did that support feel?", "What would you want them to know?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_gratitude_4",
            question: "What's one thing about yourself you're grateful for today?",
            category: .gratitude,
            timeOfDay: .evening,
            conversationStyle: .supportive,
            followUpTriggers: ["strength", "resilience", "kindness", "effort", "trying"],
            followUps: ["How did that quality show up for you today?", "What does it mean to appreciate that about yourself?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_gratitude_5",
            question: "What unexpected gift did today bring you?",
            category: .gratitude,
            timeOfDay: .evening,
            conversationStyle: .curious,
            followUpTriggers: ["unexpected", "surprise", "gift", "blessing"],
            followUps: ["How did that surprise feel?", "What made it feel like a gift?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_gratitude_6",
            question: "What's something simple that made you feel good today?",
            category: .gratitude,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["simple", "good", "nice", "pleasant", "comfort"],
            followUps: ["What is it about simple things that can feel so meaningful?", "How can you invite more of that simplicity in?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_gratitude_7",
            question: "Looking at today, what are you most thankful your heart experienced?",
            category: .gratitude,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["heart", "experienced", "felt", "thankful"],
            followUps: ["What made that experience meaningful for your heart?", "How does gratitude feel in your body right now?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "e_gratitude_8",
            question: "What's one way today reminded you of what matters most?",
            category: .gratitude,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["matters", "important", "values", "priorities"],
            followUps: ["How does it feel to be reminded of that?", "What does that tell you about what you need?"],
            emotionalTone: .warm
        ),
        
        // Evening - Processing (12 prompts)
        ConversationPrompt(
            id: "e_processing_1",
            question: "How are you feeling as the day comes to a close?",
            category: .openEnded,
            timeOfDay: .evening,
            conversationStyle: .supportive,
            followUpTriggers: ["tired", "satisfied", "worried", "peaceful", "heavy"],
            followUps: ["What do you need right now?", "How can you honor that feeling?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "e_processing_2",
            question: "What emotions are you carrying into the evening?",
            category: .openEnded,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["carrying", "heavy", "light", "mixed", "complex"],
            followUps: ["Which ones feel ready to be released?", "Which ones do you want to keep close?"],
            emotionalTone: .calm
        ),
        
        ConversationPrompt(
            id: "e_processing_3",
            question: "If you could give today's emotions a gentle place to rest, what would that look like?",
            category: .coping,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["rest", "gentle", "place", "safe", "peaceful"],
            followUps: ["What would help create that resting place?", "How can you offer yourself that gentleness?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "e_processing_4",
            question: "What would you like to leave behind from today?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .supportive,
            followUpTriggers: ["leave", "behind", "release", "let go", "done"],
            followUps: ["What would it feel like to let that go?", "What ritual or action might help you release it?"],
            emotionalTone: .calm
        ),
        
        ConversationPrompt(
            id: "e_processing_5",
            question: "How do you want to end today emotionally?",
            category: .future,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["end", "close", "finish", "peaceful", "complete"],
            followUps: ["What would help you feel that way?", "What does a good emotional ending look like for you?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_processing_6",
            question: "What does your heart need to hear before you sleep?",
            category: .coping,
            timeOfDay: .evening,
            conversationStyle: .supportive,
            followUpTriggers: ["heart", "need", "hear", "comfort", "reassurance"],
            followUps: ["Can you offer your heart those words?", "What would it mean to give yourself that message?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "e_processing_7",
            question: "If today's emotions could send you a message of love, what would it be?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["love", "message", "compassion", "understanding"],
            followUps: ["How does receiving that message feel?", "What does it mean to love all parts of your emotional experience?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "e_processing_8",
            question: "What are you most proud of about how you handled your emotions today?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .supportive,
            followUpTriggers: ["proud", "handled", "managed", "coped", "survived"],
            followUps: ["What strength did that take?", "How can you celebrate that accomplishment?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_processing_9",
            question: "As you prepare for rest, what would help your mind and heart feel peaceful?",
            category: .coping,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["peaceful", "rest", "calm", "quiet", "still"],
            followUps: ["What usually helps you find that peace?", "How can you create space for that tonight?"],
            emotionalTone: .calm
        ),
        
        ConversationPrompt(
            id: "e_processing_10",
            question: "What emotion from today deserves the most compassion?",
            category: .reflective,
            timeOfDay: .evening,
            conversationStyle: .supportive,
            followUpTriggers: ["compassion", "kindness", "understanding", "difficult"],
            followUps: ["What would compassion for that emotion look like?", "How can you offer yourself that compassion now?"],
            emotionalTone: .empathetic
        ),
        
        ConversationPrompt(
            id: "e_processing_11",
            question: "If you could wrap today's emotional journey in gratitude, what would you be thankful for?",
            category: .gratitude,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["journey", "grateful", "thankful", "growth", "learning"],
            followUps: ["What made that journey meaningful?", "How does gratitude change how you see today's emotions?"],
            emotionalTone: .warm
        ),
        
        ConversationPrompt(
            id: "e_processing_12",
            question: "What would you want to tell tomorrow's version of yourself about today's feelings?",
            category: .future,
            timeOfDay: .evening,
            conversationStyle: .gentle,
            followUpTriggers: ["tomorrow", "tell", "advice", "wisdom", "remember"],
            followUps: ["What wisdom did today's emotions teach you?", "How can you carry that learning forward?"],
            emotionalTone: .warm
        )
    ]
    
    // MARK: - Helper Methods
    
    static func getRandomPrompt(for timeOfDay: TimeContext) -> ConversationPrompt? {
        let timePrompts = allPrompts.filter { $0.timeOfDay == timeOfDay }
        return timePrompts.randomElement()
    }
    
    static func getPromptsForCategory(_ category: ConversationPrompt.PromptCategory, 
                                    timeOfDay: TimeContext) -> [ConversationPrompt] {
        return allPrompts.filter { 
            $0.category == category && $0.timeOfDay == timeOfDay 
        }
    }
    
    static func getPromptsForStyle(_ style: ConversationPrompt.ConversationStyle) -> [ConversationPrompt] {
        return allPrompts.filter { $0.conversationStyle == style }
    }
    
    static func getPromptsForTone(_ tone: ConversationPrompt.EmotionalTone) -> [ConversationPrompt] {
        return allPrompts.filter { $0.emotionalTone == tone }
    }
    
    static func getPromptById(_ id: String) -> ConversationPrompt? {
        return allPrompts.first { $0.id == id }
    }
    
    static var promptCount: Int {
        return allPrompts.count
    }
    
    static var morningPrompts: [ConversationPrompt] {
        return allPrompts.filter { $0.timeOfDay == .morning }
    }
    
    static var afternoonPrompts: [ConversationPrompt] {
        return allPrompts.filter { $0.timeOfDay == .afternoon }
    }
    
    static var eveningPrompts: [ConversationPrompt] {
        return allPrompts.filter { $0.timeOfDay == .evening }
    }
    
    // MARK: - Statistics
    
    static var promptStatistics: PromptStatistics {
        let total = allPrompts.count
        let morning = morningPrompts.count
        let afternoon = afternoonPrompts.count
        let evening = eveningPrompts.count
        
        let categoryBreakdown = Dictionary(grouping: allPrompts, by: { $0.category })
            .mapValues { $0.count }
        
        let styleBreakdown = Dictionary(grouping: allPrompts, by: { $0.conversationStyle })
            .mapValues { $0.count }
        
        let toneBreakdown = Dictionary(grouping: allPrompts, by: { $0.emotionalTone })
            .mapValues { $0.count }
        
        return PromptStatistics(
            totalPrompts: total,
            morningCount: morning,
            afternoonCount: afternoon,
            eveningCount: evening,
            categoryBreakdown: categoryBreakdown,
            styleBreakdown: styleBreakdown,
            toneBreakdown: toneBreakdown
        )
    }
}

// MARK: - Supporting Types

struct PromptStatistics {
    let totalPrompts: Int
    let morningCount: Int
    let afternoonCount: Int
    let eveningCount: Int
    let categoryBreakdown: [ConversationPrompt.PromptCategory: Int]
    let styleBreakdown: [ConversationPrompt.ConversationStyle: Int]
    let toneBreakdown: [ConversationPrompt.EmotionalTone: Int]
    
    var timeDistribution: String {
        return "Morning: \(morningCount), Afternoon: \(afternoonCount), Evening: \(eveningCount)"
    }
    
    var mostCommonCategory: ConversationPrompt.PromptCategory? {
        return categoryBreakdown.max(by: { $0.value < $1.value })?.key
    }
    
    var mostCommonStyle: ConversationPrompt.ConversationStyle? {
        return styleBreakdown.max(by: { $0.value < $1.value })?.key
    }
    
    var mostCommonTone: ConversationPrompt.EmotionalTone? {
        return toneBreakdown.max(by: { $0.value < $1.value })?.key
    }
}
