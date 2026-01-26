package com.hitutor.controller;

import com.hitutor.dto.ReviewDTO;
import com.hitutor.entity.Review;
import com.hitutor.entity.User;
import com.hitutor.service.ReviewService;
import com.hitutor.service.UserService;
import com.hitutor.util.DtoConverter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    @Autowired
    private UserService userService;

    @GetMapping("/tutor/{tutorId}")
    public ResponseEntity<Map<String, Object>> getReviewsByTutorId(@PathVariable String tutorId) {
        List<Review> reviews = reviewService.getReviewsByTutorId(tutorId);
        List<ReviewDTO> reviewDTOs = reviews.stream()
                .map(review -> {
                    User reviewer = userService.getUserById(review.getReviewerId());
                    return DtoConverter.toReviewDTO(review, reviewer);
                })
                .collect(Collectors.toList());
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "获取评价成功");
        result.put("data", reviewDTOs);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getReviewsByUserId(@PathVariable String userId) {
        List<Review> reviews = reviewService.getReviewsByUserId(userId);
        List<ReviewDTO> reviewDTOs = reviews.stream()
                .map(review -> {
                    User reviewer = userService.getUserById(review.getReviewerId());
                    return DtoConverter.toReviewDTO(review, reviewer);
                })
                .collect(Collectors.toList());
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "获取评价成功");
        result.put("data", reviewDTOs);
        return ResponseEntity.ok(result);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createReview(@RequestBody Map<String, Object> request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();
        
        request.put("reviewerId", userId);
        
        Review review = reviewService.createReview(request);
        if (review == null) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "评价创建失败");
            return ResponseEntity.badRequest().body(result);
        }
        
        User reviewer = userService.getUserById(review.getReviewerId());
        ReviewDTO reviewDTO = DtoConverter.toReviewDTO(review, reviewer);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", reviewDTO);
        result.put("message", "评价成功");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getReviewById(@PathVariable Long id) {
        Review review = reviewService.getById(id);
        Map<String, Object> result = new HashMap<>();
        if (review == null) {
            result.put("success", false);
            result.put("message", "评价不存在");
            return ResponseEntity.status(404).body(result);
        }
        User reviewer = userService.getUserById(review.getReviewerId());
        result.put("success", true);
        result.put("message", "获取评价成功");
        result.put("data", DtoConverter.toReviewDTO(review, reviewer));
        return ResponseEntity.ok(result);
    }
}
