package com.hitutor.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.hitutor.entity.Appointment;

import java.util.List;

public interface AppointmentService extends IService<Appointment> {
    Appointment getAppointmentById(Long id);
    List<Appointment> getAppointmentsByUserId(String userId);
    List<Appointment> getAppointmentsByTutorId(String tutorId);
    List<Appointment> getAllAppointments();
    boolean saveAppointment(Appointment appointment);
    boolean updateAppointment(Appointment appointment);
    boolean deleteAppointment(Long id);
    boolean confirmAppointment(Long id);
    boolean cancelAppointment(Long id);
    boolean completeAppointment(Long id);
}