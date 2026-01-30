import 'package:flutter/material.dart';
import 'pages/main/splash_page.dart';
import 'pages/auth/sms_login_page.dart';
import 'pages/auth/password_login_page.dart';
import 'pages/auth/forgot_password_page.dart';
import 'pages/auth/role_selection_page.dart';
import 'pages/main/main_tab_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/settings/profile_edit_page.dart';
import 'pages/settings/account_security_page.dart';
import 'pages/settings/change_phone_page.dart';
import 'pages/settings/change_email_page.dart';
import 'pages/about/user_agreement_page.dart';
import 'pages/about/privacy_policy_page.dart';
import 'pages/about/about_us_page.dart';

import 'pages/about/complaint_page.dart';
import 'pages/about/complaint_list_page.dart';
import 'pages/publish/publish_student_request_page.dart';
import 'pages/publish/publish_tutor_service_page.dart';
import 'pages/student_request/student_request_detail_page.dart';
import 'pages/tutor_service/tutor_service_detail_page.dart';
import 'pages/review/review_page.dart';
import 'pages/appointment/appointment_page.dart';
import 'pages/settings/blacklist_page.dart';
import 'pages/services/customer_service_page.dart';
import 'pages/services/favorites_page.dart';
import 'pages/services/my_reviews_page.dart';
import 'pages/services/tutor_certification_page.dart';
import 'pages/services/tutor_resume_page.dart';
import 'pages/map/map_page.dart';
import 'pages/application/application_form_page.dart';
import 'pages/application/application_detail_page.dart';
import 'pages/chat/chat_detail_page.dart';
import 'pages/services/points_page.dart';
import 'pages/services/points_detail_page.dart';
import 'pages/services/my_publishings_page.dart';
import 'pages/application/my_applications_page.dart';
import 'pages/user/user_profile_page.dart';
import 'pages/notification/notification_page.dart';
import 'pages/subject/subject_explore_page.dart';

class Routes {
  static const String splash = '/';
  static const String smsLogin = '/sms-login';
  static const String passwordLogin = '/password-login';
  static const String forgotPassword = '/forgot-password';
  static const String roleSelection = '/role-selection';
  static const String mainTab = '/main-tab';
  static const String settings = '/settings';
  static const String userAgreement = '/user-agreement';
  static const String privacyPolicy = '/privacy-policy';
  static const String publishStudentRequest = '/publish-student-request';
  static const String publishTutorService = '/publish-tutor-service';
  static const String tutorDetail = '/tutor-detail';
  static const String studentRequestDetail = '/student-request-detail';
  static const String tutorServiceDetail = '/tutor-service-detail';
  static const String appointment = '/appointment';
  static const String review = '/review';
  static const String profileEdit = '/profile-edit';
  static const String accountSecurity = '/account-security';
  static const String changePhone = '/change-phone';
  static const String changeEmail = '/change-email';
  static const String aboutUs = '/about-us';

  static const String complaint = '/complaint';
  static const String complaintList = '/complaint-list';
  static const String customerService = '/customer-service';
  static const String favorites = '/favorites';
  static const String myReviews = '/my-reviews';
  static const String tutorCertification = '/tutor-certification';
  static const String tutorResume = '/tutor-resume';
  static const String map = '/map';
  static const String applicationForm = '/application-form';
  static const String applicationDetail = '/application-detail';

  static const String chatDetail = '/chat-detail';
  static const String blacklist = '/blacklist';
  static const String points = '/points';
  static const String pointsDetail = '/points-detail';
  static const String myPublishings = '/my-publishings';
  static const String myApplications = '/my-applications';
  static const String userProfile = '/user-profile';
  static const String notification = '/notification';
  static const String subjectExplore = '/subject-explore';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashAdPage(),
      smsLogin: (context) => const SmsLoginPage(),
      passwordLogin: (context) => const PasswordLoginPage(),
      forgotPassword: (context) => const ForgotPasswordPage(),
      roleSelection: (context) {
        final userId = ModalRoute.of(context)?.settings.arguments as String?;
        return RoleSelectionPage(userId: userId ?? '');
      },
      mainTab: (context) => const MainTabPage(),
      settings: (context) => const SettingsPage(),
      userAgreement: (context) => const UserAgreementPage(),
      privacyPolicy: (context) => const PrivacyPolicyPage(),
      publishStudentRequest: (context) => const PublishStudentRequestPage(),
      publishTutorService: (context) => const PublishTutorServicePage(),
      studentRequestDetail: (context) {
        final request = ModalRoute.of(context)?.settings.arguments as dynamic;
        return StudentRequestDetailPage(request: request);
      },
      tutorServiceDetail: (context) {
        final tutor = ModalRoute.of(context)?.settings.arguments as dynamic;
        return TutorServiceDetailPage(tutor: tutor);
      },
      appointment: (context) => const AppointmentPage(),
      review: (context) => ReviewPage(
        appointmentId: ModalRoute.of(context)!.settings.arguments as String? ?? '',
        tutorId: '',
        tutorName: '',
      ),
      profileEdit: (context) => const ProfileEditPage(),
      accountSecurity: (context) => const AccountSecurityPage(),
      changePhone: (context) => const ChangePhonePage(),
      changeEmail: (context) => const ChangeEmailPage(),
      blacklist: (context) => const BlacklistPage(),
      aboutUs: (context) => const AboutUsPage(),

      complaint: (context) => const ComplaintPage(),
      complaintList: (context) => const ComplaintListPage(),
      customerService: (context) => const CustomerServicePage(),
      favorites: (context) => const FavoritesPage(),
      myReviews: (context) => const MyReviewsPage(),
      tutorCertification: (context) => const TutorCertificationPage(),
      tutorResume: (context) => const TutorResumePage(),
      map: (context) => MapPage(role: ModalRoute.of(context)!.settings.arguments as String? ?? 'student'),
      points: (context) => const PointsPage(),
      pointsDetail: (context) => const PointsDetailPage(),
      myPublishings: (context) => const MyPublishingsPage(),
      myApplications: (context) => const MyApplicationsPage(),
      applicationForm: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return ApplicationFormPage(
          requestId: args?['requestId']?.toString() ?? '',
          requestType: args?['requestType']?.toString() ?? '',
          title: args?['title']?.toString() ?? '',
        );
      },
      applicationDetail: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return ApplicationDetailPage(
          application: args?['application'] as Map<String, dynamic>? ?? {},
        );
      },
      chatDetail: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return ChatDetailPage(
          conversationId: args?['conversationId']?.toString() ?? '',
          otherUserId: args?['otherUserId']?.toString() ?? '',
          otherUserName: args?['otherUserName']?.toString() ?? '',
        );
      },
      userProfile: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return UserProfilePage(
          userId: args?['userId']?.toString() ?? '',
          userName: args?['userName']?.toString() ?? '',
        );
      },
      notification: (context) => const NotificationPage(),
      subjectExplore: (context) {
        final defaultSubject = ModalRoute.of(context)?.settings.arguments as String?;
        return SubjectExplorePage(defaultSubject: defaultSubject);
      },
    };
  }

  static Map<String, WidgetBuilder> get routes => getRoutes();
}
