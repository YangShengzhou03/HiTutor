package com.hitutor.repository;

import com.hitutor.document.ChatMessage;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends MongoRepository<ChatMessage, String> {
    List<ChatMessage> findByConversationIdOrderByCreateTimeAsc(String conversationId);
    
    List<ChatMessage> findByReceiverIdAndIsReadFalseOrderByCreateTimeAsc(String receiverId);
    
    void deleteByConversationId(String conversationId);
}
