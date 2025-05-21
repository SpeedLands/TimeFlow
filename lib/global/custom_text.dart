import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/widgets.dart';
import 'package:timeflow/core/app_settings.dart';

enum CustomTextType { titulo, subtitulo, parrafo }

class CustomText extends StatelessWidget {
  final String text;
  final CustomTextType type;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final String? semanticsLabel;
  final bool softWrap;
  final double minFontSize;

  const CustomText({
    super.key,
    required this.text,
    required this.type,
    this.color,
    this.textAlign,
    this.maxLines,
    this.semanticsLabel,
    this.softWrap = true,
    this.minFontSize = 10,
  });

  double _getBaseFontSize() {
    switch (type) {
      case CustomTextType.titulo:
        return 24;
      case CustomTextType.subtitulo:
        return 18;
      case CustomTextType.parrafo:
        return 14;
    }
  }

  FontWeight _getFontWeight() {
    switch (type) {
      case CustomTextType.titulo:
        return FontWeight.bold;
      case CustomTextType.subtitulo:
        return FontWeight.w600;
      case CustomTextType.parrafo:
        return FontWeight.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppSettings.getFontScale();
    final double fontSize = _getBaseFontSize() * scale;
    final TextStyle textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: _getFontWeight(),
      color: color ?? const Color(0xFF000000),
    );

    return AutoSizeText(
      text,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      softWrap: softWrap,
      style: textStyle,
      minFontSize: minFontSize,
      semanticsLabel: semanticsLabel ?? text,
    );
  }
}
