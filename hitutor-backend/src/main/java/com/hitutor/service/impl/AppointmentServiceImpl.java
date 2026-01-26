package com.hitutor.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hitutor.entity.Appointment;
import com.hitutor.entity.Notification;
import com.hitutor.entity.StudentRequest;
import com.hitutor.entity.TutorProfile;
import com.hitutor.mapper.AppointmentMapper;
import com.hitutor.mapper.StudentRequestMapper;
import com.hitutor.mapper.TutorProfileMapper;
import com.hitutor.service.AppointmentService;
import com.hitutor.service.BlacklistService;
import com.hitutor.service.NotificationService;
import com.hitutor.service.PointService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AppointmentServiceImpl extends ServiceImpl<AppointmentMapper, Appointment> implements AppointmentService {
    
    private final StudentRequestMapper studentRequestMapper;
    private final TutorProfileMapper tutorProfileMapper;
    
    @Autowired
    private BlacklistService blacklistService;
    
    @Autowired
    private PointService pointService;
    
    @Autowired
    private NotificationService notificationService;

    public AppointmentServiceImpl(AppointmentMapper appointmentMapper, 
                                 StudentRequestMapper studentRequestMapper,
                                 TutorProfileMapper tutorProfileMapper) {
        this.studentRequestMapper = studentRequestMapper;
        this.tutorProfileMapper = tutorProfileMapper;
    }

    @Override
    public Appointment getAppointmentById(Long id) {
        return baseMapper.selectById(id);
    }

    @Override
    public List<Appointment> getAllAppointments() {
        return baseMapper.selectList(null);
    }

    @Override
    public List<Appointment> getAppointmentsByUserId(String userId) {
        return baseMapper.selectList(new QueryWrapper<Appointment>()
                .or()
                .eq("student_id", userId)
                .or()
                .eq("tutor_id", userId)
        );
    }

    @Override
    public List<Appointment> getAppointmentsByTutorId(String tutorId) {
        return baseMapper.selectList(new QueryWrapper<Appointment>().eq("tutor_id", tutorId));
    }

    @Override
    @Transactional
    public boolean saveAppointment(Appointment appointment) {
        if (appointment.getStudentId().equals(appointment.getTutorId())) {
            throw new RuntimeException("不能预约自己的服务");
        }
        
        if (blacklistService.isBlocked(appointment.getTutorId(), appointment.getStudentId())) {
            throw new RuntimeException("对方已将您加入黑名单");
        }
        
        if (blacklistService.isBlocked(appointment.getStudentId(), appointment.getTutorId())) {
            throw new RuntimeException("您已将对方加入黑名单");
        }
        
        return baseMapper.insert(appointment) > 0;
    }

    @Override
    public boolean updateAppointment(Appointment appointment) {
        return baseMapper.updateById(appointment) > 0;
    }

    @Override
    public boolean deleteAppointment(Long id) {
        return baseMapper.deleteById(id) > 0;
    }

    @Override
    public boolean confirmAppointment(Long id) {
        Appointment appointment = baseMapper.selectById(id);
        if (appointment == null) {
            return false;
        }
        
        appointment.setStatus("confirmed");
        boolean result = baseMapper.updateById(appointment) > 0;
        
        if (result) {
            Notification notification = new Notification();
            notification.setUserId(appointment.getStudentId());
            notification.setType("appointment_confirmed");
            notification.setTitle("预约已确认");
            notification.setContent("家教已确认您的预约，请按时参加");
            notification.setRelatedId(appointment.getId().toString());
            notification.setRelatedType("appointment");
            notification.setIsRead(0);
            notificationService.createNotification(notification);
        }
        
        return result;
    }

    @Override
    public boolean cancelAppointment(Long id) {
        Appointment appointment = baseMapper.selectById(id);
        if (appointment == null) {
            return false;
        }
        
        appointment.setStatus("cancelled");
        boolean result = baseMapper.updateById(appointment) > 0;
        
        if (result) {
            Notification notification = new Notification();
            notification.setUserId(appointment.getTutorId());
            notification.setType("appointment_cancelled");
            notification.setTitle("预约已取消");
            notification.setContent("学生已取消预约");
            notification.setRelatedId(appointment.getId().toString());
            notification.setRelatedType("appointment");
            notification.setIsRead(0);
            notificationService.createNotification(notification);
        }
        
        return result;
    }

    @Override
    @Transactional
    public boolean completeAppointment(Long id) {
        Appointment appointment = baseMapper.selectById(id);
        if (appointment == null) {
            return false;
        }
        
        appointment.setStatus("completed");
        boolean updated = baseMapper.updateById(appointment) > 0;
        
        if (updated) {
            pointService.addPoints(appointment.getTutorId(), 10, "reward", "完成对接获得积分");
            pointService.addPoints(appointment.getStudentId(), 5, "reward", "完成对接获得积分");
            
            Notification notification = new Notification();
            notification.setUserId(appointment.getTutorId());
            notification.setType("appointment_completed");
            notification.setTitle("预约已完成");
            notification.setContent("预约已完成，获得10积分奖励");
            notification.setRelatedId(appointment.getId().toString());
            notification.setRelatedType("appointment");
            notification.setIsRead(0);
            notificationService.createNotification(notification);
            
            Notification notification2 = new Notification();
            notification2.setUserId(appointment.getStudentId());
            notification2.setType("appointment_completed");
            notification2.setTitle("预约已完成");
            notification2.setContent("预约已完成，获得5积分奖励");
            notification2.setRelatedId(appointment.getId().toString());
            notification2.setRelatedType("appointment");
            notification2.setIsRead(0);
            notificationService.createNotification(notification2);
        }
        
        return updated;
    }
}