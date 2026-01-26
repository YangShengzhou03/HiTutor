package com.hitutor.service;

import com.hitutor.entity.TutorCertification;

import java.util.List;

public interface TutorCertificationService {
    TutorCertification getCertificationByUserId(String userId);
    boolean submitCertification(TutorCertification certification);
    boolean updateCertificationStatus(Long id, String status);
    List<TutorCertification> getAllCertifications();
}