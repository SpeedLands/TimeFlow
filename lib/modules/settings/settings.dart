import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeflow/core/app_settings.dart';
import 'package:timeflow/global/custom_text.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  ConfiguracionScreenState createState() => ConfiguracionScreenState();
}

class ConfiguracionScreenState extends State<ConfiguracionScreen> {
  String _fontScale = AppSettings.getFontScaleSetting();

  @override
  Widget build(BuildContext context) {
    AppSettings.getFontScale();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            Center(
              child: CustomText(
                text: 'Configuración de Accesibilidad',
                type: CustomTextType.titulo,
              ),
            ),
            const SizedBox(height: 32),

            CustomText(
              text: 'Tamaño del texto',
              type: CustomTextType.subtitulo,
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _fontScale,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _fontScale = value;
                        AppSettings.setFontScale(value);
                      });
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'small',
                      child: CustomText(
                        text: 'Pequeño',
                        type: CustomTextType.parrafo,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'normal',
                      child: CustomText(
                        text: 'Normal',
                        type: CustomTextType.parrafo,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'large',
                      child: CustomText(
                        text: 'Grande',
                        type: CustomTextType.parrafo,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              icon: Icon(Icons.check),
              label: CustomText(
                text: 'Aplicar Cambios',
                type: CustomTextType.parrafo,
              ),
              onPressed: () {
                // Volver aplicando los cambios
                Get.offAndToNamed("/home");
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            TextButton.icon(
              icon: Icon(Icons.arrow_back),
              label: CustomText(text: 'Volver', type: CustomTextType.parrafo),
              onPressed: () {
                Get.offAndToNamed("/home");
              },
            ),
          ],
        ),
      ),
    );
  }
}
