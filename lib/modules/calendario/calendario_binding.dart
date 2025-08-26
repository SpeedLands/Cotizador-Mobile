import 'package:get/get.dart';
import 'calendario_controller.dart';

class CalendarioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalendarioController>(CalendarioController.new);
  }
}
