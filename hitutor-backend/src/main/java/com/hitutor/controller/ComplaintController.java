package com.hitutor.controller;

import com.hitutor.dto.ComplaintDTO;
import com.hitutor.entity.Complaint;
import com.hitutor.entity.User;
import com.hitutor.service.ComplaintService;
import com.hitutor.service.UserService;
import com.hitutor.util.DtoConverter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/complaints")
public class ComplaintController {

    @Autowired
    private ComplaintService complaintService;

    @Autowired
    private UserService userService;

    @PostMapping
    public ResponseEntity<Map<String, Object>> createComplaint(@RequestBody Map<String, Object> request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = null;
        
        if (authentication != null && authentication.isAuthenticated()) {
            userId = authentication.getName();
        }
        
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        request.put("userId", userId);
        Complaint complaint = complaintService.createComplaint(request);
        
        if (complaint == null) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "投诉提交失败");
            return ResponseEntity.badRequest().body(result);
        }
        
        User user = userService.getUserById(userId);
        User targetUser = userService.getUserById(complaint.getTargetUserId());
        ComplaintDTO complaintDTO = DtoConverter.toComplaintDTO(complaint, user, targetUser);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", complaintDTO);
        result.put("message", "投诉提交成功");
        return ResponseEntity.ok(result);
    }

    @GetMapping
    @PreAuthorize("hasRole('admin')")
    public ResponseEntity<Map<String, Object>> getComplaints(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String status) {
        List<Complaint> complaints = complaintService.getComplaints(page, size, status);
        List<ComplaintDTO> complaintDTOs = complaints.stream()
                .map(complaint -> {
                    User user = userService.getUserById(complaint.getUserId());
                    User targetUser = userService.getUserById(complaint.getTargetUserId());
                    return DtoConverter.toComplaintDTO(complaint, user, targetUser);
                })
                .collect(Collectors.toList());
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "获取投诉列表成功");
        result.put("data", complaintDTOs);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/my")
    public ResponseEntity<Map<String, Object>> getMyComplaints(Authentication authentication) {
        String userId = authentication.getName();
        List<Complaint> complaints = complaintService.getComplaintsByUserId(userId);
        List<ComplaintDTO> complaintDTOs = complaints.stream()
                .map(complaint -> {
                    User user = userService.getUserById(complaint.getUserId());
                    User targetUser = userService.getUserById(complaint.getTargetUserId());
                    return DtoConverter.toComplaintDTO(complaint, user, targetUser);
                })
                .collect(Collectors.toList());
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "获取我的投诉列表成功");
        result.put("data", complaintDTOs);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('admin')")
    public ResponseEntity<Map<String, Object>> getComplaint(@PathVariable Long id) {
        Complaint complaint = complaintService.getById(id);
        Map<String, Object> result = new HashMap<>();
        if (complaint == null) {
            result.put("success", false);
            result.put("message", "投诉不存在");
            return ResponseEntity.status(404).body(result);
        }
        User user = userService.getUserById(complaint.getUserId());
        User targetUser = userService.getUserById(complaint.getTargetUserId());
        result.put("success", true);
        result.put("message", "获取投诉成功");
        result.put("data", DtoConverter.toComplaintDTO(complaint, user, targetUser));
        return ResponseEntity.ok(result);
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('admin')")
    public ResponseEntity<Map<String, Object>> updateComplaintStatus(@PathVariable Long id, @RequestBody Map<String, String> request) {
        String status = request.get("status");
        Complaint complaint = complaintService.updateComplaintStatus(id, status);
        Map<String, Object> result = new HashMap<>();
        if (complaint == null) {
            result.put("success", false);
            result.put("message", "投诉不存在");
            return ResponseEntity.status(404).body(result);
        }
        User user = userService.getUserById(complaint.getUserId());
        User targetUser = userService.getUserById(complaint.getTargetUserId());
        result.put("success", true);
        result.put("message", "更新投诉状态成功");
        result.put("data", DtoConverter.toComplaintDTO(complaint, user, targetUser));
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('admin')")
    public ResponseEntity<Void> deleteComplaint(@PathVariable Long id) {
        boolean deleted = complaintService.removeById(id);
        if (!deleted) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok().build();
    }
}