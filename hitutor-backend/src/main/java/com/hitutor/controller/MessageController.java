package com.hitutor.controller;

import com.hitutor.document.ChatMessage;
import com.hitutor.entity.Conversation;
import com.hitutor.entity.Notification;
import com.hitutor.repository.ChatMessageRepository;
import com.hitutor.service.MessageService;
import com.hitutor.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/messages")
public class MessageController {

    @Autowired
    private MessageService messageService;

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private NotificationService notificationService;

    @GetMapping("/conversations")
    public ResponseEntity<Map<String, Object>> getConversations(
            @RequestParam String userId) {
        
        List<Map<String, Object>> conversations = messageService.getConversationsByUserId(userId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", conversations);
        
        return ResponseEntity.ok(result);
    }

    @GetMapping("/conversations/{sessionId}/messages")
    public ResponseEntity<Map<String, Object>> getMessagesBySessionId(
            @PathVariable String sessionId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        List<ChatMessage> allMessages = chatMessageRepository.findByConversationIdOrderByCreateTimeAsc(sessionId);
        
        int fromIndex = page * size;
        int toIndex = Math.min(fromIndex + size, allMessages.size());
        
        List<ChatMessage> messages = allMessages.subList(fromIndex, toIndex);
        
        List<Map<String, Object>> messageList = messages.stream()
                .map(msg -> {
                    Map<String, Object> messageMap = new HashMap<>();
                    messageMap.put("id", msg.getId());
                    messageMap.put("conversationId", msg.getConversationId());
                    messageMap.put("senderId", msg.getSenderId());
                    messageMap.put("receiverId", msg.getReceiverId());
                    messageMap.put("content", msg.getContent());
                    messageMap.put("messageType", msg.getMessageType());
                    messageMap.put("isRead", msg.getIsRead());
                    messageMap.put("createTime", msg.getCreateTime());
                    return messageMap;
                })
                .collect(Collectors.toList());
        
        int totalPages = (int) Math.ceil((double) allMessages.size() / size);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        
        Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("content", messageList);
        dataMap.put("totalElements", allMessages.size());
        dataMap.put("totalPages", totalPages);
        dataMap.put("currentPage", page);
        dataMap.put("size", size);
        
        result.put("data", dataMap);
        
        return ResponseEntity.ok(result);
    }

    @PostMapping("/conversations")
    public ResponseEntity<Map<String, Object>> createConversation(
            @RequestBody Map<String, String> request) {
        
        String user1Id = request.get("user1Id");
        String user2Id = request.get("user2Id");
        
        Conversation conversation = messageService.createConversation(user1Id, user2Id);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", conversation);
        result.put("message", "会话创建成功");
        
        return ResponseEntity.ok(result);
    }

    @PostMapping("/conversations/{sessionId}/messages")
    public ResponseEntity<Map<String, Object>> sendMessage(
            @PathVariable String sessionId,
            @RequestBody Map<String, Object> request) {
        
        String senderId = (String) request.get("senderId");
        String receiverId = (String) request.get("receiverId");
        String content = (String) request.get("content");
        String messageType = (String) request.getOrDefault("messageType", "text");
        
        ChatMessage chatMessage = new ChatMessage();
        chatMessage.setId(UUID.randomUUID().toString());
        chatMessage.setConversationId(sessionId);
        chatMessage.setSenderId(senderId);
        chatMessage.setReceiverId(receiverId);
        chatMessage.setContent(content);
        chatMessage.setMessageType(messageType);
        chatMessage.setIsRead(false);
        chatMessage.setCreateTime(LocalDateTime.now());
        
        chatMessageRepository.save(chatMessage);
        
        Conversation conversation = new Conversation();
        try {
            conversation.setId(Long.parseLong(sessionId));
        } catch (NumberFormatException e) {
        }
        conversation.setLastMessageTime(LocalDateTime.now());
        messageService.updateConversation(conversation);
        
        Notification notification = new Notification();
        notification.setUserId(receiverId);
        notification.setType("message");
        notification.setTitle("收到新消息");
        notification.setContent(content.length() > 50 ? content.substring(0, 50) + "..." : content);
        notification.setRelatedId(chatMessage.getId());
        notification.setRelatedType("message");
        notification.setIsRead(0);
        notificationService.createNotification(notification);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        
        Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("id", chatMessage.getId());
        dataMap.put("conversationId", chatMessage.getConversationId());
        dataMap.put("senderId", chatMessage.getSenderId());
        dataMap.put("receiverId", chatMessage.getReceiverId());
        dataMap.put("content", chatMessage.getContent());
        dataMap.put("messageType", chatMessage.getMessageType());
        dataMap.put("isRead", chatMessage.getIsRead());
        dataMap.put("createTime", chatMessage.getCreateTime());
        
        result.put("data", dataMap);
        result.put("message", "消息发送成功");
        
        return ResponseEntity.ok(result);
    }

    @PutMapping("/conversations/{sessionId}/read")
    public ResponseEntity<Map<String, Object>> markMessagesAsRead(
            @PathVariable String sessionId,
            @RequestParam String userId) {
        
        chatMessageRepository.findByConversationIdOrderByCreateTimeAsc(sessionId)
                .stream()
                .filter(msg -> msg.getReceiverId().equals(userId) && !msg.getIsRead())
                .forEach(msg -> {
                    msg.setIsRead(true);
                    chatMessageRepository.save(msg);
                });
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "消息已标记为已读");
        
        return ResponseEntity.ok(result);
    }
}
