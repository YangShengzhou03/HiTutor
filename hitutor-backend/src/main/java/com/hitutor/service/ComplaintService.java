package com.hitutor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hitutor.entity.Complaint;
import java.util.List;
import java.util.Map;

public interface ComplaintService extends IService<Complaint> {
    List<Complaint> getComplaints(int page, int size, String status);
    List<Complaint> getComplaintsByUserId(String userId);
    Complaint updateComplaintStatus(Long id, String status);
    Complaint createComplaint(Map<String, Object> data);
    int getPendingComplaintsCount();
}