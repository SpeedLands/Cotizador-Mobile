import 'package:get/get.dart';
import 'cotizacion_controller.dart';

class CotizacionBinding extends Bindings {
  @override
  void dependencies() {
    // Usamos lazyPut para que el controlador se cree solo cuando se use por primera vez.
    Get.lazyPut<CotizacionController>(CotizacionController.new);
  }
}
