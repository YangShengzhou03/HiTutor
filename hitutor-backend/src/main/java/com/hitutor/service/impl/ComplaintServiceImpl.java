package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hitutor.entity.Complaint;
import com.hitutor.mapper.ComplaintMapper;
import com.hitutor.service.ComplaintService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class ComplaintServiceImpl extends ServiceImpl<ComplaintMapper, Complaint> implements ComplaintService {

    @Override
    public List<Complaint> getComplaints(int page, int size, String status) {
        QueryWrapper<Complaint> queryWrapper = new QueryWrapper<>();
        if (status != null && !status.isEmpty()) {
            queryWrapper.eq("status", status);
        }
        queryWrapper.orderByDesc("created_at");
        
        Page<Complaint> pageObj = new Page<>(page, size);
        Page<Complaint> result = baseMapper.selectPage(pageObj, queryWrapper);
        return result.getRecords();
    }

    @Override
    public Complaint updateComplaintStatus(Long id, String status) {
        Complaint complaint = baseMapper.selectById(id);
        if (complaint != null) {
            complaint.setStatus(status);
            baseMapper.updateById(complaint);
            return complaint;
        }
        return null;
    }

    @Override
    public Complaint createComplaint(Map<String, Object> data) {
        Complaint complaint = new Complaint();
        
        if (data.containsKey("userId")) {
            complaint.setUserId((String) data.get("userId"));
        }
        
        if (data.containsKey("targetUserId")) {
            complaint.setTargetUserId((String) data.get("targetUserId"));
        }
        
        complaint.setCategoryName((String) data.get("categoryName"));
        complaint.setTypeText((String) data.get("typeText"));
        complaint.setDescription((String) data.get("description"));
        
        if (data.containsKey("contactPhone")) {
            complaint.setContactPhone((String) data.get("contactPhone"));
        }
        
        complaint.setStatus("pending");
        complaint.setCreatedAt(LocalDateTime.now());
        complaint.setUpdatedAt(LocalDateTime.now());
        
        baseMapper.insert(complaint);
        return complaint;
    }

    @Override
    public int getPendingComplaintsCount() {
        QueryWrapper<Complaint> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "pending");
        return Math.toIntExact(baseMapper.selectCount(queryWrapper));
    }

    @Override
    public List<Complaint> getComplaintsByUserId(String userId) {
        QueryWrapper<Complaint> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId);
        queryWrapper.orderByDesc("created_at");
        return baseMapper.selectList(queryWrapper);
    }
}