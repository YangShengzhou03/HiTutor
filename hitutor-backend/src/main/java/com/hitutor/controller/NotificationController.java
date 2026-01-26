package com.hitutor.controller;

import com.hitutor.entity.Notification;
import com.hitutor.service.NotificationService;
import com.hitutor.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private UserService userService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getUserNotifications(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "未授权");
            return ResponseEntity.status(401).body(response);
        }
        
        String userId = authentication.getName();
        List<Notification> notifications = notificationService.getUserNotifications(userId, page, size);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取通知列表成功");
        response.put("data", notifications);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Object>> getUnreadCount() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "未授权");
            return ResponseEntity.status(401).body(response);
        }
        
        String userId = authentication.getName();
        int unreadCount = notificationService.getUnreadCount(userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取未读数量成功");
        response.put("data", unreadCount);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Map<String, Object>> markAsRead(@PathVariable Long id) {
        boolean updated = notificationService.markAsRead(id);
        if (!updated) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "通知不存在");
            return ResponseEntity.status(404).body(response);
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "标记已读成功");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/read-all")
    public ResponseEntity<Map<String, Object>> markAllAsRead() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "未授权");
            return ResponseEntity.status(401).body(response);
        }
        
        String userId = authentication.getName();
        notificationService.markAllAsRead(userId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "全部标记已读成功");
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteNotification(@PathVariable Long id) {
        boolean deleted = notificationService.deleteNotification(id);
        if (!deleted) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "通知不存在");
            return ResponseEntity.status(404).body(response);
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "删除通知成功");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/admin/send")
    @PreAuthorize("hasRole('admin')")
    public ResponseEntity<Map<String, Object>> sendNotification(@RequestBody Map<String, Object> request) {
        String userId = request.get("userId") != null ? request.get("userId").toString() : null;
        String title = request.get("title") != null ? request.get("title").toString() : null;
        String content = request.get("content") != null ? request.get("content").toString() : null;
        String type = request.get("type") != null ? request.get("type").toString() : "system";
        
        if (title == null || title.trim().isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "通知标题不能为空");
            return ResponseEntity.status(400).body(response);
        }
        
        if (content == null || content.trim().isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "通知内容不能为空");
            return ResponseEntity.status(400).body(response);
        }
        
        if (userId != null && !userId.trim().isEmpty()) {
            Notification notification = new Notification();
            notification.setUserId(userId);
            notification.setType(type);
            notification.setTitle(title);
            notification.setContent(content);
            notification.setIsRead(0);
            notificationService.createNotification(notification);
        } else {
            List<String> allUserIds = userService.getAllUserIds();
            for (String uid : allUserIds) {
                Notification notification = new Notification();
                notification.setUserId(uid);
                notification.setType(type);
                notification.setTitle(title);
                notification.setContent(content);
                notification.setIsRead(0);
                notificationService.createNotification(notification);
            }
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", (userId != null && !userId.trim().isEmpty()) ? "发送通知成功" : "群发通知成功");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/admin/list")
    @PreAuthorize("hasRole('admin')")
    public ResponseEntity<Map<String, Object>> getAllNotifications(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        List<Notification> notifications = notificationService.getAllNotifications(page, size);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取通知列表成功");
        
        Map<String, Object> data = new HashMap<>();
        data.put("content", notifications);
        data.put("totalElements", notifications.size());
        response.put("data", data);
        
        return ResponseEntity.ok(response);
    }
}
