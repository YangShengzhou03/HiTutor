package com.hitutor.util;

import com.hitutor.dto.*;
import com.hitutor.entity.*;
import com.hitutor.service.ReviewService;
import com.hitutor.service.UserService;

import java.time.format.DateTimeFormatter;
import java.util.Map;

public class DtoConverter {
    
    private static ReviewService reviewService;
    private static UserService userService;
    
    public static void setReviewService(ReviewService service) {
        reviewService = service;
    }
    
    public static void setUserService(UserService service) {
        userService = service;
    }
    
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter DATETIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public static UserDTO toUserDTO(User user) {
        if (user == null) {
            return null;
        }
        
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setName(user.getUsername());
        dto.setUsername(user.getUsername());
        dto.setAvatar(user.getAvatar());
        dto.setPhone(user.getPhone());
        dto.setEmail(user.getEmail());
        dto.setGender(user.getGender());
        dto.setBirthDate(user.getBirthDate() != null ? user.getBirthDate().format(DATE_FORMATTER) : null);
        dto.setEducation(user.getEducation());
        dto.setSchool(user.getSchool());
        dto.setMajor(user.getMajor());
        dto.setTeachingExperience(user.getTeachingExperience());
        dto.setIsVerified(user.getIsVerified() != null && user.getIsVerified() == 1);
        dto.setRole(user.getRole());
        dto.setPoints(user.getPoints());
        dto.setCreatedAt(user.getCreateTime() != null ? user.getCreateTime().format(DATETIME_FORMATTER) : null);
        return dto;
    }

    public static ComplaintDTO toComplaintDTO(Complaint complaint, User user, User targetUser) {
        if (complaint == null) {
            return null;
        }
        
        ComplaintDTO dto = new ComplaintDTO();
        dto.setId(complaint.getId());
        dto.setUserId(complaint.getUserId());
        if (user != null) {
            dto.setUserName(user.getUsername());
            dto.setUserAvatar(user.getAvatar());
        }
        dto.setTargetUserId(complaint.getTargetUserId());
        if (targetUser != null) {
            dto.setTargetUserName(targetUser.getUsername());
            dto.setTargetUserAvatar(targetUser.getAvatar());
        }
        dto.setCategoryName(complaint.getCategoryName());
        dto.setTypeText(complaint.getTypeText());
        dto.setDescription(complaint.getDescription());
        dto.setContactPhone(complaint.getContactPhone());
        dto.setStatus(complaint.getStatus());
        dto.setCreatedAt(complaint.getCreatedAt() != null ? complaint.getCreatedAt().format(DATETIME_FORMATTER) : null);
        return dto;
    }

    public static TutorProfileDTO toTutorProfileDTO(TutorProfile profile, User user) {
        if (profile == null) {
            return null;
        }
        
        TutorProfileDTO dto = new TutorProfileDTO();
        dto.setId(profile.getId());
        dto.setUserId(profile.getUserId());
        if (user != null) {
            dto.setUserName(user.getUsername());
            dto.setUserAvatar(user.getAvatar());
            dto.setUserVerified(user.getIsVerified() != null && user.getIsVerified() == 1);
        }
        dto.setSubjectId(profile.getSubjectId());
        dto.setSubjectName(profile.getSubjectName());
        dto.setHourlyRate(profile.getHourlyRate() != null ? profile.getHourlyRate().toString() : null);
        dto.setAddress(profile.getAddress());
        dto.setLatitude(profile.getLatitude() != null ? profile.getLatitude().toString() : null);
        dto.setLongitude(profile.getLongitude() != null ? profile.getLongitude().toString() : null);
        dto.setDescription(profile.getDescription());
        dto.setAvailableTime(profile.getAvailableTime());
        dto.setTargetGradeLevels(profile.getTargetGradeLevels());
        dto.setStatus(profile.getStatus());
        
        if (reviewService != null) {
            Map<String, Object> ratingInfo = reviewService.getTutorRating(profile.getUserId());
            dto.setRating((Double) ratingInfo.getOrDefault("rating", 0.0));
            dto.setReviewCount((Integer) ratingInfo.getOrDefault("reviewCount", 0));
        } else {
            dto.setRating(0.0);
            dto.setReviewCount(0);
        }
        
        dto.setCreatedAt(profile.getCreateTime() != null ? profile.getCreateTime().format(DATETIME_FORMATTER) : null);
        return dto;
    }

    public static StudentRequestDTO toStudentRequestDTO(StudentRequest request, User user) {
        if (request == null) {
            return null;
        }
        
        StudentRequestDTO dto = new StudentRequestDTO();
        dto.setId(request.getId());
        dto.setUserId(request.getUserId());
        if (user != null) {
            dto.setUserName(user.getUsername());
            dto.setUserAvatar(user.getAvatar());
        }
        dto.setChildName(request.getChildName());
        dto.setChildGrade(request.getChildGrade());
        dto.setSubjectId(request.getSubjectId());
        dto.setSubjectName(request.getSubjectName());
        dto.setHourlyRateMin(request.getHourlyRateMin() != null ? request.getHourlyRateMin().toString() : null);
        dto.setHourlyRateMax(request.getHourlyRateMax() != null ? request.getHourlyRateMax().toString() : null);
        dto.setAddress(request.getAddress());
        dto.setLatitude(request.getLatitude() != null ? request.getLatitude().toString() : null);
        dto.setLongitude(request.getLongitude() != null ? request.getLongitude().toString() : null);
        dto.setRequirements(request.getRequirements());
        dto.setAvailableTime(request.getAvailableTime());
        dto.setStatus(request.getStatus());
        dto.setCreatedAt(request.getCreateTime() != null ? request.getCreateTime().format(DATETIME_FORMATTER) : null);
        return dto;
    }

    public static AppointmentDTO toAppointmentDTO(Appointment appointment, User tutor, User student) {
        if (appointment == null) {
            return null;
        }
        
        AppointmentDTO dto = new AppointmentDTO();
        dto.setId(appointment.getId());
        dto.setTutorId(appointment.getTutorId());
        if (tutor != null) {
            dto.setTutorName(tutor.getUsername());
            dto.setTutorAvatar(tutor.getAvatar());
            dto.setTutorPhone(tutor.getPhone());
            dto.setTutorVerified(tutor.getIsVerified() != null && tutor.getIsVerified() == 1);
        }
        dto.setStudentId(appointment.getStudentId());
        if (student != null) {
            dto.setStudentName(student.getUsername());
            dto.setStudentAvatar(student.getAvatar());
            dto.setStudentPhone(student.getPhone());
        }
        dto.setSubjectId(appointment.getSubjectId());
        dto.setSubjectName(appointment.getSubjectName());
        dto.setAppointmentTime(appointment.getAppointmentTime() != null ? appointment.getAppointmentTime().format(DATETIME_FORMATTER) : null);
        dto.setDuration(appointment.getDuration());
        dto.setAddress(appointment.getAddress());
        dto.setHourlyRate(appointment.getHourlyRate() != null ? appointment.getHourlyRate().toString() : null);
        dto.setTotalAmount(appointment.getTotalAmount() != null ? appointment.getTotalAmount().toString() : null);
        dto.setStatus(appointment.getStatus());
        dto.setNotes(appointment.getNotes());
        dto.setRequestId(appointment.getRequestId() != null ? appointment.getRequestId().toString() : null);
        dto.setRequestType(appointment.getRequestType());
        dto.setCreatedAt(appointment.getCreateTime() != null ? appointment.getCreateTime().format(DATETIME_FORMATTER) : null);
        return dto;
    }

    public static ReviewDTO toReviewDTO(Review review, User reviewer) {
        if (review == null) {
            return null;
        }
        
        ReviewDTO dto = new ReviewDTO();
        dto.setId(review.getId());
        dto.setAppointmentId(review.getAppointmentId());
        dto.setReviewerId(review.getReviewerId());
        if (reviewer != null) {
            dto.setReviewerName(reviewer.getUsername());
            dto.setReviewerAvatar(reviewer.getAvatar());
        }
        dto.setReviewedId(review.getReviewedId());
        dto.setRating(review.getRating());
        dto.setComment(review.getComment());
        dto.setCreatedAt(review.getCreateTime() != null ? review.getCreateTime().format(DATETIME_FORMATTER) : null);
        return dto;
    }

    public static RequestApplicationDTO toRequestApplicationDTO(RequestApplication application, User applicant) {
        if (application == null) {
            return null;
        }
        
        RequestApplicationDTO dto = new RequestApplicationDTO();
        dto.setId(application.getId());
        dto.setRequestId(application.getRequestId());
        dto.setRequestType(application.getRequestType());
        dto.setApplicantId(application.getApplicantId());
        dto.setApplicantName(application.getApplicantName());
        dto.setApplicantPhone(application.getApplicantPhone());
        if (applicant != null) {
            dto.setApplicantAvatar(applicant.getAvatar());
            dto.setApplicantVerified(applicant.getIsVerified() != null && applicant.getIsVerified() == 1);
        }
        dto.setMessage(application.getMessage());
        dto.setStatus(application.getStatus());
        dto.setCreateTime(application.getCreateTime());
        dto.setUpdateTime(application.getUpdateTime());
        return dto;
    }
}
