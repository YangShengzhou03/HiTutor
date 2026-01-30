package com.hitutor.controller;

import com.hitutor.dto.TutorCertificationDTO;
import com.hitutor.entity.TutorCertification;
import com.hitutor.entity.User;
import com.hitutor.service.TutorCertificationService;
import com.hitutor.service.UserService;
import com.hitutor.util.DtoConverter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/tutor-certifications")
public class TutorCertificationController {

    @Autowired
    private TutorCertificationService tutorCertificationService;

    @Autowired
    private UserService userService;

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getCertificationByUserId(@PathVariable String userId) {
        TutorCertification certification = tutorCertificationService.getCertificationByUserId(userId);
        User user = userService.getUserById(userId);
        TutorCertificationDTO certificationDTO = DtoConverter.toTutorCertificationDTO(certification, user);
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "获取认证信息成功");
        result.put("data", certificationDTO);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/all")
    public ResponseEntity<Map<String, Object>> getAllCertifications() {
        List<TutorCertification> certifications = tutorCertificationService.getAllCertifications();
        List<TutorCertificationDTO> certificationDTOs = certifications.stream()
                .map(cert -> {
                    User user = userService.getUserById(cert.getUserId());
                    return DtoConverter.toTutorCertificationDTO(cert, user);
                })
                .collect(Collectors.toList());
        
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "获取认证列表成功");
        result.put("data", certificationDTOs);
        return ResponseEntity.ok(result);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> submitCertification(@RequestBody TutorCertification certification) {
        boolean success = tutorCertificationService.submitCertification(certification);
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        if (success) {
            result.put("message", "认证申请已提交");
        } else {
            TutorCertification existing = tutorCertificationService.getCertificationByUserId(certification.getUserId());
            if (existing != null && "pending".equals(existing.getStatus())) {
                result.put("message", "已有认证正在审核中");
            } else {
                result.put("message", "认证申请失败");
            }
        }
        return ResponseEntity.ok(result);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> updateCertificationStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        String status = request.get("status");
        boolean success = tutorCertificationService.updateCertificationStatus(id, status);
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", success ? "认证状态更新成功" : "认证状态更新失败");
        return ResponseEntity.ok(result);
    }
}