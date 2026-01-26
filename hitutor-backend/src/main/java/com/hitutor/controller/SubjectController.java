package com.hitutor.controller;

import com.hitutor.entity.TutorSubject;
import com.hitutor.service.TutorSubjectService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/subjects")
public class SubjectController {

    @Autowired
    private TutorSubjectService tutorSubjectService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllSubjects() {
        List<TutorSubject> subjects = tutorSubjectService.list();
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", subjects);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/active")
    public ResponseEntity<Map<String, Object>> getActiveSubjects() {
        List<TutorSubject> subjects = tutorSubjectService.getActiveSubjects();
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", subjects);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getSubjectById(@PathVariable Long id) {
        TutorSubject subject = tutorSubjectService.getById(id);
        Map<String, Object> response = new HashMap<>();
        if (subject == null) {
            response.put("success", false);
            response.put("message", "科目不存在");
            return ResponseEntity.status(404).body(response);
        }
        response.put("success", true);
        response.put("message", "获取科目成功");
        response.put("data", subject);
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createSubject(@RequestBody TutorSubject subject) {
        boolean saved = tutorSubjectService.save(subject);
        Map<String, Object> response = new HashMap<>();
        if (saved) {
            response.put("success", true);
            response.put("message", "创建科目成功");
            response.put("data", subject);
            return ResponseEntity.status(201).body(response);
        } else {
            response.put("success", false);
            response.put("message", "创建科目失败");
            return ResponseEntity.badRequest().body(response);
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateSubject(@PathVariable Long id, @RequestBody TutorSubject subject) {
        subject.setId(id);
        boolean updated = tutorSubjectService.updateById(subject);
        Map<String, Object> response = new HashMap<>();
        if (updated) {
            response.put("success", true);
            response.put("message", "更新科目成功");
            response.put("data", subject);
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "科目不存在");
            return ResponseEntity.status(404).body(response);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteSubject(@PathVariable Long id) {
        boolean deleted = tutorSubjectService.removeById(id);
        Map<String, Object> response = new HashMap<>();
        if (deleted) {
            response.put("success", true);
            response.put("message", "删除科目成功");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "科目不存在");
            return ResponseEntity.status(404).body(response);
        }
    }
}
