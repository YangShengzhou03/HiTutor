package com.hitutor.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("appointments")
public class Appointment {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField(value = "tutor_id", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String tutorId;
    
    @TableField(value = "student_id", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String studentId;
    
    @TableField(value = "subject_id", insertStrategy = FieldStrategy.NOT_EMPTY)
    private Long subjectId;
    
    @TableField(value = "subject_name", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String subjectName;
    
    @TableField(value = "appointment_time", insertStrategy = FieldStrategy.NOT_EMPTY)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime appointmentTime;
    
    @TableField(value = "duration", insertStrategy = FieldStrategy.NOT_EMPTY)
    private Integer duration;
    
    @TableField(value = "address", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String address;
    
    @TableField(value = "latitude", insertStrategy = FieldStrategy.NOT_EMPTY)
    private BigDecimal latitude;
    
    @TableField(value = "longitude", insertStrategy = FieldStrategy.NOT_EMPTY)
    private BigDecimal longitude;
    
    @TableField(value = "hourly_rate", insertStrategy = FieldStrategy.NOT_EMPTY)
    private BigDecimal hourlyRate;
    
    @TableField(value = "total_amount", insertStrategy = FieldStrategy.NOT_EMPTY)
    private BigDecimal totalAmount;
    
    @TableField(value = "status", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String status;
    
    @TableField(value = "notes", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String notes;
    
    @TableField(value = "request_id")
    private Long requestId;
    
    @TableField(value = "request_type")
    private String requestType;
    
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
    
    @TableField(value = "update_time", fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTutorId() {
        return tutorId;
    }

    public void setTutorId(String tutorId) {
        this.tutorId = tutorId;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public Long getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(Long subjectId) {
        this.subjectId = subjectId;
    }

    public String getSubjectName() {
        return subjectName;
    }

    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }

    public LocalDateTime getAppointmentTime() {
        return appointmentTime;
    }

    public void setAppointmentTime(LocalDateTime appointmentTime) {
        this.appointmentTime = appointmentTime;
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public BigDecimal getLatitude() {
        return latitude;
    }

    public void setLatitude(BigDecimal latitude) {
        this.latitude = latitude;
    }

    public BigDecimal getLongitude() {
        return longitude;
    }

    public void setLongitude(BigDecimal longitude) {
        this.longitude = longitude;
    }

    public BigDecimal getHourlyRate() {
        return hourlyRate;
    }

    public void setHourlyRate(BigDecimal hourlyRate) {
        this.hourlyRate = hourlyRate;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Long getRequestId() {
        return requestId;
    }

    public void setRequestId(Long requestId) {
        this.requestId = requestId;
    }

    public String getRequestType() {
        return requestType;
    }

    public void setRequestType(String requestType) {
        this.requestType = requestType;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }
}