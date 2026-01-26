package com.hitutor.service;

import com.hitutor.entity.Conversation;
import java.util.List;
import java.util.Map;

public interface MessageService {
    
    List<Map<String, Object>> getConversationsByUserId(String userId);
    
    Conversation createConversation(String user1Id, String user2Id);
    
    void updateConversation(Conversation conversation);
}
