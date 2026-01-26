package com.hitutor.service;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hitutor.entity.PointRecord;

import java.util.List;

public interface PointService {
    void addPoints(String userId, Integer points, String type, String description);
    void adminAddPoints(String userId, Integer points, String type, String description);
    List<PointRecord> getPointRecords(String userId);
    Integer getTotalPoints(String userId);
    boolean hasLoginPointsToday(String userId, java.time.LocalDate date);
}