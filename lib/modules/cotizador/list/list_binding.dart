import 'package:get/get.dart';
import 'list_controller.dart';

class ListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ListController.new);
  }
}
