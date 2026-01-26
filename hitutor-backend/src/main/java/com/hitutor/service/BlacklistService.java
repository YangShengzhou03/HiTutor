package com.hitutor.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hitutor.entity.Blacklist;
import com.hitutor.entity.User;
import com.hitutor.repository.BlacklistRepository;
import com.hitutor.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class BlacklistService {

    @Autowired
    private BlacklistRepository blacklistRepository;

    @Autowired
    private UserService userService;

    public Page<Blacklist> getAllBlacklist(int page, int size) {
        QueryWrapper<Blacklist> queryWrapper = new QueryWrapper<>();
        Page<Blacklist> pageParam = new Page<>(page, size);
        Page<Blacklist> result = blacklistRepository.selectPage(pageParam, queryWrapper);
        
        for (Blacklist entry : result.getRecords()) {
            User blockedUser = userService.getUserById(entry.getBlockedUserId());
            if (blockedUser != null) {
                entry.setBlockedUser(blockedUser);
            }
        }
        
        return result;
    }

    public List<Blacklist> getUserBlacklist(String userId) {
        List<Blacklist> blacklist = blacklistRepository.findByUserId(userId);
        for (Blacklist entry : blacklist) {
            User blockedUser = userService.getUserById(entry.getBlockedUserId());
            if (blockedUser != null) {
                entry.setBlockedUser(blockedUser);
            }
        }
        return blacklist;
    }

    public Blacklist getBlacklistEntry(String userId, String blockedUserId) {
        return blacklistRepository.findByUserIdAndBlockedUserId(userId, blockedUserId);
    }

    public boolean isBlocked(String userId, String blockedUserId) {
        return blacklistRepository.existsByUserIdAndBlockedUserId(userId, blockedUserId);
    }

    @Transactional
    public Blacklist addToBlacklist(String userId, String blockedUserId) {
        if (isBlocked(userId, blockedUserId)) {
            throw new RuntimeException("用户已在黑名单中");
        }
        
        Blacklist blacklist = new Blacklist();
        blacklist.setUserId(userId);
        blacklist.setBlockedUserId(blockedUserId);
        blacklistRepository.insert(blacklist);
        return blacklist;
    }

    @Transactional
    public boolean removeFromBlacklist(String userId, String blockedUserId) {
        if (!isBlocked(userId, blockedUserId)) {
            return false;
        }
        
        blacklistRepository.deleteByUserIdAndBlockedUserId(userId, blockedUserId);
        return true;
    }

    @Transactional
    public boolean deleteBlacklistEntry(Long id) {
        return blacklistRepository.deleteById(id) > 0;
    }
}