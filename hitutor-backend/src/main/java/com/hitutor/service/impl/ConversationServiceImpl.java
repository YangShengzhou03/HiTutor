package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.hitutor.entity.Conversation;
import com.hitutor.mapper.ConversationMapper;
import com.hitutor.service.ConversationService;
import com.hitutor.service.BlacklistService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class ConversationServiceImpl implements ConversationService {

    @Autowired
    private ConversationMapper conversationMapper;
    
    @Autowired
    private BlacklistService blacklistService;

    @Override
    public Conversation getOrCreateConversation(String user1Id, String user2Id) {
        if (blacklistService.isBlocked(user1Id, user2Id) || blacklistService.isBlocked(user2Id, user1Id)) {
            throw new RuntimeException("无法与黑名单用户创建会话");
        }
        
        QueryWrapper<Conversation> queryWrapper = new QueryWrapper<>();
        queryWrapper.and(wrapper -> wrapper
            .eq("user1_id", user1Id).eq("user2_id", user2Id)
            .or()
            .eq("user1_id", user2Id).eq("user2_id", user1Id)
        );

        Conversation conversation = conversationMapper.selectOne(queryWrapper);

        if (conversation == null) {
            conversation = new Conversation();
            conversation.setUser1Id(user1Id);
            conversation.setUser2Id(user2Id);
            conversation.setCreateTime(LocalDateTime.now());
            conversation.setLastMessageTime(LocalDateTime.now());
            conversationMapper.insert(conversation);
        }

        return conversation;
    }

    @Override
    public Conversation getConversationById(Long id) {
        return conversationMapper.selectById(id);
    }

    @Override
    public Conversation getConversationByUsers(String user1Id, String user2Id) {
        QueryWrapper<Conversation> queryWrapper = new QueryWrapper<>();
        queryWrapper.and(wrapper -> wrapper
            .eq("user1_id", user1Id).eq("user2_id", user2Id)
            .or()
            .eq("user1_id", user2Id).eq("user2_id", user1Id)
        );

        return conversationMapper.selectOne(queryWrapper);
    }

    @Override
    public boolean updateConversation(Conversation conversation) {
        return conversationMapper.updateById(conversation) > 0;
    }
}
