package com.hitutor.controller;

import com.hitutor.dto.UserDTO;
import com.hitutor.entity.User;
import com.hitutor.service.UserService;
import com.hitutor.util.DtoConverter;
import com.hitutor.util.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private PasswordUtil passwordUtil;

    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> getCurrentUser(@RequestParam(required = false) String userId) {
        Map<String, Object> response = new java.util.HashMap<>();
        
        if (userId == null || userId.isEmpty()) {
            response.put("success", false);
            response.put("message", "未授权");
            response.put("data", new java.util.HashMap<>());
            return ResponseEntity.status(401).body(response);
        }
        
        User user = userService.getUserById(userId);
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            response.put("data", new java.util.HashMap<>());
            return ResponseEntity.status(404).body(response);
        }
        
        response.put("success", true);
        response.put("message", "获取用户信息成功");
        response.put("data", DtoConverter.toUserDTO(user));
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getUser(@PathVariable String id) {
        User user = userService.getUserById(id);
        Map<String, Object> response = new java.util.HashMap<>();
        
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        response.put("success", true);
        response.put("message", "获取用户信息成功");
        response.put("data", DtoConverter.toUserDTO(user));
        return ResponseEntity.ok(response);
    }
    
    
    @PatchMapping("/{id}/role")
    public ResponseEntity<Map<String, Object>> updateUserRole(@PathVariable String id, @RequestBody Map<String, Object> userData) {
        Map<String, Object> response = new java.util.HashMap<>();
        
        User user = userService.getUserById(id);
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        if (userData.containsKey("role") || userData.containsKey("roleId")) {
            String newRole = (String) (userData.containsKey("role") ? 
                userData.get("role") : userData.get("roleId"));
            
            if ("admin".equals(user.getRole())) {
                response.put("success", false);
                response.put("message", "禁止修改管理员角色");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            if (!"student".equals(newRole) && !"tutor".equals(newRole)) {
                response.put("success", false);
                response.put("message", "角色类型错误");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }
            
            user.setRole(newRole);
        } else {
            response.put("success", false);
            response.put("message", "缺少角色参数");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
        
        boolean updated = userService.updateUser(user);
        
        if (!updated) {
            response.put("success", false);
            response.put("message", "更新失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
        
        response.put("success", true);
        response.put("message", "角色更新成功");
        response.put("data", DtoConverter.toUserDTO(user));
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateUser(@PathVariable String id, @RequestBody Map<String, Object> userData) {
        Map<String, Object> response = new java.util.HashMap<>();
        
        User user = userService.getUserById(id);
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        if (userData.containsKey("role") || userData.containsKey("roleId")) {
            String newRole = (String) (userData.containsKey("role") ? 
                userData.get("role") : userData.get("roleId"));
            
            user.setRole(newRole);
        }
        
        if (userData.containsKey("status")) {
            user.setStatus((String) userData.get("status"));
        }
        if (userData.containsKey("username")) {
            user.setUsername((String) userData.get("username"));
        }
        if (userData.containsKey("email")) {
            user.setEmail((String) userData.get("email"));
        }
        if (userData.containsKey("phone")) {
            user.setPhone((String) userData.get("phone"));
        }
        
        if (userData.containsKey("avatar")) {
            user.setAvatar((String) userData.get("avatar"));
        }
        if (userData.containsKey("gender")) {
            user.setGender((String) userData.get("gender"));
        }
        if (userData.containsKey("birthDate")) {
            user.setBirthDate(java.time.LocalDate.parse((String) userData.get("birthDate")));
        }
        if (userData.containsKey("teachingExperience")) {
            user.setTeachingExperience((Integer) userData.get("teachingExperience"));
        }
        
        boolean updated = userService.updateUser(user);
        if (!updated) {
            response.put("success", false);
            response.put("message", "更新失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
        
        response.put("success", true);
        response.put("message", "更新成功");
        response.put("data", DtoConverter.toUserDTO(user));
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/profile")
    public ResponseEntity<Map<String, Object>> updateProfile(@PathVariable String id, @RequestBody Map<String, Object> data) {
        User user = userService.getUserById(id);
        Map<String, Object> response = new java.util.HashMap<>();
        
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }

        if (data.containsKey("username")) {
            user.setUsername((String) data.get("username"));
        }
        if (data.containsKey("avatar")) {
            user.setAvatar((String) data.get("avatar"));
        }
        if (data.containsKey("phone")) {
            user.setPhone((String) data.get("phone"));
        }
        if (data.containsKey("gender")) {
            user.setGender((String) data.get("gender"));
        }
        if (data.containsKey("birthDate")) {
            user.setBirthDate(java.time.LocalDate.parse((String) data.get("birthDate")));
        }
        if (data.containsKey("teachingExperience")) {
            user.setTeachingExperience((Integer) data.get("teachingExperience"));
        }

        boolean updated = userService.updateUser(user);
        if (!updated) {
            response.put("success", false);
            response.put("message", "更新失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
        
        response.put("success", true);
        response.put("message", "更新成功");
        response.put("data", DtoConverter.toUserDTO(user));
        return ResponseEntity.ok(response);
    }

    @GetMapping("/tutors")
    public ResponseEntity<Map<String, Object>> getTutors(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        List<User> tutors = userService.getTutors();
        List<UserDTO> tutorDTOs = tutors.stream()
                .map(DtoConverter::toUserDTO)
                .collect(Collectors.toList());
        Map<String, Object> data = new java.util.HashMap<>();
        data.put("content", tutorDTOs);
        data.put("page", page);
        data.put("size", size);
        data.put("totalElements", tutorDTOs.size());
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "获取家教列表成功");
        response.put("data", data);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/tutors/search")
    public ResponseEntity<Map<String, Object>> searchTutors(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        List<User> tutors = userService.searchTutors(q, page, size);
        List<UserDTO> tutorDTOs = tutors.stream()
                .map(DtoConverter::toUserDTO)
                .collect(Collectors.toList());
        Map<String, Object> data = new java.util.HashMap<>();
        data.put("content", tutorDTOs);
        data.put("page", page);
        data.put("size", size);
        data.put("totalElements", tutorDTOs.size());
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "搜索家教成功");
        response.put("data", data);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/students/search")
    public ResponseEntity<Map<String, Object>> searchStudents(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        List<User> students = userService.searchStudents(q, page, size);
        List<UserDTO> studentDTOs = students.stream()
                .map(DtoConverter::toUserDTO)
                .collect(Collectors.toList());
        Map<String, Object> data = new java.util.HashMap<>();
        data.put("content", studentDTOs);
        data.put("page", page);
        data.put("size", size);
        data.put("totalElements", studentDTOs.size());
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "搜索学生成功");
        response.put("data", data);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/me/password")
    public ResponseEntity<Map<String, Object>> changePassword(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", false);
        response.put("message", "未授权");
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
    }

    @GetMapping("/{id}/statistics")
    public ResponseEntity<Map<String, Object>> getUserStatistics(@PathVariable String id) {
        Map<String, Object> response = new java.util.HashMap<>();
        
        User user = userService.getUserById(id);
        if (user == null) {
            response.put("success", false);
            response.put("message", "用户不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        Map<String, Object> statistics = userService.getUserStatistics(id);
        response.put("success", true);
        response.put("message", "获取用户统计信息成功");
        response.put("data", statistics);
        return ResponseEntity.ok(response);
    }
}