import 'package:flutter/material.dart';

class AuthVisualPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AuthVisualPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 130,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: textTheme.headlineLarge?.copyWith(
                color: colorScheme.primary,
                fontSize: 42,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
