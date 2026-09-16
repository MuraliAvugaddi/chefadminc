class ApiEndpoints {
  static const String baseUrl =
      "https://chefhospitality-backend-main.onrender.com/api";

  // Admin Routes
  static const String adminBase = "$baseUrl/admin";
  static const String adminUsers = "$adminBase/users";
  static const String adminHistory = "$adminBase/history";
  static const String adminAllPayments = "$adminBase/all-payments";
  static const String adminSkipReport = "$adminBase/skip-report";
  static const String adminDayScholarOrders = "$adminBase/dayscholar-orders";

  // Menu Routes
  static const String menuActive = "$baseUrl/menu/active";
  static const String adminUploadMenu = "$adminBase/admin/menu/upload";

  // Admin Item Management
  static const String adminAddItem = "$adminBase/add-item";
  static const String adminDeleteItem = "$adminBase/delete-item";

  // Special Food Routes
  static const String specialFoodBase = "$baseUrl/special-food";
  static const String specialFoodMenu = "$specialFoodBase/menu";

  // --- FEEDBACK ENDPOINT ---
  static const String adminFeedbackList =
      "$baseUrl/admin/feedback"; // 👈 Added here

  // Token Routes
  static const String tokenStats = "$baseUrl/tokens/stats";

  static const String adminAuthToken = "YOUR_ADMIN_JWT_TOKEN";
}
