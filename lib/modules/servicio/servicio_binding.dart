import 'package:get/get.dart';
import 'servicio_controller.dart';

class ServicioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(ServicioController.new);
  }
}
