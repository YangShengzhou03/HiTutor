package com.hitutor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hitutor.entity.Notification;

import java.util.List;

public interface NotificationService extends IService<Notification> {
    Notification createNotification(Notification notification);
    boolean markAsRead(Long notificationId);
    boolean markAllAsRead(String userId);
    List<Notification> getUserNotifications(String userId, Integer page, Integer size);
    int getUnreadCount(String userId);
    boolean deleteNotification(Long notificationId);
    List<Notification> getAllNotifications(Integer page, Integer size);
}
