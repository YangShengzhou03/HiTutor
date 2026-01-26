import Server from '../utils/Server'
import * as utils from '../utils/utils.js'

const AdminService = {
  login(data) {
    return Server.post('/api/auth/login', data)
  },

  logout() {
    utils.removeToken()
    return Promise.resolve({ success: true, message: '退出登录成功' })
  },

  // 管理员专用注册接口 - 仅需邮箱和密码，不需要验证码
  register(data) {
    return Server.post('/api/admin/register', data)
  },

  getUserInfo() {
    return Server.get('/api/users/me')
  },

  getCurrentUser() {
    return Server.get('/api/users/me')
  },

  updateUserInfo(data) {
    return Server.put(`/api/users/me`, data)
  },

  changePassword(data) {
    return Server.put(`/api/users/me/password`, data)
  },

  getDashboardStats() {
    return Server.get('/api/admin/stats')
  },

  getSubjectDistribution() {
    return Server.get('/api/admin/stats/subject-distribution')
  },

  getUserList(params) {
    return Server.get('/api/admin/users', {
      page: params.page || 1,
      size: params.size || 10
    })
  },

  getUserById(id) {
    return Server.get(`/api/admin/users/${id}`)
  },

  updateUserStatus(id, status) {
    return Server.put(`/api/admin/users/${id}/status`, { status })
  },

  deleteUser(id) {
    return Server.delete(`/api/admin/users/${id}`)
  }
}

const UserService = {
  login(data) {
    return Server.post('/api/auth/login', data)
  },

  logout() {
    utils.removeToken()
    return Promise.resolve({ success: true, message: '退出登录成功' })
  },

  register(data) {
    return Server.post('/api/auth/register', data)
  },

  getCurrentUser() {
    return Server.get('/api/users/me')
  },

  getUserById(id) {
    return Server.get(`/api/users/${id}`)
  },

  updateUser(id, data) {
    return Server.put(`/api/users/${id}`, data)
  },

  updateProfile(id, data) {
    return Server.put(`/api/users/${id}/profile`, data)
  },

  updateUserRole(id, data) {
    return Server.patch(`/api/users/${id}/role`, data)
  },

  getTutors(params) {
    return Server.get('/api/users/tutors', {
      page: params.page || 0,
      size: params.size || 10,
      location: params.location,
      subject: params.subject
    })
  },

  searchTutors(params) {
    return Server.get('/api/users/tutors/search', {
      q: params.q,
      page: params.page || 0,
      size: params.size || 10,
      location: params.location,
      subject: params.subject
    })
  }
}

const ComplaintService = {
  getComplaints(params) {
    return Server.get('/api/complaints', {
      page: params.page || 0,
      size: params.size || 10,
      status: params.status
    })
  },

  getMyComplaints() {
    return Server.get('/api/complaints/my')
  },

  getComplaintById(id) {
    return Server.get(`/api/complaints/${id}`)
  },

  updateComplaintStatus(id, status) {
    return Server.put(`/api/complaints/${id}/status`, { status })
  },

  deleteComplaint(id) {
    return Server.delete(`/api/complaints/${id}`)
  },

  createComplaint(data) {
    return Server.post('/api/complaints', data)
  }
}

const TutorCertificationService = {
  getCertificationByUserId(userId) {
    return Server.get(`/api/tutor-certifications/user/${userId}`)
  },

  getAllCertifications() {
    return Server.get('/api/tutor-certifications/all')
  },

  submitCertification(data) {
    return Server.post('/api/tutor-certifications', data)
  },

  updateCertificationStatus(id, status) {
    return Server.put(`/api/tutor-certifications/${id}/status`, { status })
  }
}

const StudentRequestService = {
  createStudentRequest(data) {
    return Server.post('/api/student-requests', data)
  },

  getNearbyRequests(params) {
    return Server.get('/api/student-requests/nearby', {
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.radius || 10,
      subject: params.subject
    })
  },

  getAllStudentRequests(params) {
    return Server.get('/api/student-requests', {
      page: params.page || 0,
      size: params.size || 10
    })
  },

  getStudentRequestById(id) {
    return Server.get(`/api/student-requests/${id}`)
  },

  updateStudentRequest(id, data) {
    return Server.put(`/api/student-requests/${id}`, data)
  },

  deleteStudentRequest(id) {
    return Server.delete(`/api/student-requests/${id}`)
  },

  getUserRequests() {
    return Server.get('/api/student-requests/user')
  },

  searchStudentRequests(params) {
    return Server.get('/api/student-requests/search', {
      q: params.q,
      page: params.page || 0,
      size: params.size || 10,
      location: params.location,
      subject: params.subject
    })
  }
}

const TutorProfileService = {
  createTutorProfile(data) {
    return Server.post('/api/tutor-profiles', data)
  },

  getNearbyTutors(params) {
    return Server.get('/api/tutor-profiles/nearby', {
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.radius || 10,
      subject: params.subject
    })
  },

  getAllTutorProfiles(params) {
    return Server.get('/api/tutor-profiles', {
      page: params.page || 0,
      size: params.size || 10
    })
  },

  getTutorProfileById(id) {
    return Server.get(`/api/tutor-profiles/${id}`)
  },

  updateTutorProfile(id, data) {
    return Server.put(`/api/tutor-profiles/${id}`, data)
  },

  deleteTutorProfile(id) {
    return Server.delete(`/api/tutor-profiles/${id}`)
  },

  getUserProfiles() {
    return Server.get('/api/tutor-profiles/user')
  }
}

const SubjectService = {
  getAllSubjects() {
    return Server.get('/api/subjects')
  },

  getActiveSubjects() {
    return Server.get('/api/subjects/active')
  },

  getSubjectById(id) {
    return Server.get(`/api/subjects/${id}`)
  },

  createSubject(data) {
    return Server.post('/api/subjects', data)
  },

  updateSubject(id, data) {
    return Server.put(`/api/subjects/${id}`, data)
  },

  deleteSubject(id) {
    return Server.delete(`/api/subjects/${id}`)
  }
}

const BlacklistService = {
  getUserBlacklist() {
    return Server.get('/api/blacklist')
  },

  getAllBlacklist(params) {
    return Server.get('/api/blacklist/admin/all', {
      page: params.page || 0,
      size: params.size || 20
    })
  },

  deleteBlacklistEntry(id) {
    return Server.delete(`/api/blacklist/admin/${id}`)
  },

  checkBlocked(blockedUserId) {
    return Server.get(`/api/blacklist/check/${blockedUserId}`)
  },

  addToBlacklist(data) {
    return Server.post('/api/blacklist', data)
  },

  removeFromBlacklist(blockedUserId) {
    return Server.delete(`/api/blacklist/${blockedUserId}`)
  }
}

const AppointmentService = {
  getAppointmentsByUserId(userId) {
    return Server.get(`/api/appointments/user/${userId}`)
  },

  getAppointmentsByTutorId(tutorId) {
    return Server.get(`/api/appointments/tutor/${tutorId}`)
  },

  getAppointmentById(id) {
    return Server.get(`/api/appointments/${id}`)
  },

  createAppointment(data) {
    return Server.post('/api/appointments', data)
  },

  updateAppointment(id, data) {
    return Server.put(`/api/appointments/${id}`, data)
  },

  deleteAppointment(id) {
    return Server.delete(`/api/appointments/${id}`)
  },

  confirmAppointment(id) {
    return Server.put(`/api/appointments/${id}/confirm`)
  },

  cancelAppointment(id) {
    return Server.put(`/api/appointments/${id}/cancel`)
  },

  completeAppointment(id) {
    return Server.put(`/api/appointments/${id}/complete`)
  }
}

const ReviewService = {
  getReviewsByTutorId(tutorId) {
    return Server.get(`/api/reviews/tutor/${tutorId}`)
  },

  getReviewsByUserId(userId) {
    return Server.get(`/api/reviews/user/${userId}`)
  },

  createReview(data) {
    return Server.post('/api/reviews', data)
  },

  getReviewById(id) {
    return Server.get(`/api/reviews/${id}`)
  }
}

const TutorResumeService = {
  getResumeByUserId(userId) {
    return Server.get(`/api/tutor-resumes/user/${userId}`)
  },

  getAllTutorResumes(params) {
    return Server.get('/api/tutor-resumes', {
      page: params.page || 0,
      size: params.size || 10
    })
  },

  getTutorResumeById(id) {
    return Server.get(`/api/tutor-resumes/${id}`)
  },

  saveOrUpdateResume(data) {
    return Server.post('/api/tutor-resumes', data)
  },

  updateTutorResume(id, data) {
    return Server.put(`/api/tutor-resumes/${id}`, data)
  },

  deleteTutorResume(id) {
    return Server.delete(`/api/tutor-resumes/${id}`)
  }
}

const PointService = {
  getPointRecords(userId) {
    return Server.get(`/api/points/records?userId=${userId}`)
  },

  getTotalPoints(userId) {
    return Server.get(`/api/points/total?userId=${userId}`)
  },

  adminAddPoints(data) {
    return Server.post('/api/points/admin/add', data)
  },

  adminDeductPoints(data) {
    return Server.post('/api/points/admin/deduct', data)
  }
}

export default {
  admin: AdminService,
  user: UserService,
  complaint: ComplaintService,
  tutorCertification: TutorCertificationService,
  studentRequest: StudentRequestService,
  tutorProfile: TutorProfileService,
  subject: SubjectService,
  blacklist: BlacklistService,
  appointment: AppointmentService,
  review: ReviewService,
  tutorResume: TutorResumeService,
  point: PointService
}
