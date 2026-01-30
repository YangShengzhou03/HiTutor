package com.hitutor.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.hitutor.entity.Complaint;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ComplaintMapper extends BaseMapper<Complaint> {
}