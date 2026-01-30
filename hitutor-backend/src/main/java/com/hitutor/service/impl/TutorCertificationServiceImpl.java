package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.hitutor.entity.TutorCertification;
import com.hitutor.entity.User;
import com.hitutor.mapper.TutorCertificationMapper;
import com.hitutor.mapper.UserMapper;
import com.hitutor.service.TutorCertificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class TutorCertificationServiceImpl implements TutorCertificationService {

    @Autowired
    private TutorCertificationMapper tutorCertificationMapper;
    
    @Autowired
    private UserMapper userMapper;

    @Override
    public TutorCertification getCertificationByUserId(String userId) {
        QueryWrapper<TutorCertification> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId);
        return tutorCertificationMapper.selectOne(wrapper);
    }

    @Override
    public boolean submitCertification(TutorCertification certification) {
        if (certification.getCertificateNumber() == null || !certification.getCertificateNumber().matches("\\d{17}")) {
            throw new IllegalArgumentException("教师资格证号必须为17位数字");
        }
        
        QueryWrapper<TutorCertification> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", certification.getUserId());
        TutorCertification existingCertification = tutorCertificationMapper.selectOne(wrapper);
        
        if (existingCertification != null) {
            if ("pending".equals(existingCertification.getStatus())) {
                return false;
            }
            existingCertification.setRealName(certification.getRealName());
            existingCertification.setIdCard(certification.getIdCard());
            existingCertification.setEducation(certification.getEducation());
            existingCertification.setSchool(certification.getSchool());
            existingCertification.setMajor(certification.getMajor());
            existingCertification.setCertificateNumber(certification.getCertificateNumber());
            existingCertification.setStatus("pending");
            existingCertification.setUpdateTime(LocalDateTime.now());
            return tutorCertificationMapper.updateById(existingCertification) > 0;
        }
        
        certification.setCreateTime(LocalDateTime.now());
        certification.setUpdateTime(LocalDateTime.now());
        certification.setStatus("pending");
        return tutorCertificationMapper.insert(certification) > 0;
    }

    @Override
    public boolean updateCertificationStatus(Long id, String status) {
        TutorCertification certification = tutorCertificationMapper.selectById(id);
        if (certification == null) {
            return false;
        }
        
        certification.setStatus(status);
        certification.setUpdateTime(LocalDateTime.now());
        boolean updated = tutorCertificationMapper.updateById(certification) > 0;
        
        if (updated) {
            if ("approved".equals(status)) {
                User user = userMapper.selectById(certification.getUserId());
                if (user != null) {
                    user.setIsVerified(true);
                    user.setUpdateTime(LocalDateTime.now());
                    userMapper.updateById(user);
                }
            } else if ("rejected".equals(status)) {
                User user = userMapper.selectById(certification.getUserId());
                if (user != null) {
                    user.setIsVerified(false);
                    user.setUpdateTime(LocalDateTime.now());
                    userMapper.updateById(user);
                }
            }
        }
        
        return updated;
    }

    @Override
    public List<TutorCertification> getAllCertifications() {
        return tutorCertificationMapper.selectList(null);
    }
}