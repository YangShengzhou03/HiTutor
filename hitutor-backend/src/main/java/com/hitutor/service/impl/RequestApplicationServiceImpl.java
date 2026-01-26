package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hitutor.entity.Appointment;
import com.hitutor.entity.RequestApplication;
import com.hitutor.entity.StudentRequest;
import com.hitutor.entity.TutorProfile;
import com.hitutor.entity.User;
import com.hitutor.entity.Notification;
import com.hitutor.mapper.RequestApplicationMapper;
import com.hitutor.mapper.StudentRequestMapper;
import com.hitutor.mapper.TutorProfileMapper;
import com.hitutor.service.AppointmentService;
import com.hitutor.service.RequestApplicationService;
import com.hitutor.service.UserService;
import com.hitutor.service.NotificationService;
import com.hitutor.service.BlacklistService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class RequestApplicationServiceImpl extends ServiceImpl<RequestApplicationMapper, RequestApplication> implements RequestApplicationService {

    @Autowired
    private StudentRequestMapper studentRequestMapper;

    @Autowired
    private TutorProfileMapper tutorProfileMapper;

    @Autowired
    private AppointmentService appointmentService;

    @Autowired
    private UserService userService;
    
    @Autowired
    private NotificationService notificationService;
    
    @Autowired
    private BlacklistService blacklistService;

    @Override
    @Transactional
    public boolean createApplication(RequestApplication application) {
        QueryWrapper<RequestApplication> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("request_id", application.getRequestId())
                   .eq("request_type", application.getRequestType())
                   .eq("applicant_id", application.getApplicantId());
        
        long count = baseMapper.selectCount(queryWrapper);
        if (count > 0) {
            throw new RuntimeException("您已经报名过该请求");
        }

        String requestType = application.getRequestType();
        String publisherId = null;
        
        if ("student_request".equals(requestType)) {
            StudentRequest request = studentRequestMapper.selectById(application.getRequestId());
            if (request == null) {
                throw new RuntimeException("需求不存在");
            }

            if (request.getUserId().equals(application.getApplicantId())) {
                throw new RuntimeException("不能报名自己发布的需求");
            }
            
            if (blacklistService.isBlocked(request.getUserId(), application.getApplicantId())) {
                throw new RuntimeException("对方已将您加入黑名单");
            }
            
            if (blacklistService.isBlocked(application.getApplicantId(), request.getUserId())) {
                throw new RuntimeException("您已将对方加入黑名单");
            }
            
            publisherId = request.getUserId();
        } else if ("tutor_profile".equals(requestType)) {
            TutorProfile service = tutorProfileMapper.selectById(application.getRequestId());
            if (service == null) {
                throw new RuntimeException("家教信息不存在");
            }

            if (service.getUserId().equals(application.getApplicantId())) {
                throw new RuntimeException("不能报名自己发布的家教信息");
            }
            
            if (blacklistService.isBlocked(service.getUserId(), application.getApplicantId())) {
                throw new RuntimeException("对方已将您加入黑名单");
            }
            
            if (blacklistService.isBlocked(application.getApplicantId(), service.getUserId())) {
                throw new RuntimeException("您已将对方加入黑名单");
            }
            
            publisherId = service.getUserId();
        } else {
            throw new RuntimeException("无效的请求类型");
        }
        
        User applicant = userService.getUserById(application.getApplicantId());
        if (applicant != null) {
            application.setApplicantName(applicant.getUsername());
            application.setApplicantPhone(applicant.getPhone());
        }
        
        boolean result = baseMapper.insert(application) > 0;
        
        if (result && publisherId != null) {
            Notification notification = new Notification();
            notification.setUserId(publisherId);
            notification.setType("application");
            notification.setTitle("新的报名申请");
            notification.setContent(applicant.getUsername() + " 报名了您的" + 
                ("student_request".equals(application.getRequestType()) ? "学生需求" : "家教信息"));
            notification.setRelatedId(application.getId().toString());
            notification.setRelatedType("application");
            notification.setIsRead(0);
            notificationService.createNotification(notification);
        }
        
        return result;
    }

    @Override
    @Transactional
    public boolean updateApplicationStatus(Long id, String status) {
        RequestApplication selectedApplication = baseMapper.selectById(id);
        if (selectedApplication == null) {
            return false;
        }

        if ("accepted".equals(status)) {
            Long requestId = selectedApplication.getRequestId();
            String requestType = selectedApplication.getRequestType();
            
            QueryWrapper<RequestApplication> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("request_id", requestId)
                       .eq("request_type", requestType);
            
            List<RequestApplication> allApplications = baseMapper.selectList(queryWrapper);
            
            for (RequestApplication app : allApplications) {
                if (app.getId().equals(id)) {
                    app.setStatus("accepted");
                    baseMapper.updateById(app);
                    
                    createAppointmentFromApplication(app);
                    
                    Notification notification = new Notification();
                    notification.setUserId(app.getApplicantId());
                    notification.setType("application_accepted");
                    notification.setTitle("报名申请已被接受");
                    notification.setContent("您的报名申请已被接受，请确认预约");
                    notification.setRelatedId(app.getId().toString());
                    notification.setRelatedType("application");
                    notification.setIsRead(0);
                    notificationService.createNotification(notification);
                } else {
                    app.setStatus("rejected");
                    baseMapper.updateById(app);
                    
                    Notification notification = new Notification();
                    notification.setUserId(app.getApplicantId());
                    notification.setType("application_rejected");
                    notification.setTitle("报名申请已被拒绝");
                    notification.setContent("您的报名申请已被拒绝");
                    notification.setRelatedId(app.getId().toString());
                    notification.setRelatedType("application");
                    notification.setIsRead(0);
                    notificationService.createNotification(notification);
                }
            }
            return true;
        } else {
            selectedApplication.setStatus(status);
            return baseMapper.updateById(selectedApplication) > 0;
        }
    }

    @Override
    @Transactional
    public boolean confirmApplication(Long id) {
        RequestApplication application = baseMapper.selectById(id);
        if (application != null && "accepted".equals(application.getStatus())) {
            application.setStatus("confirmed");
            boolean result = baseMapper.updateById(application) > 0;
            
            if (result) {
                Notification notification = new Notification();
                notification.setUserId(application.getApplicantId());
                notification.setType("application_confirmed");
                notification.setTitle("预约已确认");
                notification.setContent("预约已确认，请按时参加");
                notification.setRelatedId(application.getId().toString());
                notification.setRelatedType("application");
                notification.setIsRead(0);
                notificationService.createNotification(notification);
            }
            
            return result;
        }
        return false;
    }

    private void createAppointmentFromApplication(RequestApplication application) {
        String requestType = application.getRequestType();
        
        if ("student_request".equals(requestType)) {
            StudentRequest request = studentRequestMapper.selectById(application.getRequestId());
            if (request != null) {
                Appointment appointment = new Appointment();
                appointment.setTutorId(application.getApplicantId());
                appointment.setStudentId(request.getUserId());
                appointment.setSubjectId(request.getSubjectId());
                appointment.setSubjectName(request.getSubjectName());
                appointment.setAddress(request.getAddress());
                appointment.setLatitude(request.getLatitude());
                appointment.setLongitude(request.getLongitude());
                appointment.setHourlyRate(request.getHourlyRateMin());
                appointment.setDuration(60);
                appointment.setTotalAmount(request.getHourlyRateMin().multiply(BigDecimal.valueOf(1)));
                appointment.setStatus("pending");
                appointment.setNotes("来自学生需求报名：" + request.getRequirements());
                appointment.setRequestId(application.getRequestId());
                appointment.setRequestType("student_request");
                appointment.setAppointmentTime(LocalDateTime.now().plusDays(1));
                appointmentService.saveAppointment(appointment);
                
                request.setStatus("closed");
                studentRequestMapper.updateById(request);
            }
        } else if ("tutor_profile".equals(requestType)) {
            TutorProfile service = tutorProfileMapper.selectById(application.getRequestId());
            if (service != null) {
                Appointment appointment = new Appointment();
                appointment.setTutorId(service.getUserId());
                appointment.setStudentId(application.getApplicantId());
                appointment.setSubjectId(service.getSubjectId());
                appointment.setSubjectName(service.getSubjectName());
                appointment.setAddress(service.getAddress());
                appointment.setLatitude(service.getLatitude());
                appointment.setLongitude(service.getLongitude());
                appointment.setHourlyRate(service.getHourlyRate());
                appointment.setDuration(60);
                appointment.setTotalAmount(service.getHourlyRate().multiply(BigDecimal.valueOf(1)));
                appointment.setStatus("pending");
                appointment.setNotes("来自家教信息报名：" + service.getDescription());
                appointment.setRequestId(application.getRequestId());
                appointment.setRequestType("tutor_profile");
                appointment.setAppointmentTime(LocalDateTime.now().plusDays(1));
                appointmentService.saveAppointment(appointment);
                
                service.setStatus("busy");
                tutorProfileMapper.updateById(service);
            }
        }
    }

    @Override
    public List<RequestApplication> getApplicationsByRequestId(Long requestId) {
        return baseMapper.selectList(new QueryWrapper<RequestApplication>().eq("request_id", requestId));
    }

    @Override
    public List<RequestApplication> getApplicationsByRequestIdAndType(Long requestId, String requestType) {
        return baseMapper.selectList(new QueryWrapper<RequestApplication>()
                .eq("request_id", requestId)
                .eq("request_type", requestType));
    }

    @Override
    public List<RequestApplication> getApplicationsByApplicantId(String applicantId) {
        return baseMapper.selectList(new QueryWrapper<RequestApplication>().eq("applicant_id", applicantId));
    }
}
