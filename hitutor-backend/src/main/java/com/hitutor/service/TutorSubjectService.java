package com.hitutor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hitutor.entity.TutorSubject;
import java.util.List;

public interface TutorSubjectService extends IService<TutorSubject> {
    List<TutorSubject> getActiveSubjects();
}
