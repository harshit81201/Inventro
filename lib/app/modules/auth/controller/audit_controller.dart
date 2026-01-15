import 'package:get/get.dart';
import '../../../data/models/audit_log_model.dart';
import '../../../data/services/audit_service.dart';

class AuditController extends GetxController {
  final AuditService _auditService = AuditService();
  
  var isLoading = false.obs;
  var auditLogs = <AuditLogModel>[].obs;
  
  // Pagination variables
  int skip = 0;
  final int limit = 100;

  @override
  void onInit() {
    super.onInit();
    fetchAuditLogs();
  }

  void fetchAuditLogs() async {
    try {
      isLoading(true);
      var logs = await _auditService.getCompanyAuditLogs(skip: skip, limit: limit);
      auditLogs.assignAll(logs);
    } catch (e) {
      Get.snackbar(
        'Error', 
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading(false);
    }
  }

  void refreshLogs() {
    skip = 0;
    fetchAuditLogs();
  }
}