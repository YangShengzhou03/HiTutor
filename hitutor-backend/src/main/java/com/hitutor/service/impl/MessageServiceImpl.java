package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hitutor.entity.Conversation;
import com.hitutor.mapper.ConversationMapper;
import com.hitutor.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class MessageServiceImpl extends ServiceImpl<ConversationMapper, Conversation> implements MessageService {

    @Override
    public List<Map<String, Object>> getConversationsByUserId(String userId) {
        QueryWrapper<Conversation> wrapper = new QueryWrapper<>();
        wrapper.and(w -> w.eq("user1_id", userId).or().eq("user2_id", userId));
        wrapper.orderByDesc("last_message_time");
        
        List<Conversation> conversations = baseMapper.selectList(wrapper);
        
        List<Map<String, Object>> result = new ArrayList<>();
        for (Conversation conv : conversations) {
            Map<String, Object> convMap = new HashMap<>();
            convMap.put("id", conv.getId());
            convMap.put("user1Id", conv.getUser1Id());
            convMap.put("user2Id", conv.getUser2Id());
            convMap.put("lastMessageTime", conv.getLastMessageTime());
            result.add(convMap);
        }
        
        return result;
    }

    @Override
    @Transactional
    public Conversation createConversation(String user1Id, String user2Id) {
        QueryWrapper<Conversation> wrapper = new QueryWrapper<>();
        wrapper.and(w -> w.eq("user1_id", user1Id).eq("user2_id", user2Id))
               .or(w -> w.eq("user1_id", user2Id).eq("user2_id", user1Id));
        
        Conversation existingConv = baseMapper.selectOne(wrapper);
        if (existingConv != null) {
            return existingConv;
        }
        
        Conversation conversation = new Conversation();
        conversation.setUser1Id(user1Id);
        conversation.setUser2Id(user2Id);
        conversation.setLastMessageTime(LocalDateTime.now());
        conversation.setCreateTime(LocalDateTime.now());
        
        baseMapper.insert(conversation);
        return conversation;
    }

    @Override
    @Transactional
    public void updateConversation(Conversation conversation) {
        baseMapper.updateById(conversation);
    }
}
