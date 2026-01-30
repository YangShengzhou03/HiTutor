package com.hitutor.controller;

import com.hitutor.entity.Blacklist;
import com.hitutor.entity.User;
import com.hitutor.service.BlacklistService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/blacklist")
public class BlacklistController {

    @Autowired
    private BlacklistService blacklistService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getUserBlacklist(
            @RequestParam(required = false) String userId) {
        if (userId == null || userId.isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "用户未登录");
            return ResponseEntity.status(401).body(result);
        }
        List<Blacklist> blacklist = blacklistService.getUserBlacklist(userId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "获取黑名单成功");
        result.put("data", blacklist);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/admin/all")
    public ResponseEntity<Map<String, Object>> getAllBlacklist(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<Blacklist> blacklistPage = blacklistService.getAllBlacklist(page, size);
        
        Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("content", blacklistPage.getRecords());
        dataMap.put("total", blacklistPage.getTotal());
        dataMap.put("page", blacklistPage.getCurrent());
        dataMap.put("size", blacklistPage.getSize());

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "获取全量黑名单成功");
        result.put("data", dataMap);
        
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/admin/{id}")
    public ResponseEntity<Map<String, Object>> deleteBlacklistEntry(
            @PathVariable Long id) {
        boolean deleted = blacklistService.deleteBlacklistEntry(id);
        Map<String, Object> result = new HashMap<>();
        if (!deleted) {
            result.put("success", false);
            result.put("message", "记录不存在");
            return ResponseEntity.status(404).body(result);
        }
        result.put("success", true);
        result.put("message", "删除成功");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/check/{blockedUserId}")
    public ResponseEntity<Map<String, Object>> checkBlocked(
            @PathVariable String blockedUserId,
            @RequestParam(required = false) String userId) {
        if (userId == null || userId.isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "用户未登录");
            return ResponseEntity.status(401).body(result);
        }
        boolean isBlocked = blacklistService.isBlocked(userId, blockedUserId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "查询成功");
        result.put("data", isBlocked);
        return ResponseEntity.ok(result);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> addToBlacklist(
            @RequestBody Map<String, Object> request) {
        String userId = (String) request.get("userId");
        if (userId == null || userId.isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "用户未登录");
            return ResponseEntity.status(401).body(result);
        }
        try {
            String blockedUserId = ((String) request.get("blockedUserId"));
            
            Blacklist blacklist = blacklistService.addToBlacklist(
                userId,
                blockedUserId
            );
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("data", blacklist);
            result.put("message", "已添加到黑名单");
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(result);
        }
    }

    @DeleteMapping("/{blockedUserId}")
    public ResponseEntity<Map<String, Object>> removeFromBlacklist(
            @PathVariable String blockedUserId,
            @RequestParam(required = false) String userId) {
        if (userId == null || userId.isEmpty()) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "用户未登录");
            return ResponseEntity.status(401).body(result);
        }
        boolean removed = blacklistService.removeFromBlacklist(userId, blockedUserId);
        if (!removed) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "黑名单记录不存在");
            return ResponseEntity.badRequest().body(result);
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "已从黑名单移除");
        return ResponseEntity.ok(result);
    }
}