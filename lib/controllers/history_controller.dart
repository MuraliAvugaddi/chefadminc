import 'package:chefadmin/models/tokenHostory_model.dart';
import 'package:chefadmin/services/Api_token_history.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TokenHistoryController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();

  var historyList = <TokenHistoryItem>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  var selectedMealType = 'All'.obs;

  // ✅ Calendar State
  var selectedDate = DateTime.now().obs;

  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    fetchInitialHistory();
    _addScrollListener();
  }

  void _addScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore.value && hasMoreData.value) {
        fetchMoreHistory();
      }
    });
  }

  // ✅ Method to change date from calendar
  void updateDate(DateTime date) {
    selectedDate.value = date;
    fetchInitialHistory();
  }

  void changeMealType(String newMealType) {
    if (selectedMealType.value == newMealType) return;
    selectedMealType(newMealType);
    fetchInitialHistory();
  }

  Future<void> fetchInitialHistory() async {
    try {
      isLoading(true);
      currentPage(1);
      hasMoreData(true);
      historyList.clear();

      // Debug print to check what URL is being hit
      print("Fetching history for Meal: ${selectedMealType.value}, Date: ${DateFormat('yyyy-MM-dd').format(selectedDate.value)}");

      final items = await apiService.fetchTokenHistory(
        currentPage.value, 
        selectedMealType.value,
        date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
      );

      print("Fetched items count: ${items.length}");
      if (items.length < 20) hasMoreData(false);
      historyList.assignAll(items);
    } catch (e) {
      print("Error in fetchInitialHistory: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMoreHistory() async {
    try {
      isLoadingMore(true);
      currentPage.value++;
      final items = await apiService.fetchTokenHistory(
        currentPage.value, 
        selectedMealType.value,
        date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
      );
      if (items.isEmpty) {
        hasMoreData(false);
      } else {
        historyList.addAll(items);
      }
    } catch (e) {
      print("Error in fetchMoreHistory: $e");
    } finally {
      isLoadingMore(false);
    }
  }
}