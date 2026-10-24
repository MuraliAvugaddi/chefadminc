class ApiEndpoints {
  // //--- Production Render URLs (Commented Out) ---
  static const String baseUrl =
      'https://chefhospitality-backend-main.onrender.com/api';
  static const String socketUrl =
      'https://chefhospitality-backend-main.onrender.com/socket';
  // Local development URLs
  // static const String baseUrl = 'http://192.168.1.14:5002/api';
  // static const String socketUrl = 'http://192.168.1.14:5002'; // Sockets typically connect to the host root

  static const String adminBase = '$baseUrl/admin';

  static const String adminUsers = '$adminBase/users';
  static const String adminHistory = '$adminBase/history';
  static const String adminAllPayments = '$adminBase/all-payments';
  static const String adminSkipReport = '$adminBase/skip-report';
  static const String adminDayScholarOrders = '$adminBase/dayscholar-orders';

  static const String adminManualPayment = '$adminBase/payments/manual';
  static const String adminDeleteMonthPayment = '$adminBase/payments/month';
  static const String adminExportExcel = '$adminBase/reports/export-excel';

  static const String menuActive = '$baseUrl/menu/active';
  static const String adminUploadMenu = '$baseUrl/admin/menu/upload';
  static const String adminAddItem = '$adminBase/add-item';
  static const String adminDeleteItem = '$adminBase/delete-item';

  static const String specialFoodBase = '$baseUrl/special-food';
  static const String specialFoodMenu = '$specialFoodBase/menu';

  static const String adminFeedbackList = '$baseUrl/admin/feedback';
  static const String tokenStats = '$baseUrl/tokens/stats';

  // ✅ NEW: Payment / server notice shown on admin home screen
  static const String systemNotice = '$baseUrl/system/notice';

  // ✅ NEW: UPI screenshot payments
  static const String paymentSubmissions = '$adminBase/payment-submissions';
  static const String paymentSubmissionCounts =
      '$adminBase/payment-submissions/counts';
  static String approveSubmission(String id) =>
      '$adminBase/payment-submissions/$id/approve';
  static String rejectSubmission(String id) =>
      '$adminBase/payment-submissions/$id/reject';
  static String studentReceipts(String userId) =>
      '$adminBase/students/$userId/receipts';

  static const String submissions = '$adminBase/payment-submissions';
  static const String submissionCounts =
      '$adminBase/payment-submissions/counts';
  static String approve(String id) =>
      '$adminBase/payment-submissions/$id/approve';
  static String reject(String id) =>
      '$adminBase/payment-submissions/$id/reject';
  //static String studentReceipts(String userId) => '$adminBase/students/$userId/receipts';

  static const String adminAuthToken = 'YOUR_ADMIN_JWT_TOKEN';
}
