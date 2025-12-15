import 'package:get/get.dart';
import '../controller/bulk_upload_controller.dart';

class BulkUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BulkUploadController>(() => BulkUploadController());
  }
}