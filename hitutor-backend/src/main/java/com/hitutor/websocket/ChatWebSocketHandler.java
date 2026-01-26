package com.hitutor.websocket;

import com.hitutor.document.ChatMessage;
import com.hitutor.entity.Conversation;
import com.hitutor.repository.ChatMessageRepository;
import com.hitutor.service.BlacklistService;
import com.hitutor.service.ConversationService;
import com.hitutor.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.util.HashMap;
import java.util.Map;

@Controller
public class ChatWebSocketHandler {

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private ConversationService conversationService;

    @Autowired
    private BlacklistService blacklistService;

    @Autowired
    private UserService userService;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat/send")
    @SendTo("/topic/messages")
    public Map<String, Object> sendMessage(Map<String, Object> messageData) {
        String senderId = (String) messageData.get("senderId");
        String receiverId = (String) messageData.get("receiverId");
        String content = (String) messageData.get("content");
        String messageType = (String) messageData.getOrDefault("messageType", "text");

        Map<String, Object> response = new HashMap<>();

        if (senderId == null || receiverId == null || content == null) {
            response.put("success", false);
            response.put("message", "参数不完整");
            return response;
        }

        if (blacklistService.isBlocked(senderId, receiverId)) {
            response.put("success", false);
            response.put("message", "您已被对方拉黑，无法发送消息");
            return response;
        }

        Conversation conversation = conversationService.getOrCreateConversation(senderId, receiverId);
        if (conversation == null) {
            response.put("success", false);
            response.put("message", "会话创建失败");
            return response;
        }

        ChatMessage chatMessage = new ChatMessage(
            conversation.getId().toString(),
            senderId,
            receiverId,
            content,
            messageType
        );

        chatMessage = chatMessageRepository.save(chatMessage);

        conversation.setLastMessageTime(chatMessage.getCreateTime());
        conversationService.updateConversation(conversation);

        Map<String, Object> messageMap = new HashMap<>();
        messageMap.put("id", chatMessage.getId());
        messageMap.put("conversationId", chatMessage.getConversationId());
        messageMap.put("senderId", chatMessage.getSenderId());
        messageMap.put("receiverId", chatMessage.getReceiverId());
        messageMap.put("content", chatMessage.getContent());
        messageMap.put("messageType", chatMessage.getMessageType());
        messageMap.put("isRead", chatMessage.getIsRead());
        messageMap.put("createTime", chatMessage.getCreateTime());

        response.put("success", true);
        response.put("message", "消息发送成功");
        response.put("data", messageMap);

        messagingTemplate.convertAndSendToUser(
            receiverId,
            "/queue/messages",
            response
        );

        return response;
    }

    @MessageMapping("/chat/read")
    public void markAsRead(Map<String, Object> messageData) {
        String conversationId = (String) messageData.get("conversationId");
        String userId = (String) messageData.get("userId");

        if (conversationId != null && userId != null) {
            chatMessageRepository.findByConversationIdOrderByCreateTimeAsc(conversationId)
                .stream()
                .filter(msg -> msg.getReceiverId().equals(userId) && !msg.getIsRead())
                .forEach(msg -> {
                    msg.setIsRead(true);
                    chatMessageRepository.save(msg);
                });
        }
    }
}
