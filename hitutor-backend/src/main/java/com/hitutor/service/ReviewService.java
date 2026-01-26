package com.hitutor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hitutor.entity.Review;
import java.util.List;
import java.util.Map;

public interface ReviewService extends IService<Review> {
    List<Review> getReviewsByTutorId(String tutorId);
    List<Review> getReviewsByUserId(String userId);
    Review createReview(Map<String, Object> request);
    Map<String, Object> getTutorRating(String tutorId);
}
