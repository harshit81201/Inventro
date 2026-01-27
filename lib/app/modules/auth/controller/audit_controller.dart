import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/audit_log_model.dart';
import '../../../data/services/audit_service.dart';

class AuditController extends GetxController {
  final AuditService _auditService = AuditService();
  
  // UI State
  var isLoading = false.obs;      // Initial load
  var isLoadingMore = false.obs;  // Pagination load
  var hasMore = true.obs;         // If false, stop trying to load
  var auditLogs = <AuditLogModel>[].obs;
  
  // Pagination
  final int _limit = 10;          // Load 10 items per source per page
  int _currentSkip = 0;           // Track current offset
  
  // Scroll Controller for the ListView
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchInitialLogs();
    
    // Listen to scroll events for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
          !isLoading.value &&
          !isLoadingMore.value &&
          hasMore.value) {
        loadMoreLogs();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // 1. Initial Fetch (First 10 items)
  void fetchInitialLogs() async {
    try {
      isLoading(true);
      _currentSkip = 0;
      hasMore(true);
      
      final logs = await _fetchAndMergeLogs(skip: 0, limit: _limit);
      
      auditLogs.assignAll(logs);
      
      // If we got fewer items than requested, we might be at the end
      if (logs.length < _limit) {
        hasMore(false);
      }
      
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading(false);
    }
  }

  // 2. Load More (Next 10 items)
  void loadMoreLogs() async {
    try {
      isLoadingMore(true);
      
      // Increment skip
      int nextSkip = _currentSkip + _limit;
      
      final newLogs = await _fetchAndMergeLogs(skip: nextSkip, limit: _limit);
      
      if (newLogs.isEmpty) {
        hasMore(false);
      } else {
        // Append new logs to existing list
        auditLogs.addAll(newLogs);
        // Resort the whole list to ensure correct order after merging
        auditLogs.sort((a, b) {
          DateTime dateA = a.createdAt ?? DateTime(2000);
          DateTime dateB = b.createdAt ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        
        _currentSkip = nextSkip; // Update skip only on success
      }
      
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoadingMore(false);
    }
  }

  // Helper: Fetch from both sources and merge
  Future<List<AuditLogModel>> _fetchAndMergeLogs({required int skip, required int limit}) async {
    // Fetch from both endpoints in parallel
    final legacyFuture = _auditService.getLegacyAuditLogs(skip: skip, limit: limit);
    final newFuture = _auditService.getNewProductAuditLogs(skip: skip, limit: limit);

    final results = await Future.wait([legacyFuture, newFuture]);
    
    List<AuditLogModel> combinedLogs = [];
    combinedLogs.addAll(results[0]); // Legacy
    combinedLogs.addAll(results[1]); // New

    // Sort by Date Descending (Newest First)
    combinedLogs.sort((a, b) {
      DateTime dateA = a.createdAt ?? DateTime(2000);
      DateTime dateB = b.createdAt ?? DateTime(2000);
      return dateB.compareTo(dateA); 
    });

    return combinedLogs;
  }

  void refreshLogs() {
    fetchInitialLogs();
  }

  void _showError(String message) {
    Get.snackbar(
      'Error', 
      message.replaceAll('Exception:', '').trim(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      colorText: Get.theme.colorScheme.error,
      duration: const Duration(seconds: 4),
    );
  }
}