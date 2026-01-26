package com.hitutor.config;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleException(Exception e) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", e.getMessage() != null ? e.getMessage() : "服务器内部错误");
        response.put("error", e.getClass().getSimpleName());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, Object>> handleIllegalArgumentException(IllegalArgumentException e) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", e.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, Object>> handleRuntimeException(RuntimeException e) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", e.getMessage() != null ? e.getMessage() : "运行时错误");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<Map<String, Object>> handleDataIntegrityViolationException(DataIntegrityViolationException e) {
        Map<String, Object> response = new HashMap<>();
        String message = e.getMessage();
        
        if (message != null && message.contains("uk_request_applicant")) {
            response.put("success", false);
            response.put("message", "您已经报名过该请求");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
        
        if (message != null && message.contains("uk_user_target")) {
            response.put("success", false);
            response.put("message", "您已经收藏过该内容");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
        
        if (message != null && message.contains("uk_user_blocked")) {
            response.put("success", false);
            response.put("message", "该用户已在您的黑名单中");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
        
        if (message != null && message.contains("uk_users")) {
            response.put("success", false);
            response.put("message", "会话已存在");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
        
        response.put("success", false);
        response.put("message", "数据完整性错误");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }
}
