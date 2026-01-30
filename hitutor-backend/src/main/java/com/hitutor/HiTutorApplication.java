package com.hitutor;

import com.hitutor.service.ReviewService;
import com.hitutor.service.TutorCertificationService;
import com.hitutor.util.DtoConverter;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

import jakarta.annotation.PostConstruct;

@MapperScan({"com.hitutor.mapper", "com.hitutor.repository"})
@SpringBootApplication
@EnableScheduling
public class HiTutorApplication {

    @Autowired
    private ReviewService reviewService;
    
    @Autowired
    private TutorCertificationService tutorCertificationService;

    public static void main(String[] args) {
        SpringApplication.run(HiTutorApplication.class, args);
    }

    @PostConstruct
    public void init() {
        DtoConverter.setReviewService(reviewService);
        DtoConverter.setTutorCertificationService(tutorCertificationService);
    }

}