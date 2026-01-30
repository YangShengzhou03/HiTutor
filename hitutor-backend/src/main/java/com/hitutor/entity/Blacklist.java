package com.hitutor.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.LocalDateTime;

@JsonInclude(JsonInclude.Include.NON_NULL)
@TableName("blacklist")
public class Blacklist {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField("user_id")
    private String userId;
    
    @TableField("blocked_user_id")
    private String blockedUserId;

    @TableField("create_time")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
    
    @TableField(exist = false)
    private User user;
    
    @TableField(exist = false)
    private User blockedUser;
    
    public Blacklist() {
        this.createTime = LocalDateTime.now();
    }
    
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
    
    public String getBlockedUserId() {
        return blockedUserId;
    }

    public void setBlockedUserId(String blockedUserId) {
        this.blockedUserId = blockedUserId;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }
    
    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
    
    public User getUser() {
        return user;
    }
    
    public void setUser(User user) {
        this.user = user;
    }
    
    public User getBlockedUser() {
        return blockedUser;
    }
    
    public void setBlockedUser(User blockedUser) {
        this.blockedUser = blockedUser;
    }
}