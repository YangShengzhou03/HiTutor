package com.hitutor.controller;

import com.hitutor.dto.StudentRequestDTO;
import com.hitutor.entity.StudentRequest;
import com.hitutor.entity.User;
import com.hitutor.service.StudentRequestService;
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
@RequestMapping("/api/student-requests")
@SuppressWarnings("unchecked")
public class StudentRequestController {

    @Autowired
    private StudentRequestService studentRequestService;

    @Autowired
    private UserService userService;

    @PostMapping
    public ResponseEntity<Map<String, Object>> createStudentRequest(@RequestBody Map<String, Object> request) {
        String userId = (String) request.get("userId");
        Map<String, Object> response = new HashMap<>();
        
        if (userId == null || userId.isEmpty()) {
            response.put("success", false);
            response.put("message", "用户未登录");
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
            response.put("message", "账号已被禁用，无法发布学生需求");
            return ResponseEntity.status(403).body(response);
        }
        
        request.put("userId", userId);
        try {
            StudentRequest studentRequest = studentRequestService.createStudentRequest(request);
            if (studentRequest == null) {
                response.put("success", false);
                response.put("message", "创建学生需求失败");
                return ResponseEntity.badRequest().body(response);
            }
            response.put("success", true);
            response.put("message", "创建学生需求成功");
            response.put("data", DtoConverter.toStudentRequestDTO(studentRequest, user));
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "系统错误，请稍后重试");
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/nearby")
    public ResponseEntity<Map<String, Object>> getNearbyRequests(
            @RequestParam double latitude,
            @RequestParam double longitude,
            @RequestParam(defaultValue = "10") double radius,
            @RequestParam(required = false) String subject) {
        List<StudentRequest> requests = studentRequestService.getNearbyRequests(latitude, longitude, radius, subject);
        List<StudentRequestDTO> requestDTOs = requests.stream()
                .map(request -> {
                    User user = userService.getUserById(request.getUserId());
                    return DtoConverter.toStudentRequestDTO(request, user);
                })
                .collect(Collectors.toList());
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "获取附近学生需求成功");
        response.put("data", requestDTOs);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllStudentRequests(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Map<String, Object> result = studentRequestService.getAllStudentRequests(page, size);
        List<StudentRequest> requests = (List<StudentRequest>) result.get("content");
        List<StudentRequestDTO> requestDTOs = requests.stream()
                .map(request -> {
                    User user = userService.getUserById(request.getUserId());
                    return DtoConverter.toStudentRequestDTO(request, user);
                })
                .collect(Collectors.toList());
        result.put("content", requestDTOs);
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "获取学生需求列表成功");
        response.put("data", result);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getStudentRequest(@PathVariable Long id) {
        StudentRequest request = studentRequestService.getById(id);
        if (request == null) {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", false);
            response.put("message", "学生需求不存在");
            response.put("data", null);
            return ResponseEntity.status(org.springframework.http.HttpStatus.NOT_FOUND).body(response);
        }
        User user = userService.getUserById(request.getUserId());
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "获取学生需求成功");
        response.put("data", DtoConverter.toStudentRequestDTO(request, user));
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateStudentRequest(@PathVariable Long id, @RequestBody StudentRequest request) {
        request.setId(id);
        boolean updated = studentRequestService.updateStudentRequest(request);
        if (!updated) {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", false);
            response.put("message", "学生需求不存在");
            response.put("data", null);
            return ResponseEntity.status(org.springframework.http.HttpStatus.NOT_FOUND).body(response);
        }
        User user = userService.getUserById(request.getUserId());
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "更新学生需求成功");
        response.put("data", DtoConverter.toStudentRequestDTO(request, user));
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteStudentRequest(@PathVariable Long id) {
        boolean deleted = studentRequestService.deleteStudentRequest(id);
        if (!deleted) {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", false);
            response.put("message", "学生需求不存在");
            response.put("data", null);
            return ResponseEntity.status(org.springframework.http.HttpStatus.NOT_FOUND).body(response);
        }
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "删除学生需求成功");
        response.put("data", null);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user")
    public ResponseEntity<Map<String, Object>> getUserRequests(
            @RequestParam(required = false) String userId) {
        if (userId == null || userId.isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "未授权");
            return ResponseEntity.status(401).body(response);
        }
        
        List<StudentRequest> requests = studentRequestService.getRequestsByUserId(userId);
        List<StudentRequestDTO> requestDTOs = requests.stream()
                .map(request -> {
                    User user = userService.getUserById(request.getUserId());
                    return DtoConverter.toStudentRequestDTO(request, user);
                })
                .collect(Collectors.toList());
        Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("content", requestDTOs);
        dataMap.put("totalElements", requestDTOs.size());
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取我的需求成功");
        response.put("data", dataMap);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getRequestsByUserId(@PathVariable String userId) {
        List<StudentRequest> requests = studentRequestService.getRequestsByUserId(userId);
        List<StudentRequestDTO> requestDTOs = requests.stream()
                .map(request -> {
                    User user = userService.getUserById(request.getUserId());
                    return DtoConverter.toStudentRequestDTO(request, user);
                })
                .collect(Collectors.toList());
        Map<String, Object> dataMap = new java.util.HashMap<>();
        dataMap.put("content", requestDTOs);
        dataMap.put("totalElements", requestDTOs.size());
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "获取用户需求成功");
        response.put("data", dataMap);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchStudentRequests(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String subject) {
        Map<String, Object> result = studentRequestService.searchStudentRequests(q, page, size, subject);
        List<StudentRequest> requests = (List<StudentRequest>) result.get("content");
        List<StudentRequestDTO> requestDTOs = requests.stream()
                .map(request -> {
                    User user = userService.getUserById(request.getUserId());
                    return DtoConverter.toStudentRequestDTO(request, user);
                })
                .collect(Collectors.toList());
        result.put("content", requestDTOs);
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "搜索学生需求成功");
        response.put("data", result);
        return ResponseEntity.ok(response);
    }
}