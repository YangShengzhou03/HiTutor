package com.hitutor.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.hitutor.entity.TutorResume;

public interface TutorResumeService {
    TutorResume getResumeByUserId(String userId);
    boolean saveOrUpdateResume(TutorResume resume);
    Page<TutorResume> getAllTutorResumes(int page, int size);
    TutorResume getTutorResumeById(Long id);
    boolean deleteTutorResume(Long id);
}