// ✅ THIS IS THE CORRECTED IMPORT
import 'package:chefadmin/services/Api_token_history.dart';

import 'package:chefadmin/models/tokenHostory_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TokenHistoryController extends GetxController {
  // Now this will correctly find the service registered in main.dart
  final ApiService apiService = Get.find<ApiService>(); 

  // --- State Variables ---
  var historyList = <TokenHistoryItem>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var currentPage = 1.obs;
  var hasMoreData = true.obs;

  // --- ✨ NEW STATE for filter ---
  var selectedMealType = 'All'.obs;

  // --- Scroll Controller for pagination ---
  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    _fetchInitialHistory();
    _addScrollListener();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _addScrollListener() {
    scrollController.addListener(() {
      // Check if user is at the end of the list
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !isLoadingMore.value &&
          hasMoreData.value) {
        _fetchMoreHistory();
      }
    });
  }

  // --- ✨ NEW METHOD to change filter ---
  void changeMealType(String newMealType) {
    if (selectedMealType.value == newMealType) return; // No change

    selectedMealType(newMealType);
    // Reset and fetch new data
    _fetchInitialHistory();
  }

  Future<void> _fetchInitialHistory() async {
    try {
      isLoading(true);
      currentPage(1);
      hasMoreData(true);
      historyList
          .clear(); // Clear list before fetching new filtered data

      // --- ✨ UPDATED to pass filter ---
      final items =
          await apiService.fetchTokenHistory(currentPage.value, selectedMealType.value);

      if (items.isEmpty) {
        hasMoreData(false);
      }
      historyList.assignAll(items);
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchMoreHistory() async {
    try {
      isLoadingMore(true);
      currentPage.value++; // Increment page

      // --- ✨ UPDATED to pass filter ---
      final items =
          await apiService.fetchTokenHistory(currentPage.value, selectedMealType.value);

      if (items.isEmpty) {
        hasMoreData(false);
        Get.snackbar('All Done', 'You have reached the end of the history.');
      } else {
        historyList.addAll(items);
      }
    } finally {
      isLoadingMore(false);
    }
  }

  // For pull-to-refresh
  Future<void> refreshHistory() async {
    await _fetchInitialHistory();
  }
}