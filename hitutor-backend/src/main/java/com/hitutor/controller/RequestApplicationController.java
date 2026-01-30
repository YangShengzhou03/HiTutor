package com.hitutor.controller;

import com.hitutor.dto.RequestApplicationDTO;
import com.hitutor.entity.RequestApplication;
import com.hitutor.entity.User;
import com.hitutor.service.RequestApplicationService;
import com.hitutor.service.UserService;
import com.hitutor.util.DtoConverter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/applications")
public class RequestApplicationController {

    @Autowired
    private RequestApplicationService applicationService;

    @Autowired
    private UserService userService;

    @PostMapping
    public ResponseEntity<Map<String, Object>> createApplication(@RequestBody RequestApplication application) {
        boolean created = applicationService.createApplication(application);
        if (created) {
            User applicant = userService.getUserById(application.getApplicantId());
            RequestApplicationDTO applicationDTO = DtoConverter.toRequestApplicationDTO(application, applicant);
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", true);
            response.put("message", "申请提交成功");
            response.put("data", applicationDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } else {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", false);
            response.put("message", "申请提交失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> updateApplicationStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        String status = request.get("status");
        boolean updated = applicationService.updateApplicationStatus(id, status);
        if (updated) {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", true);
            response.put("message", "状态更新成功");
            return ResponseEntity.ok(response);
        } else {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", false);
            response.put("message", "状态更新失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PutMapping("/{id}/confirm")
    public ResponseEntity<Map<String, Object>> confirmApplication(@PathVariable Long id) {
        boolean confirmed = applicationService.confirmApplication(id);
        if (confirmed) {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", true);
            response.put("message", "确认成功");
            return ResponseEntity.ok(response);
        } else {
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("success", false);
            response.put("message", "确认失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/request/{requestId}")
    public ResponseEntity<Map<String, Object>> getApplicationsByRequestId(@PathVariable Long requestId) {
        List<RequestApplication> applications = applicationService.getApplicationsByRequestId(requestId);
        List<RequestApplicationDTO> applicationDTOs = applications.stream()
                .map(app -> {
                    User applicant = userService.getUserById(app.getApplicantId());
                    return DtoConverter.toRequestApplicationDTO(app, applicant);
                })
                .collect(Collectors.toList());
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "获取申请列表成功");
        response.put("data", applicationDTOs);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/request/{requestId}/type/{requestType}")
    public ResponseEntity<Map<String, Object>> getApplicationsByRequestIdAndType(
            @PathVariable Long requestId,
            @PathVariable String requestType) {
        List<RequestApplication> applications = applicationService.getApplicationsByRequestIdAndType(requestId, requestType);
        List<RequestApplicationDTO> applicationDTOs = applications.stream()
                .map(app -> {
                    User applicant = userService.getUserById(app.getApplicantId());
                    return DtoConverter.toRequestApplicationDTO(app, applicant);
                })
                .collect(Collectors.toList());
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "获取申请列表成功");
        response.put("data", applicationDTOs);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/applicant/{applicantId}")
    public ResponseEntity<Map<String, Object>> getApplicationsByApplicantId(@PathVariable String applicantId) {
        List<RequestApplication> applications = applicationService.getApplicationsByApplicantId(applicantId);
        List<RequestApplicationDTO> applicationDTOs = applications.stream()
                .map(app -> {
                    User applicant = userService.getUserById(app.getApplicantId());
                    return DtoConverter.toRequestApplicationDTO(app, applicant);
                })
                .collect(Collectors.toList());
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("success", true);
        response.put("message", "获取申请列表成功");
        response.put("data", applicationDTOs);
        return ResponseEntity.ok(response);
    }
}
