package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hitutor.entity.Review;
import com.hitutor.entity.Notification;
import com.hitutor.mapper.ReviewMapper;
import com.hitutor.service.ReviewService;
import com.hitutor.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ReviewServiceImpl extends ServiceImpl<ReviewMapper, Review> implements ReviewService {

    @Autowired
    private NotificationService notificationService;

    @Override
    public List<Review> getReviewsByTutorId(String tutorId) {
        QueryWrapper<Review> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("reviewed_id", tutorId);
        queryWrapper.orderByDesc("create_time");
        return this.list(queryWrapper);
    }

    @Override
    public List<Review> getReviewsByUserId(String userId) {
        QueryWrapper<Review> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("reviewer_id", userId);
        queryWrapper.orderByDesc("create_time");
        return this.list(queryWrapper);
    }

    @Override
    public Review createReview(Map<String, Object> request) {
        Review review = new Review();
        
        if (request.containsKey("appointmentId")) {
            try {
                review.setAppointmentId(Long.parseLong(request.get("appointmentId").toString()));
            } catch (NumberFormatException e) {
            }
        }
        if (request.containsKey("reviewerId")) {
            review.setReviewerId(request.get("reviewerId").toString());
        }
        if (request.containsKey("reviewedId")) {
            review.setReviewedId(request.get("reviewedId").toString());
        }
        if (request.containsKey("rating")) {
            try {
                review.setRating(Integer.parseInt(request.get("rating").toString()));
            } catch (NumberFormatException e) {
            }
        }
        if (request.containsKey("comment")) {
            review.setComment(request.get("comment").toString());
        }
        
        review.setCreateTime(LocalDateTime.now());
        
        this.save(review);
        
        if (review.getReviewedId() != null && !review.getReviewedId().isEmpty()) {
            Notification notification = new Notification();
            notification.setUserId(review.getReviewedId());
            notification.setType("review");
            notification.setTitle("收到新的评价");
            notification.setContent("您收到了一条新的评价，评分：" + review.getRating());
            notification.setRelatedId(review.getId().toString());
            notification.setRelatedType("review");
            notification.setIsRead(0);
            notificationService.createNotification(notification);
        }
        
        return review;
    }

    @Override
    public Map<String, Object> getTutorRating(String tutorId) {
        QueryWrapper<Review> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("reviewed_id", tutorId);
        List<Review> reviews = this.list(queryWrapper);
        
        Map<String, Object> result = new HashMap<>();
        result.put("rating", 0.0);
        result.put("reviewCount", 0);
        
        if (reviews != null && !reviews.isEmpty()) {
            double totalRating = 0;
            for (Review review : reviews) {
                totalRating += review.getRating();
            }
            double averageRating = totalRating / reviews.size();
            result.put("rating", averageRating);
            result.put("reviewCount", reviews.size());
        }
        
        return result;
    }
}
