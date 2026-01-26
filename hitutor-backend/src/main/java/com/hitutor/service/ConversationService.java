package com.hitutor.service;

import com.hitutor.entity.Conversation;

public interface ConversationService {
    Conversation getOrCreateConversation(String user1Id, String user2Id);
    Conversation getConversationById(Long id);
    Conversation getConversationByUsers(String user1Id, String user2Id);
    boolean updateConversation(Conversation conversation);
}
