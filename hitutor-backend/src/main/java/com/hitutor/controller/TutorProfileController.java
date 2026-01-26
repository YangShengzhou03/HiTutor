package com.hitutor.controller;

import com.hitutor.dto.TutorProfileDTO;
import com.hitutor.entity.TutorProfile;
import com.hitutor.entity.User;
import com.hitutor.service.TutorProfileService;
import com.hitutor.service.UserService;
import com.hitutor.util.DtoConverter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/tutor-profiles")
public class TutorProfileController {

    @Autowired
    private TutorProfileService tutorProfileService;

    @Autowired
    private UserService userService;

    @PostMapping
    public ResponseEntity<Map<String, Object>> createTutorProfile(@RequestBody Map<String, Object> request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = null;
        Map<String, Object> response = new java.util.HashMap<>();
        
        if (authentication != null && authentication.isAuthenticated()) {
            userId = authentication.getName();
        }
        
        if (userId == null) {
            response.put("success", false);
            response.put("message", "未授权");
            return ResponseEntity.status(401).body(response);
        }
        
        User user = userService.getUserById(userId);
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(404).body(response);
        }
        
        if (!"active".equals(user.getStatus())) {
            response.put("success", false);
            response.put("message", "账号已被禁用，无法发布家教信息");
            return ResponseEntity.status(403).body(response);
        }
        
        request.put("userId", userId);
        TutorProfile profile = tutorProfileService.createTutorProfile(request);
        if (profile == null) {
            response.put("success", false);
            response.put("message", "创建家教信息失败");
            return ResponseEntity.badRequest().body(response);
        }
        
        response.put("success", true);
        response.put("message", "创建家教信息成功");
        response.put("data", DtoConverter.toTutorProfileDTO(profile, user));
        return ResponseEntity.ok(response);
    }

    @GetMapping("/nearby")
    public ResponseEntity<Map<String, Object>> getNearbyTutors(
            @RequestParam double latitude,
            @RequestParam double longitude,
            @RequestParam(defaultValue = "10") double radius,
            @RequestParam(required = false) String subject) {
        List<TutorProfile> profiles = tutorProfileService.getNearbyTutors(latitude, longitude, radius, subject);
        List<TutorProfileDTO> profileDTOs = profiles.stream()
                .map(profile -> {
                    User user = userService.getUserById(profile.getUserId());
                    return DtoConverter.toTutorProfileDTO(profile, user);
                })
                .collect(Collectors.toList());
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "获取附近家教成功");
        response.put("data", profileDTOs);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @SuppressWarnings("unchecked")
    public ResponseEntity<Map<String, Object>> getAllTutorProfiles(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Map<String, Object> result = tutorProfileService.getAllTutorProfiles(page, size);
        List<TutorProfile> profiles = (List<TutorProfile>) result.get("content");
        List<TutorProfileDTO> profileDTOs = profiles.stream()
                .map(profile -> {
                    User user = userService.getUserById(profile.getUserId());
                    return DtoConverter.toTutorProfileDTO(profile, user);
                })
                .collect(Collectors.toList());
        result.put("content", profileDTOs);
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "获取家教列表成功");
        response.put("data", result);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getTutorProfile(@PathVariable Long id) {
        TutorProfile profile = tutorProfileService.getById(id);
        Map<String, Object> response = new java.util.HashMap<>();
        
        if (profile == null) {
            response.put("success", false);
            response.put("message", "家教信息不存在");
            return ResponseEntity.status(org.springframework.http.HttpStatus.NOT_FOUND).body(response);
        }
        User user = userService.getUserById(profile.getUserId());
        
        response.put("success", true);
        response.put("message", "获取家教信息成功");
        response.put("data", DtoConverter.toTutorProfileDTO(profile, user));
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateTutorProfile(@PathVariable Long id, @RequestBody TutorProfile profile) {
        profile.setId(id);
        boolean updated = tutorProfileService.updateTutorProfile(profile);
        Map<String, Object> response = new java.util.HashMap<>();
        
        if (!updated) {
            response.put("success", false);
            response.put("message", "家教信息不存在");
            return ResponseEntity.status(org.springframework.http.HttpStatus.NOT_FOUND).body(response);
        }
        User user = userService.getUserById(profile.getUserId());
        
        response.put("success", true);
        response.put("message", "更新家教信息成功");
        response.put("data", DtoConverter.toTutorProfileDTO(profile, user));
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteTutorProfile(@PathVariable Long id) {
        boolean deleted = tutorProfileService.deleteTutorProfile(id);
        Map<String, Object> response = new java.util.HashMap<>();
        
        if (!deleted) {
            response.put("success", false);
            response.put("message", "家教信息不存在");
            return ResponseEntity.status(org.springframework.http.HttpStatus.NOT_FOUND).body(response);
        }
        
        response.put("success", true);
        response.put("message", "删除家教信息成功");
        response.put("data", null);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user")
    public ResponseEntity<Map<String, Object>> getUserProfiles(
            Authentication authentication) {
        String userId = authentication.getName();
        List<TutorProfile> profiles = tutorProfileService.getProfilesByUserId(userId);
        List<TutorProfileDTO> profileDTOs = profiles.stream()
                .map(profile -> {
                    User user = userService.getUserById(profile.getUserId());
                    return DtoConverter.toTutorProfileDTO(profile, user);
                })
                .collect(Collectors.toList());
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        result.put("message", "获取用户家教信息成功");
        
        Map<String, Object> dataMap = new java.util.HashMap<>();
        dataMap.put("content", profileDTOs);
        dataMap.put("totalElements", profileDTOs.size());
        
        result.put("data", dataMap);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getProfilesByUserId(@PathVariable String userId) {
        List<TutorProfile> profiles = tutorProfileService.getProfilesByUserId(userId);
        List<TutorProfileDTO> profileDTOs = profiles.stream()
                .map(profile -> {
                    User user = userService.getUserById(profile.getUserId());
                    return DtoConverter.toTutorProfileDTO(profile, user);
                })
                .collect(Collectors.toList());
        Map<String, Object> result = new java.util.HashMap<>();
        result.put("success", true);
        result.put("message", "获取用户家教信息成功");
        
        Map<String, Object> dataMap = new java.util.HashMap<>();
        dataMap.put("content", profileDTOs);
        dataMap.put("totalElements", profileDTOs.size());
        
        result.put("data", dataMap);
        return ResponseEntity.ok(result);
    }
}