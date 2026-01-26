package com.hitutor.controller;

import com.hitutor.service.VerificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/verifications")
public class VerificationController {

    @Autowired
    private VerificationService verificationService;

    @PostMapping("/send")
    public ResponseEntity<Map<String, Object>> sendVerificationCode(@RequestBody Map<String, String> request) {
        String phone = request.get("phone");

        try {
            verificationService.sendVerificationCode(phone);
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "验证码已发送");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(result);
        }
    }

    @PostMapping("/verify")
    public ResponseEntity<Map<String, Object>> verifyCode(@RequestBody Map<String, String> request) {
        String phone = request.get("phone");
        String code = request.get("code");

        try {
            boolean isValid = verificationService.verifyCode(phone, code);
            Map<String, Object> result = new HashMap<>();
            result.put("success", isValid);
            result.put("message", isValid ? "验证成功" : "验证码错误");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(result);
        }
    }
}