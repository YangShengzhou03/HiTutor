package com.hitutor.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@TableName("student_requests")
public class StudentRequest {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("user_id")
    private String userId;
    
    @TableField("child_name")
    private String childName;
    
    @TableField("child_grade")
    private String childGrade;
    
    @TableField("subject_id")
    private Long subjectId;
    
    @TableField("subject_name")
    private String subjectName;
    
    @TableField("hourly_rate_min")
    private BigDecimal hourlyRateMin;
    
    @TableField("hourly_rate_max")
    private BigDecimal hourlyRateMax;
    
    @TableField("address")
    private String address;
    
    @TableField("latitude")
    private BigDecimal latitude;
    
    @TableField("longitude")
    private BigDecimal longitude;
    
    @TableField("requirements")
    private String requirements;
    
    @TableField("available_time")
    private String availableTime;
    
    @TableField("status")
    private String status;
    
    @TableField("create_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
    
    @TableField("update_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getChildName() {
        return childName;
    }

    public void setChildName(String childName) {
        this.childName = childName;
    }

    public String getChildGrade() {
        return childGrade;
    }

    public void setChildGrade(String childGrade) {
        this.childGrade = childGrade;
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

    public BigDecimal getHourlyRateMin() {
        return hourlyRateMin;
    }

    public void setHourlyRateMin(BigDecimal hourlyRateMin) {
        this.hourlyRateMin = hourlyRateMin;
    }

    public BigDecimal getHourlyRateMax() {
        return hourlyRateMax;
    }

    public void setHourlyRateMax(BigDecimal hourlyRateMax) {
        this.hourlyRateMax = hourlyRateMax;
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

    public String getRequirements() {
        return requirements;
    }

    public void setRequirements(String requirements) {
        this.requirements = requirements;
    }

    public String getAvailableTime() {
        return availableTime;
    }

    public void setAvailableTime(String availableTime) {
        this.availableTime = availableTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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