package com.hitutor.service;

import com.hitutor.entity.StudentRequest;
import java.util.List;
import java.util.Map;

public interface StudentRequestService {
    
    List<StudentRequest> getNearbyRequests(double latitude, double longitude, double radius, String subject);
    
    StudentRequest createStudentRequest(Map<String, Object> data);
    
    Map<String, Object> getAllStudentRequests(int page, int size);
    
    StudentRequest getById(Long id);
    
    boolean updateStudentRequest(StudentRequest request);
    
    boolean deleteStudentRequest(Long id);
    
    Map<String, Object> searchStudentRequests(String query, int page, int size, String subject);
    
    List<StudentRequest> getRequestsByUserId(String userId);
}