package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hitutor.entity.TutorResume;
import com.hitutor.mapper.TutorResumeMapper;
import com.hitutor.service.TutorResumeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class TutorResumeServiceImpl implements TutorResumeService {

    @Autowired
    private TutorResumeMapper tutorResumeMapper;

    @Override
    public TutorResume getResumeByUserId(String userId) {
        QueryWrapper<TutorResume> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId);
        return tutorResumeMapper.selectOne(wrapper);
    }

    @Override
    public boolean saveOrUpdateResume(TutorResume resume) {
        QueryWrapper<TutorResume> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", resume.getUserId());
        TutorResume existingResume = tutorResumeMapper.selectOne(wrapper);
        
        if (existingResume != null) {
            resume.setId(existingResume.getId());
            resume.setUpdateTime(LocalDateTime.now());
            return tutorResumeMapper.updateById(resume) > 0;
        } else {
            resume.setCreateTime(LocalDateTime.now());
            resume.setUpdateTime(LocalDateTime.now());
            return tutorResumeMapper.insert(resume) > 0;
        }
    }

    @Override
    public Page<TutorResume> getAllTutorResumes(int page, int size) {
        Page<TutorResume> pageParam = new Page<>(page, size);
        return tutorResumeMapper.selectPage(pageParam, null);
    }

    @Override
    public TutorResume getTutorResumeById(Long id) {
        return tutorResumeMapper.selectById(id);
    }

    @Override
    public boolean deleteTutorResume(Long id) {
        return tutorResumeMapper.deleteById(id) > 0;
    }
}