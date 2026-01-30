package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hitutor.entity.TutorProfile;
import com.hitutor.mapper.TutorProfileMapper;
import com.hitutor.service.TutorProfileService;
import com.hitutor.util.DistanceUtil;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class TutorProfileServiceImpl extends ServiceImpl<TutorProfileMapper, TutorProfile> implements TutorProfileService {

    @Override
    public List<TutorProfile> getNearbyTutors(double latitude, double longitude, double radius, String subject) {
        QueryWrapper<TutorProfile> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "available");
        
        if (subject != null && !subject.isEmpty()) {
            queryWrapper.eq("subject_name", subject);
        }
        
        List<TutorProfile> allProfiles = baseMapper.selectList(queryWrapper);
        
        return allProfiles.stream()
            .filter(profile -> {
                double distance = DistanceUtil.calculateDistance(
                    latitude, longitude,
                    profile.getLatitude().doubleValue(),
                    profile.getLongitude().doubleValue()
                );
                return distance <= radius;
            })
            .toList();
    }

    @Override
    public TutorProfile createTutorProfile(Map<String, Object> data) {
        TutorProfile profile = new TutorProfile();
        profile.setUserId((String) data.get("userId"));
        
        Object subjectIdObj = data.get("subjectId");
        if (subjectIdObj != null) {
            if (subjectIdObj instanceof Number) {
                profile.setSubjectId(((Number) subjectIdObj).longValue());
            }
        }
        
        profile.setSubjectName((String) data.get("subjectName"));
        
        BigDecimal hourlyRate = new BigDecimal(data.get("hourlyRate").toString());
        if (hourlyRate.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("时薪必须大于0");
        }
        if (hourlyRate.compareTo(new BigDecimal("500")) > 0) {
            throw new IllegalArgumentException("时薪不能超过500元/小时");
        }
        profile.setHourlyRate(hourlyRate);
        
        profile.setAddress((String) data.get("address"));
        profile.setLatitude(new BigDecimal(data.get("latitude").toString()));
        profile.setLongitude(new BigDecimal(data.get("longitude").toString()));
        
        profile.setDescription((String) data.get("description"));
        profile.setAvailableTime((String) data.get("availableTime"));
        
        Object targetGradeLevelsObj = data.get("targetGradeLevels");
        if (targetGradeLevelsObj != null) {
            if (targetGradeLevelsObj instanceof String) {
                profile.setTargetGradeLevels((String) targetGradeLevelsObj);
            } else if (targetGradeLevelsObj instanceof List) {
                @SuppressWarnings("unchecked")
                List<String> gradeLevels = (List<String>) targetGradeLevelsObj;
                profile.setTargetGradeLevels(String.join(",", gradeLevels));
            }
        }
        
        profile.setStatus("available");
        profile.setCreateTime(LocalDateTime.now());
        profile.setUpdateTime(LocalDateTime.now());
        
        boolean saved = baseMapper.insert(profile) > 0;
        return saved ? profile : null;
    }

    @Override
    public Map<String, Object> getAllTutorProfiles(int page, int size) {
        QueryWrapper<TutorProfile> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "available");
        
        
        Page<TutorProfile> pageObj = new Page<>(page, size);
        Page<TutorProfile> resultPage = baseMapper.selectPage(pageObj, queryWrapper);
        
        
        java.util.HashMap<String, Object> result = new java.util.HashMap<>();
        result.put("content", resultPage.getRecords());
        result.put("page", page);
        result.put("size", size);
        result.put("totalElements", resultPage.getTotal());
        result.put("totalPages", resultPage.getPages());
        
        return result;
    }

    @Override
    public TutorProfile getById(Long id) {
        return baseMapper.selectById(id);
    }

    @Override
    public boolean updateTutorProfile(TutorProfile profile) {
        profile.setUpdateTime(LocalDateTime.now());
        return baseMapper.updateById(profile) > 0;
    }

    @Override
    public boolean deleteTutorProfile(Long id) {
        return baseMapper.deleteById(id) > 0;
    }

    @Override
    public List<TutorProfile> getProfilesByUserId(String userId) {
        QueryWrapper<TutorProfile> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId);
        queryWrapper.orderByDesc("create_time");
        return baseMapper.selectList(queryWrapper);
    }
}