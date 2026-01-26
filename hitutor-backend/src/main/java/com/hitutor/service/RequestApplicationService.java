package com.hitutor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hitutor.entity.RequestApplication;

import java.util.List;

public interface RequestApplicationService extends IService<RequestApplication> {
    boolean createApplication(RequestApplication application);
    boolean updateApplicationStatus(Long id, String status);
    boolean confirmApplication(Long id);
    List<RequestApplication> getApplicationsByRequestId(Long requestId);
    List<RequestApplication> getApplicationsByRequestIdAndType(Long requestId, String requestType);
    List<RequestApplication> getApplicationsByApplicantId(String applicantId);
}
