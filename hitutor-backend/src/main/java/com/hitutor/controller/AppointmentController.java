package com.hitutor.controller;

import com.hitutor.dto.AppointmentDTO;
import com.hitutor.entity.Appointment;
import com.hitutor.entity.User;
import com.hitutor.service.AppointmentService;
import com.hitutor.service.UserService;
import com.hitutor.util.DtoConverter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {

    @Autowired
    private AppointmentService appointmentService;

    @Autowired
    private UserService userService;

    @GetMapping("/user/{userId}")
    public ResponseEntity<Map<String, Object>> getAppointmentsByUserId(@PathVariable String userId) {
        if ("all".equals(userId)) {
            List<Appointment> appointments = appointmentService.getAllAppointments();
            
            Set<String> userIds = appointments.stream()
                    .flatMap(appointment -> List.of(appointment.getTutorId(), appointment.getStudentId()).stream())
                    .collect(Collectors.toSet());
            
            List<User> users = userService.getUsersByIds(userIds.stream().toList());
            Map<String, User> userMap = users.stream()
                    .collect(Collectors.toMap(User::getId, user -> user));
            
            List<AppointmentDTO> appointmentDTOs = appointments.stream()
                    .map(appointment -> {
                        User tutor = userMap.get(appointment.getTutorId());
                        User student = userMap.get(appointment.getStudentId());
                        return DtoConverter.toAppointmentDTO(appointment, tutor, student);
                    })
                    .collect(Collectors.toList());
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "获取预约列表成功");
            response.put("data", appointmentDTOs);
            return ResponseEntity.ok(response);
        }
        
        List<Appointment> appointments = appointmentService.getAppointmentsByUserId(userId);
        
        Set<String> userIds = appointments.stream()
                .flatMap(appointment -> List.of(appointment.getTutorId(), appointment.getStudentId()).stream())
                .collect(Collectors.toSet());
        
        List<User> users = userService.getUsersByIds(userIds.stream().toList());
        Map<String, User> userMap = users.stream()
                .collect(Collectors.toMap(User::getId, user -> user));
        
        List<AppointmentDTO> appointmentDTOs = appointments.stream()
                .map(appointment -> {
                    User tutor = userMap.get(appointment.getTutorId());
                    User student = userMap.get(appointment.getStudentId());
                    return DtoConverter.toAppointmentDTO(appointment, tutor, student);
                })
                .collect(Collectors.toList());
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取用户预约列表成功");
        response.put("data", appointmentDTOs);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/tutor/{tutorId}")
    public ResponseEntity<Map<String, Object>> getAppointmentsByTutorId(@PathVariable String tutorId) {
        List<Appointment> appointments = appointmentService.getAppointmentsByTutorId(tutorId);
        
        Set<String> userIds = appointments.stream()
                .flatMap(appointment -> List.of(appointment.getTutorId(), appointment.getStudentId()).stream())
                .collect(Collectors.toSet());
        
        List<User> users = userService.getUsersByIds(userIds.stream().toList());
        Map<String, User> userMap = users.stream()
                .collect(Collectors.toMap(User::getId, user -> user));
        
        List<AppointmentDTO> appointmentDTOs = appointments.stream()
                .map(appointment -> {
                    User tutor = userMap.get(appointment.getTutorId());
                    User student = userMap.get(appointment.getStudentId());
                    return DtoConverter.toAppointmentDTO(appointment, tutor, student);
                })
                .collect(Collectors.toList());
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取家教预约列表成功");
        response.put("data", appointmentDTOs);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getAppointmentById(@PathVariable Long id) {
        Appointment appointment = appointmentService.getAppointmentById(id);
        if (appointment == null) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "预约不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        User tutor = userService.getUserById(appointment.getTutorId());
        User student = userService.getUserById(appointment.getStudentId());
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "获取预约详情成功");
        response.put("data", DtoConverter.toAppointmentDTO(appointment, tutor, student));
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createAppointment(@RequestBody Appointment appointment) {
        if (appointment.getTutorId() == null || appointment.getTutorId().isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "家教ID不能为空");
            return ResponseEntity.badRequest().body(response);
        }
        
        if (appointment.getStudentId() == null || appointment.getStudentId().isEmpty()) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "学生ID不能为空");
            return ResponseEntity.badRequest().body(response);
        }
        
        User tutor = userService.getUserById(appointment.getTutorId());
        User student = userService.getUserById(appointment.getStudentId());
        
        if (tutor == null) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "家教不存在");
            return ResponseEntity.badRequest().body(response);
        }
        
        if (student == null) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "学生不存在");
            return ResponseEntity.badRequest().body(response);
        }
        
        if (!"active".equals(tutor.getStatus())) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "家教账号已被禁用，无法创建预约");
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
        }
        
        if (!"active".equals(student.getStatus())) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "学生账号已被禁用，无法创建预约");
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
        }
        
        boolean saved = appointmentService.saveAppointment(appointment);
        if (!saved) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "创建预约失败");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "创建预约成功");
        response.put("data", DtoConverter.toAppointmentDTO(appointment, tutor, student));
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateAppointment(@PathVariable Long id, @RequestBody Appointment appointment) {
        appointment.setId(id);
        boolean updated = appointmentService.updateAppointment(appointment);
        if (!updated) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "预约不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        User tutor = userService.getUserById(appointment.getTutorId());
        User student = userService.getUserById(appointment.getStudentId());
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "更新预约成功");
        response.put("data", DtoConverter.toAppointmentDTO(appointment, tutor, student));
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteAppointment(@PathVariable Long id) {
        boolean deleted = appointmentService.deleteAppointment(id);
        if (!deleted) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "预约不存在");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "删除预约成功");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/confirm")
    public ResponseEntity<Map<String, Object>> confirmAppointment(@PathVariable Long id) {
        boolean confirmed = appointmentService.confirmAppointment(id);
        if (!confirmed) {
            return ResponseEntity.notFound().build();
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "预约已确认");
        return ResponseEntity.ok(result);
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<Map<String, Object>> cancelAppointment(@PathVariable Long id) {
        boolean cancelled = appointmentService.cancelAppointment(id);
        if (!cancelled) {
            return ResponseEntity.notFound().build();
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "预约已取消");
        return ResponseEntity.ok(result);
    }

    @PutMapping("/{id}/complete")
    public ResponseEntity<Map<String, Object>> completeAppointment(@PathVariable Long id) {
        boolean completed = appointmentService.completeAppointment(id);
        if (!completed) {
            return ResponseEntity.notFound().build();
        }
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "预约已完成");
        return ResponseEntity.ok(result);
    }
}