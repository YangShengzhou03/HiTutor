package com.hitutor.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hitutor.entity.TutorResume;
import com.hitutor.service.TutorResumeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/tutor-resumes")
public class TutorResumeController {

    @Autowired
    private TutorResumeService tutorResumeService;

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getResumeByUserId(@PathVariable String userId) {
        TutorResume resume = tutorResumeService.getResumeByUserId(userId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", resume);
        return ResponseEntity.ok(result);
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllTutorResumes(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<TutorResume> result = tutorResumeService.getAllTutorResumes(page, size);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取简历列表成功");
        Map<String, Object> data = new HashMap<>();
        data.put("content", result.getRecords());
        data.put("totalElements", result.getTotal());
        data.put("totalPages", result.getPages());
        data.put("size", result.getSize());
        data.put("number", result.getCurrent());
        response.put("data", data);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getTutorResumeById(@PathVariable Long id) {
        TutorResume resume = tutorResumeService.getTutorResumeById(id);
        if (resume == null) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "简历不存在");
            response.put("data", null);
            return ResponseEntity.status(404).body(response);
        }
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取简历成功");
        response.put("data", resume);
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> saveOrUpdateResume(@RequestBody TutorResume resume) {
        boolean success = tutorResumeService.saveOrUpdateResume(resume);
        Map<String, Object> result = new HashMap<>();
        result.put("success", success);
        result.put("message", success ? "简历保存成功" : "简历保存失败");
        return ResponseEntity.ok(result);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateTutorResume(@PathVariable Long id, @RequestBody TutorResume resume) {
        resume.setId(id);
        boolean success = tutorResumeService.saveOrUpdateResume(resume);
        if (!success) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "简历不存在或更新失败");
            response.put("data", null);
            return ResponseEntity.status(404).body(response);
        }
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "更新简历成功");
        response.put("data", resume);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteTutorResume(@PathVariable Long id) {
        boolean deleted = tutorResumeService.deleteTutorResume(id);
        if (!deleted) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "简历不存在");
            response.put("data", null);
            return ResponseEntity.status(404).body(response);
        }
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "删除简历成功");
        response.put("data", null);
        return ResponseEntity.ok(response);
    }
}