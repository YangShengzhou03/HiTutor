package com.hitutor.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hitutor.entity.Blacklist;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Delete;

import java.util.List;

@Mapper
public interface BlacklistRepository extends BaseMapper<Blacklist> {
    
    @Select("SELECT * FROM blacklist WHERE user_id = #{userId}")
    List<Blacklist> findByUserId(String userId);
    
    @Select("SELECT * FROM blacklist WHERE user_id = #{userId} AND blocked_user_id = #{blockedUserId}")
    Blacklist findByUserIdAndBlockedUserId(String userId, String blockedUserId);
    
    @Select("SELECT COUNT(*) > 0 FROM blacklist WHERE user_id = #{userId} AND blocked_user_id = #{blockedUserId}")
    boolean existsByUserIdAndBlockedUserId(String userId, String blockedUserId);
    
    @Delete("DELETE FROM blacklist WHERE user_id = #{userId} AND blocked_user_id = #{blockedUserId}")
    void deleteByUserIdAndBlockedUserId(String userId, String blockedUserId);
}