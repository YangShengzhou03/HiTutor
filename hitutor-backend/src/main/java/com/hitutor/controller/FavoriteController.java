package com.hitutor.controller;

import com.hitutor.entity.Favorite;
import com.hitutor.entity.TutorProfile;
import com.hitutor.entity.StudentRequest;
import com.hitutor.entity.User;
import com.hitutor.service.FavoriteService;
import com.hitutor.service.TutorProfileService;
import com.hitutor.service.StudentRequestService;
import com.hitutor.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/favorites")
public class FavoriteController {

    @Autowired
    private FavoriteService favoriteService;

    @Autowired
    private UserService userService;

    @Autowired
    private TutorProfileService tutorProfileService;

    @Autowired
    private StudentRequestService studentRequestService;

    @PostMapping
    public ResponseEntity<Map<String, Object>> addFavorite(@RequestBody Favorite favorite) {
        try {
            boolean added = favoriteService.addFavorite(favorite);
            if (added) {
                Map<String, Object> response = new java.util.HashMap<>();
                response.put("success", true);
                response.put("message", "收藏成功");
                response.put("data", favorite);
                return ResponseEntity.status(HttpStatus.CREATED).body(response);
            } else {
                Map<String, Object> response = new java.util.HashMap<>();
                response.put("success", false);
                response.put("message", "收藏失败");
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
            }
        } catch (Exception e) {
            Map<String, Object> response = new java.util.HashMap<>();
            if (e.getMessage() != null && e.getMessage().contains("uk_user_target")) {
                response.put("success", false);
                response.put("message", "您已经收藏过该内容");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }
            response.put("success", false);
            response.put("message", "收藏失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @DeleteMapping
    public ResponseEntity<Map<String, Object>> removeFavorite(
            @RequestParam String userId,
            @RequestParam String targetId,
            @RequestParam String targetType) {
        Long targetIdLong = null;
        try {
            targetIdLong = Long.parseLong(targetId);
        } catch (NumberFormatException e) {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", false);
            response.put("message", "目标ID格式错误");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
        boolean removed = favoriteService.removeFavorite(userId, targetIdLong, targetType);
        if (removed) {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", true);
            response.put("message", "取消收藏成功");
            return ResponseEntity.ok(response);
        } else {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", false);
            response.put("message", "取消收藏失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getFavoritesByUserId(@PathVariable String userId) {
        List<Favorite> favorites = favoriteService.getFavoritesByUserId(userId);
        List<Map<String, Object>> enrichedFavorites = new ArrayList<>();
        
        for (Favorite favorite : favorites) {
            Map<String, Object> favoriteMap = new HashMap<>();
            favoriteMap.put("id", favorite.getId());
            favoriteMap.put("userId", favorite.getUserId());
            favoriteMap.put("targetId", favorite.getTargetId());
            favoriteMap.put("targetType", favorite.getTargetType());
            favoriteMap.put("createTime", favorite.getCreateTime());
            
            Map<String, Object> targetData = new HashMap<>();
            
            if ("tutor_profile".equals(favorite.getTargetType()) || "tutor".equals(favorite.getTargetType())) {
                TutorProfile profile = tutorProfileService.getById(favorite.getTargetId());
                if (profile != null) {
                    User user = userService.getUserById(profile.getUserId());
                    if (user != null) {
                        targetData.put("username", user.getUsername());
                        targetData.put("userId", user.getId());
                        targetData.put("isVerified", user.getIsVerified() != null ? user.getIsVerified() : false);
                        targetData.put("badge", user.getBadge());
                        targetData.put("gender", user.getGender());
                    }
                    targetData.put("subjectName", profile.getSubjectName());
                    targetData.put("hourlyRate", profile.getHourlyRate());
                }
            } else if ("student_request".equals(favorite.getTargetType())) {
                StudentRequest request = studentRequestService.getById(favorite.getTargetId());
                if (request != null) {
                    User user = userService.getUserById(request.getUserId());
                    if (user != null) {
                        targetData.put("username", user.getUsername());
                        targetData.put("userId", user.getId());
                        targetData.put("isVerified", user.getIsVerified() != null ? user.getIsVerified() : false);
                        targetData.put("badge", user.getBadge());
                        targetData.put("gender", user.getGender());
                    }
                    targetData.put("subjectName", request.getSubjectName());
                    targetData.put("childGrade", request.getChildGrade());
                    targetData.put("hourlyRateMin", request.getHourlyRateMin());
                    targetData.put("hourlyRateMax", request.getHourlyRateMax());
                }
            }
            
            favoriteMap.put("target", targetData);
            enrichedFavorites.add(favoriteMap);
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取收藏列表成功");
        response.put("data", enrichedFavorites);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/check")
    public ResponseEntity<Map<String, Object>> checkFavorite(
            @RequestParam String userId,
            @RequestParam String targetId,
            @RequestParam String targetType) {
        Long targetIdLong = null;
        try {
            targetIdLong = Long.parseLong(targetId);
        } catch (NumberFormatException e) {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", false);
            response.put("message", "目标ID格式错误");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
        boolean isFavorite = favoriteService.isFavorite(userId, targetIdLong, targetType);
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "查询成功");
        response.put("data", isFavorite);
        return ResponseEntity.ok(response);
    }
}
