class ApiEndpoints {

  //--- Production Render URLs (Commented Out) ---
  static const String baseUrl =
      'https://chefhospitality-backend-main.onrender.com/api';
  static const String socketUrl =
      'https://chefhospitality-backend-main.onrender.com/socket';

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

  static const String adminAuthToken = 'YOUR_ADMIN_JWT_TOKEN';
}
