package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.hitutor.entity.PointRecord;
import com.hitutor.entity.User;
import com.hitutor.mapper.PointRecordMapper;
import com.hitutor.mapper.UserMapper;
import com.hitutor.service.PointService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class PointServiceImpl implements PointService {

    @Autowired
    private PointRecordMapper pointRecordMapper;

    @Autowired
    private UserMapper userMapper;

    @Override
    public void addPoints(String userId, Integer points, String type, String description) {
        PointRecord record = new PointRecord();
        record.setUserId(userId);
        record.setPoints(points);
        record.setType(type);
        record.setDescription(description);
        record.setCreateTime(LocalDateTime.now());
        pointRecordMapper.insert(record);
        
        updateUserPoints(userId);
    }

    @Override
    public void adminAddPoints(String userId, Integer points, String type, String description) {
        PointRecord record = new PointRecord();
        record.setUserId(userId);
        record.setPoints(points);
        record.setType(type);
        record.setDescription(description);
        record.setCreateTime(LocalDateTime.now());
        pointRecordMapper.insert(record);
        
        updateUserPoints(userId);
    }

    private void updateUserPoints(String userId) {
        QueryWrapper<PointRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId);
        List<PointRecord> records = pointRecordMapper.selectList(wrapper);
        
        int total = 0;
        for (PointRecord record : records) {
            total += record.getPoints();
        }
        
        QueryWrapper<User> userWrapper = new QueryWrapper<>();
        userWrapper.eq("id", userId);
        User user = userMapper.selectOne(userWrapper);
        
        if (user != null) {
            user.setPoints(total);
            userMapper.updateById(user);
        }
    }

    @Override
    public List<PointRecord> getPointRecords(String userId) {
        QueryWrapper<PointRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId)
               .orderByDesc("create_time");
        return pointRecordMapper.selectList(wrapper);
    }

    @Override
    public Integer getTotalPoints(String userId) {
        QueryWrapper<PointRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId);
        List<PointRecord> records = pointRecordMapper.selectList(wrapper);
        
        int total = 0;
        for (PointRecord record : records) {
            total += record.getPoints();
        }
        return total;
    }

    @Override
    public boolean hasLoginPointsToday(String userId, java.time.LocalDate date) {
        QueryWrapper<PointRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId)
               .eq("type", "login")
               .ge("create_time", date.atStartOfDay())
               .le("create_time", date.atTime(23, 59, 59));
        return pointRecordMapper.selectCount(wrapper) > 0;
    }
}