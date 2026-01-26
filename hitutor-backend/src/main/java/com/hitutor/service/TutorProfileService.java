package com.hitutor.service;

import com.hitutor.entity.TutorProfile;
import java.util.List;
import java.util.Map;

public interface TutorProfileService {
    
    List<TutorProfile> getNearbyTutors(double latitude, double longitude, double radius, String subject);
    
    TutorProfile createTutorProfile(Map<String, Object> data);
    
    Map<String, Object> getAllTutorProfiles(int page, int size);
    
    TutorProfile getById(Long id);
    
    boolean updateTutorProfile(TutorProfile profile);
    
    boolean deleteTutorProfile(Long id);
    
    List<TutorProfile> getProfilesByUserId(String userId);
}