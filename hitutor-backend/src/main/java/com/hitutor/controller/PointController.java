package com.hitutor.controller;

import com.hitutor.entity.PointRecord;
import com.hitutor.service.PointService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/points")
public class PointController {

    private static final Logger logger = LoggerFactory.getLogger(PointController.class);

    @Autowired
    private PointService pointService;

    @GetMapping("/records")
    public ResponseEntity<Map<String, Object>> getPointRecords(@RequestParam String userId) {
        List<PointRecord> records = pointService.getPointRecords(userId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", records);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/total")
    public ResponseEntity<Map<String, Object>> getTotalPoints(@RequestParam String userId) {
        Integer totalPoints = pointService.getTotalPoints(userId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        
        Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("totalPoints", totalPoints);
        
        result.put("data", dataMap);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/admin/add")
    public ResponseEntity<Map<String, Object>> adminAddPoints(@RequestBody Map<String, Object> request) {
        logger.info("收到积分添加请求，请求体: {}", request);
        
        String userId = (String) request.get("userId");
        Object pointsObj = request.get("points");
        String type = (String) request.get("type");
        String description = (String) request.get("description");

        logger.info("解析参数 - userId: {}, points: {}, type: {}, description: {}", 
            userId, pointsObj, type, description);

        if (userId == null || userId.isEmpty()) {
            logger.warn("用户ID为空或无效: {}", userId);
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "用户ID不能为空");
            return ResponseEntity.badRequest().body(result);
        }

        if (pointsObj == null) {
            logger.warn("积分数量为空");
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "积分数量不能为空");
            return ResponseEntity.badRequest().body(result);
        }

        Integer points = ((Number) pointsObj).intValue();

        if (type == null || type.isEmpty()) {
            logger.warn("积分类型为空或无效: {}", type);
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "积分类型不能为空");
            return ResponseEntity.badRequest().body(result);
        }

        if (description == null || description.isEmpty()) {
            logger.warn("积分说明为空或无效: {}", description);
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "积分说明不能为空");
            return ResponseEntity.badRequest().body(result);
        }

        logger.info("开始添加积分 - userId: {}, points: {}, type: {}, description: {}", 
            userId, points, type, description);
        pointService.adminAddPoints(userId, points, type, description);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "积分操作成功");
        logger.info("积分添加成功 - userId: {}, points: {}", userId, points);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/admin/deduct")
    public ResponseEntity<Map<String, Object>> adminDeductPoints(@RequestBody Map<String, Object> request) {
        logger.info("收到积分扣除请求，请求体: {}", request);
        
        String userId = (String) request.get("userId");
        Object pointsObj = request.get("points");
        String type = (String) request.get("type");
        String description = (String) request.get("description");

        logger.info("解析参数 - userId: {}, points: {}, type: {}, description: {}", 
            userId, pointsObj, type, description);

        if (userId == null || userId.isEmpty()) {
            logger.warn("用户ID为空或无效: {}", userId);
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "用户ID不能为空");
            return ResponseEntity.badRequest().body(result);
        }

        if (pointsObj == null) {
            logger.warn("积分数量为空");
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "积分数量不能为空");
            return ResponseEntity.badRequest().body(result);
        }

        Integer points = ((Number) pointsObj).intValue();

        if (type == null || type.isEmpty()) {
            logger.warn("积分类型为空或无效: {}", type);
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "积分类型不能为空");
            return ResponseEntity.badRequest().body(result);
        }

        if (description == null || description.isEmpty()) {
            logger.warn("积分说明为空或无效: {}", description);
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "积分说明不能为空");
            return ResponseEntity.badRequest().body(result);
        }

        logger.info("开始扣除积分 - userId: {}, points: {}, type: {}, description: {}", 
            userId, points, type, description);
        pointService.adminAddPoints(userId, -points, type, description);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "积分扣除成功");
        logger.info("积分扣除成功 - userId: {}, points: {}", userId, points);
        return ResponseEntity.ok(result);
    }
}