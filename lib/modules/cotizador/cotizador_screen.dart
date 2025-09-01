import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_input/phone_input_package.dart';

import '../../data/models/cotizacion_model.dart';
import '../../global/custom_button.dart';
import '../../global/styles/app_colors.dart';
import '../../global/styles/app_text_styles.dart';
import '../../global/widgets/custom_dropdown_form_field.dart';
import '../../global/widgets/custom_scaffold.dart';
import '../../global/widgets/custom_text_form_field.dart';
import '../../global/widgets/loading_indicator.dart';
import '../../routes/app_routes.dart';
import 'cotizacion_controller.dart';

class CotizadorScreen extends StatefulWidget {
  const CotizadorScreen({super.key});

  @override
  State<CotizadorScreen> createState() => CotizadorScreenState();
}

class CotizadorScreenState extends State<CotizadorScreen> {
  final CotizacionController controller = Get.find<CotizacionController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller.loadGuestCotizacion();
    controller.cantidadInvitadosController.addListener(
      controller.recalcularTotal,
    );
  }

  @override
  Widget build(BuildContext context) => CustomScaffold(
    title: 'Cotiza tu Evento al Instante',
    actions: [
      IconButton(
        icon: const Icon(Icons.admin_panel_settings_outlined),
        tooltip: 'Acceso de Administrador',
        onPressed: () {
          Get.toNamed(AppRoutes.LOGIN);
        },
      ),
    ],
    body: FutureBuilder(
      future: controller.inicializarCotizador(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingIndicator();
        }
        if (snapshot.hasError || controller.errorMessage.value != null) {
          return Center(
            child: Text(
              controller.errorMessage.value ?? 'Ocurrió un error',
              style: AppTextStyles.bodyText1,
            ),
          );
        }

        // Aquí solo decides si mostrar cotización guardada o formulario
        return Obx(() {
          if (controller.cotizacionInvitado.value != null) {
            return _buildSavedQuoteSummary(
              context,
              controller.cotizacionInvitado.value!,
            );
          } else {
            return _buildForm(context);
          }
        });
      },
    ),
  );

  Widget _buildForm(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Column(
      children: [
        _buildResumenCard(),
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20.0 + bottomPadding),
              children: [
                // --- SECCIONES DEL FORMULARIO ---
                _buildSectionTitle('1. Información de Contacto'),
                _buildTextField(
                  controller: controller.nombreCompletoController,
                  label: 'Nombre Completo*',
                  hintText: 'Ej. Gerardo Buena Vista',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre completo es requerido';
                    }
                    if (value.trim().length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'WhatsApp*',
                          style: AppTextStyles.bodyText1,
                        ),
                      ),
                      PhoneInput(
                        defaultCountry: IsoCode.MX,
                        countrySelectorNavigator:
                            const CountrySelectorNavigator.dialog(),
                        decoration: InputDecoration(
                          hintText: '878 123 4567',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                        onChanged: (PhoneNumber? phone) {
                          controller.whatsappNumber.value =
                              '${phone?.international}';
                        },
                      ),
                      Obx(() {
                        final whatsapp = controller.whatsappNumber.value;
                        if (whatsapp.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              'El número de WhatsApp es requerido',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          );
                        } else if (whatsapp.length < 10) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              'Ingresa un número válido',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),

                _buildSectionTitle('2. Detalles del Evento'),
                _buildDropdown(
                  label: 'Tipo de Evento*',
                  value: controller.tipoEvento,
                  items: const [
                    {'display': 'Evento Social', 'value': 'Social'},
                    {
                      'display': 'Evento Empresarial o Corporativo',
                      'value': 'Empresarial',
                    },
                    {'display': 'Otro', 'value': 'Otro'},
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona un tipo de evento';
                    }
                    return null;
                  },
                ),
                _buildConditionalTextField(
                  triggerValue: controller.tipoEvento,
                  expectedValue: 'Empresarial',
                  controller: controller.nombreEmpresaController,
                  label: 'Nombre de la Empresa*',
                  hintText: 'Ej. Mapolato',
                  validator: (value) {
                    if (controller.tipoEvento.value == 'Empresarial') {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre de la empresa es requerido';
                      }
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  controller: controller.direccionEventoController,
                  label: 'Dirección del Evento*',
                  hintText: 'Ej. Salón Las Palmas, Blvd. Hidalgo #321',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La dirección del evento es requerida';
                    }
                    if (value.trim().length < 10) {
                      return 'La dirección debe ser más específica';
                    }
                    return null;
                  },
                ),

                _buildDateField(context),

                _buildTextField(
                  controller: controller.horaEventoController,
                  label: 'Hora del Evento',
                  hintText: 'Ej. 7:30 PM',
                  readOnly: true, // Impide que aparezca el teclado
                  onTap: () => controller.seleccionarHora(
                    context,
                    controller.horaEventoController,
                  ), // Llama al picker al tocar
                ),

                _buildTextField(
                  controller: controller.horarioConsumoController,
                  label: 'Horario de Consumo',
                  hintText: 'Ej. De 8:00 PM a 12:00 AM',
                ),

                _buildTextField(
                  controller: controller.cantidadInvitadosController,
                  label: 'Cantidad de Invitados*',
                  hintText: 'Ej. 120 invitados',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La cantidad de invitados es requerida';
                    }
                    final cantidad = int.tryParse(value);
                    if (cantidad == null || cantidad <= 0) {
                      return 'Ingresa una cantidad válida mayor a 0';
                    }
                    if (cantidad > 1000) {
                      return 'La cantidad máxima es 1000 invitados';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                // --- SECCIÓN 3: SERVICIOS ---
                _buildSectionTitle('3. Servicios'),
                const Text(
                  '¿Qué Gustas en tu Cotización?*',
                  style: AppTextStyles.headline3,
                ),
                _buildServiciosRegularesList(), // Checkboxes
                Obx(() {
                  if (controller.serviciosSeleccionados.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        'Selecciona al menos un servicio',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 24),
                const Text(
                  'Modalidad del Servicio',
                  style: AppTextStyles.headline3,
                ),
                _buildModalidadesList(), // Radio Buttons

                _buildTextField(
                  controller: controller.serviciosOtrosController,
                  label: 'Otros servicios que no estén en la lista:',
                  hintText:
                      'Ej. Barra de postres, coctelería premium, DJ, etc.',
                  maxLines: 2,
                ),

                _buildSectionTitle('4. Detalles Finales'),

                _buildDropdown(
                  label: '¿Gusta Agregar mesa y mantel para el servicio?',
                  value: controller.mesaMantel,
                  items: const [
                    {'display': 'Si', 'value': 'Si'},
                    {'display': 'No', 'value': 'No'},
                    {'display': 'Otro', 'value': 'otro'},
                  ],
                ),
                Obx(
                  () => controller.mesaMantel.value == 'otro'
                      ? _buildTextField(
                          controller: controller.mesaMantelOtroController,
                          label: 'Por favor, especifica*',
                          hintText:
                              'Ej. Manteles negros con servilletas doradas',
                          validator: (value) {
                            if (controller.mesaMantel.value == 'otro') {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, especifica los detalles';
                              }
                            }
                            return null;
                          },
                        )
                      : const SizedBox.shrink(),
                ),

                _buildDropdown(
                  label: '¿Gusta que alguien esté sirviendo en el evento?',
                  value: controller.personalServicio,
                  items: const [
                    {'display': 'Si', 'value': 'Si'},
                    {'display': 'No', 'value': 'No'},
                  ],
                ),

                Obx(() {
                  if (controller.serviciosSeleccionados.contains(7)) {
                    return _buildDropdown(
                      label:
                          'Para el servicio de café, ¿hay acceso a enchufes cerca?',
                      value: controller.accesoEnchufe,
                      items: const [
                        {'display': 'Sí, hay cerca', 'value': 'Si'},
                        {
                          'display': 'No hay cerca, se necesita extensión',
                          'value': 'No',
                        },
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                _buildTextField(
                  controller: controller.dificultadMontajeController,
                  label: 'Dificultad de Montaje',
                  hintText:
                      'Ej. Acceso en segundo piso, escaleras estrechas, área exterior con pasto',
                ),

                _buildDropdown(
                  label: '¿Cómo supiste de nosotros?',
                  value: controller.comoSupiste,
                  items: const [
                    {'display': 'Recomendación', 'value': 'Recomendacion'},
                    {'display': 'Redes Sociales', 'value': 'Redes Sociales'},
                    {
                      'display': 'Por el Restaurante',
                      'value': 'Por el Restaurante',
                    },
                    {'display': 'Otro', 'value': 'Otro'},
                  ],
                ),
                Obx(
                  () => controller.comoSupiste.value == 'otro'
                      ? _buildTextField(
                          controller: controller.comoSupisteOtroController,
                          label: 'Por favor, especifica*',
                          hintText:
                              'Ej. Valla publicitaria, evento en plaza, etc.',
                          validator: (value) {
                            if (controller.comoSupiste.value == 'otro') {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, especifica cómo supiste de nosotros';
                              }
                            }
                            return null;
                          },
                        )
                      : const SizedBox.shrink(),
                ),

                _buildDropdown(
                  label: 'Tipo de Consumidores',
                  value: controller.tipoConsumidores,
                  items: const [
                    {'display': 'Hombres', 'value': 'Hombres'},
                    {'display': 'Mujeres', 'value': 'Mujeres'},
                    {'display': 'Niños', 'value': 'Niños'},
                    {'display': 'Mixto', 'value': 'Mixto'},
                  ],
                ),

                _buildTextField(
                  controller: controller.restriccionesController,
                  label: '¿Alguna restricción alimenticia?',
                  hintText: 'Ej. Menú vegetariano, sin gluten, sin lácteos',
                ),

                _buildTextField(
                  controller: controller.requisitosAdicionalesController,
                  label: '¿Requisitos Adicionales o especiales?',
                  hintText:
                      'Ej. Decoración especial, área infantil, iluminación ambiental',
                ),

                _buildTextField(
                  controller: controller.presupuestoController,
                  label: '¿Rango de presupuesto en mente?',
                  hintText: 'Ej. Entre \$15,000 y \$20,000 MXN',
                ),

                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResumenCard() => ExpansionTile(
    title: Text(
      'Total Estimado: \$${controller.subtotal.value.toStringAsFixed(2)}',
      style: AppTextStyles.headline3,
    ),
    children: [
      Obx(() {
        if (controller.resumenItems.isEmpty) {
          return const Text('Selecciona un servicio para ver el costo.');
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...controller.resumenItems.map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(item['nombre']!),
                  trailing: Text('${item['costo']}'),
                ),
              ),
            ],
          ),
        );
      }),
    ],
  );

  Widget _buildDateField(BuildContext context) => _buildTextField(
    controller: controller.fechaEventoController,
    label: 'Fecha del Evento*',
    hintText: 'Selecciona la fecha en el calendario',
    readOnly: true, // Para que no se pueda escribir
    onTap: () =>
        controller.seleccionarFecha(context), // Abre el picker al tocar
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'La fecha del evento es requerida';
      }
      return null;
    },
  );

  Widget _buildDropdown({
    required String label,
    required RxString value,
    required List<Map<String, String>> items,
    String? Function(String?)? validator,
  }) => Obx(
    () => CustomDropdownFormField<String>(
      labelText: label,
      value: value.value.isEmpty ? null : value.value,
      items: items
          .map(
            (Map<String, String> item) => DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['display']!),
            ),
          )
          .toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          value.value = newValue;
        }
      },
      validator: validator,
    ),
  );

  Widget _buildConditionalTextField({
    required RxString triggerValue,
    required String expectedValue,
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? Function(String?)? validator,
  }) => Obx(() {
    if (triggerValue.value == expectedValue) {
      return _buildTextField(
        controller: controller,
        label: label,
        hintText: hintText,
        validator: validator,
      );
    } else {
      return const SizedBox.shrink();
    }
  });

  // Widget de ayuda para crear los títulos de sección
  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(title, style: AppTextStyles.headline2),
  );

  Widget _buildServiciosRegularesList() => Obx(() {
    final cantidadInvitados =
        int.tryParse(controller.cantidadInvitadosController.text) ?? 0;
    return Column(
      children: controller.serviciosRegulares.map((servicio) {
        final bool isDisabled = cantidadInvitados < servicio.minPersonas;
        return CheckboxListTile(
          title: Text(
            servicio.nombre,
            style: TextStyle(
              color: isDisabled ? AppColors.grey : AppColors.text,
            ),
          ),
          subtitle: Text('Mínimo: ${servicio.minPersonas} personas'),
          value: controller.serviciosSeleccionados.contains(servicio.id),
          onChanged: isDisabled
              ? null
              : (value) => controller.toggleServicio(servicio.id),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  });

  Widget _buildModalidadesList() => Obx(
    () => RadioGroup(
      groupValue: controller.modalidadSeleccionada.value,
      onChanged: controller.seleccionarModalidad,
      child: Column(
        children: controller.modalidades.map((modalidad) {
          final precio = double.parse(modalidad.precioBase);
          return RadioListTile<int>(
            title: Text(modalidad.nombre.replaceFirst('Modalidad: ', '')),
            subtitle: Text(
              precio > 0 ? '(Costo adicional)' : '(Opción estándar)',
              style: TextStyle(
                color: precio > 0 ? AppColors.green : AppColors.grey,
              ),
            ),
            value: modalidad.id,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    ),
  );

  Widget _buildSubmitButton() => Obx(
    () => ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: controller.isLoading.value
          ? null
          : () {
              final isWhatsAppValid =
                  controller.whatsappNumber.value.isNotEmpty &&
                  controller.whatsappNumber.value.length >= 10;

              if (_formKey.currentState!.validate() &&
                  controller.serviciosSeleccionados.isNotEmpty &&
                  isWhatsAppValid) {
                controller.crearCotizacionInvitado();
              } else {
                Get.snackbar(
                  'Error de Validación',
                  'Por favor, completa todos los campos requeridos correctamente, selecciona al menos un servicio y verifica tu número de WhatsApp.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
      child: controller.isLoading.value
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: AppColors.textLight),
            )
          : const Text('Enviar Cotización', style: AppTextStyles.button),
    ),
  );

  Widget _buildSavedQuoteSummary(
    BuildContext context,
    Cotizacion cotizacion,
  ) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.receipt_long, size: 60, color: AppColors.blue),
        const SizedBox(height: 20),
        Text(
          '¡Hola, ${cotizacion.nombreCompleto}!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Hemos encontrado una cotización que dejaste en progreso.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyText1,
        ),
        const SizedBox(height: 32),
        Card(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: AppColors.green,
              width: 3,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          shadowColor: AppColors.green,
          child: ListTile(
            title: const Text('Fecha del Evento'),
            subtitle: Text(cotizacion.fechaEvento),
            trailing: Text(
              '\$${cotizacion.totalEstimado}',
              style: AppTextStyles.bodyText1,
            ),
          ),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Ver resumen',
          color: AppColors.green,
          onPress: () {
            Get.toNamed(
              '${AppRoutes.COTIZACION_DETAIL.replaceAll(':id', '')}${cotizacion.id}',
            );
          },
        ),
        const SizedBox(height: 12),
        CustomButton(
          color: AppColors.primary,
          onPress: controller.clearGuestSession,
          text: 'Crear una Nueva Cotización',
        ),
      ],
    ),
  );

  // Widget de ayuda para crear los campos de texto y mantener el código limpio
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => CustomTextFormField(
    controller: controller,
    labelText: label,
    keyboardType: keyboardType,
    hintText: hintText,
    readOnly: readOnly,
    onTap: onTap,
    maxLines: maxLines,
    validator: validator,
  );
}
