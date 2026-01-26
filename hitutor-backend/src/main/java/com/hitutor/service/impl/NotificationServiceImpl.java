package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hitutor.entity.Notification;
import com.hitutor.mapper.NotificationMapper;
import com.hitutor.service.NotificationService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotificationServiceImpl extends ServiceImpl<NotificationMapper, Notification> implements NotificationService {

    @Override
    public Notification createNotification(Notification notification) {
        baseMapper.insert(notification);
        return notification;
    }

    @Override
    public boolean markAsRead(Long notificationId) {
        Notification notification = baseMapper.selectById(notificationId);
        if (notification == null) {
            return false;
        }
        notification.setIsRead(1);
        return baseMapper.updateById(notification) > 0;
    }

    @Override
    public boolean markAllAsRead(String userId) {
        QueryWrapper<Notification> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId).eq("is_read", 0);
        
        List<Notification> notifications = baseMapper.selectList(queryWrapper);
        for (Notification notification : notifications) {
            notification.setIsRead(1);
            baseMapper.updateById(notification);
        }
        return true;
    }

    @Override
    public List<Notification> getUserNotifications(String userId, Integer page, Integer size) {
        QueryWrapper<Notification> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId).orderByDesc("create_time");
        
        Page<Notification> pageObj = new Page<>(page, size);
        Page<Notification> resultPage = baseMapper.selectPage(pageObj, queryWrapper);
        return resultPage.getRecords();
    }

    @Override
    public int getUnreadCount(String userId) {
        QueryWrapper<Notification> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId).eq("is_read", 0);
        return baseMapper.selectCount(queryWrapper).intValue();
    }

    @Override
    public boolean deleteNotification(Long notificationId) {
        return baseMapper.deleteById(notificationId) > 0;
    }

    @Override
    public List<Notification> getAllNotifications(Integer page, Integer size) {
        QueryWrapper<Notification> queryWrapper = new QueryWrapper<>();
        queryWrapper.orderByDesc("create_time");
        
        Page<Notification> pageObj = new Page<>(page, size);
        Page<Notification> resultPage = baseMapper.selectPage(pageObj, queryWrapper);
        return resultPage.getRecords();
    }
}
