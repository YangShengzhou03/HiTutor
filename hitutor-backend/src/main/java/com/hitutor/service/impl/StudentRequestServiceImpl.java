package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hitutor.entity.StudentRequest;
import com.hitutor.mapper.StudentRequestMapper;
import com.hitutor.service.StudentRequestService;
import com.hitutor.util.DistanceUtil;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class StudentRequestServiceImpl extends ServiceImpl<StudentRequestMapper, StudentRequest> implements StudentRequestService {

    @Override
    public List<StudentRequest> getNearbyRequests(double latitude, double longitude, double radius, String subject) {
        QueryWrapper<StudentRequest> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "recruiting");
        
        if (subject != null && !subject.isEmpty()) {
            queryWrapper.eq("subject_name", subject);
        }
        
        List<StudentRequest> allRequests = baseMapper.selectList(queryWrapper);
        
        return allRequests.stream()
            .filter(request -> {
                double distance = DistanceUtil.calculateDistance(
                    latitude, longitude,
                    request.getLatitude().doubleValue(),
                    request.getLongitude().doubleValue()
                );
                return distance <= radius;
            })
            .toList();
    }

    @Override
    public StudentRequest createStudentRequest(Map<String, Object> data) {
        // 数据校验
        if (!data.containsKey("userId") || data.get("userId") == null) {
            throw new IllegalArgumentException("用户ID不能为空");
        }
        if (!data.containsKey("childName") || data.get("childName") == null || ((String) data.get("childName")).trim().isEmpty()) {
            throw new IllegalArgumentException("孩子称呼不能为空");
        }
        if (!data.containsKey("childGrade") || data.get("childGrade") == null || ((String) data.get("childGrade")).trim().isEmpty()) {
            throw new IllegalArgumentException("孩子年级不能为空");
        }
        if (!data.containsKey("subjectId") || data.get("subjectId") == null) {
            throw new IllegalArgumentException("科目ID不能为空");
        }
        if (!data.containsKey("subjectName") || data.get("subjectName") == null || ((String) data.get("subjectName")).trim().isEmpty()) {
            throw new IllegalArgumentException("科目名称不能为空");
        }
        if (!data.containsKey("address") || data.get("address") == null || ((String) data.get("address")).trim().isEmpty()) {
            throw new IllegalArgumentException("地址不能为空");
        }
        if (!data.containsKey("latitude") || data.get("latitude") == null) {
            throw new IllegalArgumentException("纬度不能为空");
        }
        if (!data.containsKey("longitude") || data.get("longitude") == null) {
            throw new IllegalArgumentException("经度不能为空");
        }
        
        // 经纬度范围校验
        double latitude = Double.parseDouble(data.get("latitude").toString());
        double longitude = Double.parseDouble(data.get("longitude").toString());
        if (latitude < -90 || latitude > 90) {
            throw new IllegalArgumentException("纬度必须在-90到90之间");
        }
        if (longitude < -180 || longitude > 180) {
            throw new IllegalArgumentException("经度必须在-180到180之间");
        }
        
        // 价格范围校验
        if (data.containsKey("hourlyRateMin")) {
            BigDecimal hourlyRateMin = new BigDecimal(data.get("hourlyRateMin").toString());
            if (hourlyRateMin.compareTo(BigDecimal.ZERO) < 0) {
                throw new IllegalArgumentException("最低时薪不能为负数");
            }
            if (hourlyRateMin.compareTo(new BigDecimal("500")) > 0) {
                throw new IllegalArgumentException("最低时薪不能超过500元/小时");
            }
        }
        if (data.containsKey("hourlyRateMax")) {
            BigDecimal hourlyRateMax = new BigDecimal(data.get("hourlyRateMax").toString());
            if (hourlyRateMax.compareTo(BigDecimal.ZERO) < 0) {
                throw new IllegalArgumentException("最高时薪不能为负数");
            }
            if (hourlyRateMax.compareTo(new BigDecimal("500")) > 0) {
                throw new IllegalArgumentException("最高时薪不能超过500元/小时");
            }
        }
        if (data.containsKey("hourlyRateMin") && data.containsKey("hourlyRateMax")) {
            BigDecimal hourlyRateMin = new BigDecimal(data.get("hourlyRateMin").toString());
            BigDecimal hourlyRateMax = new BigDecimal(data.get("hourlyRateMax").toString());
            if (hourlyRateMin.compareTo(hourlyRateMax) > 0) {
                throw new IllegalArgumentException("最低时薪不能大于最高时薪");
            }
        }
        
        StudentRequest request = new StudentRequest();
        request.setUserId((String) data.get("userId"));
        request.setChildName((String) data.get("childName"));
        request.setChildGrade((String) data.get("childGrade"));
        request.setSubjectId(((Number) data.get("subjectId")).longValue());
        request.setSubjectName((String) data.get("subjectName"));
        
        if (data.containsKey("hourlyRateMin")) {
            request.setHourlyRateMin(new BigDecimal(data.get("hourlyRateMin").toString()));
        }
        if (data.containsKey("hourlyRateMax")) {
            request.setHourlyRateMax(new BigDecimal(data.get("hourlyRateMax").toString()));
        }
        
        request.setAddress((String) data.get("address"));
        request.setLatitude(new BigDecimal(data.get("latitude").toString()));
        request.setLongitude(new BigDecimal(data.get("longitude").toString()));
        request.setRequirements((String) data.get("requirements"));
        request.setAvailableTime((String) data.get("availableTime"));
        request.setStatus("recruiting");
        request.setCreateTime(LocalDateTime.now());
        request.setUpdateTime(LocalDateTime.now());
        
        boolean saved = baseMapper.insert(request) > 0;
        return saved ? request : null;
    }

    @Override
    public Map<String, Object> getAllStudentRequests(int page, int size) {
        QueryWrapper<StudentRequest> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "recruiting");
        
        Page<StudentRequest> pageObj = new Page<>(page, size);
        Page<StudentRequest> resultPage = baseMapper.selectPage(pageObj, queryWrapper);
        
        java.util.HashMap<String, Object> result = new java.util.HashMap<>();
        result.put("content", resultPage.getRecords());
        result.put("page", page);
        result.put("size", size);
        result.put("totalElements", resultPage.getTotal());
        result.put("totalPages", resultPage.getPages());
        
        return result;
    }

    @Override
    public StudentRequest getById(Long id) {
        return baseMapper.selectById(id);
    }

    @Override
    public boolean updateStudentRequest(StudentRequest request) {
        request.setUpdateTime(LocalDateTime.now());
        return baseMapper.updateById(request) > 0;
    }

    @Override
    public boolean deleteStudentRequest(Long id) {
        return baseMapper.deleteById(id) > 0;
    }
    
    @Override
    public Map<String, Object> searchStudentRequests(String query, int page, int size, String subject) {
        QueryWrapper<StudentRequest> queryWrapper = new QueryWrapper<>();
        queryWrapper.like("child_name", query)
                   .or()
                   .like("subject_name", query)
                   .or()
                   .like("requirements", query)
                   .eq("status", "recruiting");
        
        if (subject != null && !subject.isEmpty()) {
            queryWrapper.eq("subject_name", subject);
        }
        
        Page<StudentRequest> pageObj = new Page<>(page, size);
        Page<StudentRequest> resultPage = baseMapper.selectPage(pageObj, queryWrapper);
        
        java.util.HashMap<String, Object> result = new java.util.HashMap<>();
        result.put("content", resultPage.getRecords());
        result.put("page", page);
        result.put("size", size);
        result.put("totalElements", resultPage.getTotal());
        result.put("totalPages", resultPage.getPages());
        
        return result;
    }
    
    @Override
    public List<StudentRequest> getRequestsByUserId(String userId) {
        QueryWrapper<StudentRequest> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId);
        queryWrapper.orderByDesc("create_time");
        return baseMapper.selectList(queryWrapper);
    }
}