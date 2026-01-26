package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hitutor.entity.TutorSubject;
import com.hitutor.mapper.TutorSubjectMapper;
import com.hitutor.service.TutorSubjectService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TutorSubjectServiceImpl extends ServiceImpl<TutorSubjectMapper, TutorSubject> implements TutorSubjectService {

    @Override
    public List<TutorSubject> getActiveSubjects() {
        QueryWrapper<TutorSubject> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "active");
        queryWrapper.orderByDesc("create_time");
        return this.list(queryWrapper);
    }
}
