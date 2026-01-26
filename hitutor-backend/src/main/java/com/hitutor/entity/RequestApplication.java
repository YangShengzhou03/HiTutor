package com.hitutor.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

@TableName("request_applications")
public class RequestApplication {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField(value = "request_id", insertStrategy = FieldStrategy.NOT_EMPTY)
    private Long requestId;
    
    @TableField(value = "request_type", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String requestType;
    
    @TableField(value = "applicant_id", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String applicantId;
    
    @TableField(value = "applicant_name", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String applicantName;
    
    @TableField(value = "applicant_phone", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String applicantPhone;
    
    @TableField(value = "message", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String message;
    
    @TableField(value = "status", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String status;
    
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

    public String getApplicantId() {
        return applicantId;
    }

    public void setApplicantId(String applicantId) {
        this.applicantId = applicantId;
    }

    public String getApplicantName() {
        return applicantName;
    }

    public void setApplicantName(String applicantName) {
        this.applicantName = applicantName;
    }

    public String getApplicantPhone() {
        return applicantPhone;
    }

    public void setApplicantPhone(String applicantPhone) {
        this.applicantPhone = applicantPhone;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
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
