package com.hitutor.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

@TableName("notifications")
public class Notification {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    @TableField(value = "user_id", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String userId;
    
    @TableField(value = "type", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String type;
    
    @TableField(value = "title", insertStrategy = FieldStrategy.NOT_EMPTY)
    private String title;
    
    @TableField(value = "content")
    private String content;
    
    @TableField(value = "related_id")
    private String relatedId;
    
    @TableField(value = "related_type")
    private String relatedType;
    
    @TableField(value = "is_read", insertStrategy = FieldStrategy.NOT_EMPTY)
    private Integer isRead;
    
    @TableField(value = "create_time", fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

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

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getRelatedId() {
        return relatedId;
    }

    public void setRelatedId(String relatedId) {
        this.relatedId = relatedId;
    }

    public String getRelatedType() {
        return relatedType;
    }

    public void setRelatedType(String relatedType) {
        this.relatedType = relatedType;
    }

    public Integer getIsRead() {
        return isRead;
    }

    public void setIsRead(Integer isRead) {
        this.isRead = isRead;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
}
