import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/servicio_model.dart';
import '../../global/custom_button.dart';
import '../../global/widgets/custom_dropdown_form_field.dart';
import '../../global/widgets/custom_scaffold.dart';
import '../../global/widgets/custom_text_form_field.dart';
import 'servicio_controller.dart';

class ServicioFormScreen extends StatefulWidget {
  const ServicioFormScreen({super.key});

  @override
  State<ServicioFormScreen> createState() => _ServicioFormScreenState();
}

class _ServicioFormScreenState extends State<ServicioFormScreen> {
  final ServicioController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  // Controllers para los campos del formulario
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _minPersonasController;
  String? _tipoCobroSeleccionado;

  // El servicio que estamos editando (puede ser nulo si estamos creando)
  Servicio? _editingServicio;

  @override
  void initState() {
    super.initState();
    _editingServicio = Get.arguments as Servicio?;

    // Inicializamos los controllers con los datos existentes si estamos editando
    _nombreController = TextEditingController(
      text: _editingServicio?.nombre ?? '',
    );
    _precioController = TextEditingController(
      text: _editingServicio?.precioBase ?? '',
    );
    _minPersonasController = TextEditingController(
      text: _editingServicio?.minPersonas.toString() ?? '0',
    );
    _tipoCobroSeleccionado = _editingServicio?.tipoCobro ?? 'fijo';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _minPersonasController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nombre': _nombreController.text,
        'precio_base': _precioController.text,
        'tipo_cobro': _tipoCobroSeleccionado,
        'min_personas': int.tryParse(_minPersonasController.text) ?? 0,
      };
      controller.saveServicio(data, id: _editingServicio?.id);
    }
  }

  @override
  Widget build(BuildContext context) => CustomScaffold(
      title: _editingServicio == null ? 'Crear Servicio' : 'Editar Servicio',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                controller: _nombreController,
                labelText: 'Nombre del Servicio',
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _precioController,
                labelText: 'Precio Base',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 16),
              CustomDropdownFormField(
                value: _tipoCobroSeleccionado,
                labelText: 'Tipo de Cobro',
                items: ['fijo', 'por_persona', 'por_litro'].map((tipo) => DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.replaceAll('_', ' ').capitalizeFirst!),
                  )).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoCobroSeleccionado = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecciona un tipo' : null,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _minPersonasController,
                labelText: 'Mínimo de Personas',
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Este campo es requerido' : null,
              ),
              const SizedBox(height: 32),
              CustomButton(onPress: _submitForm, text: 'Guardar'),
            ],
          ),
        ),
      ),
    );
}
