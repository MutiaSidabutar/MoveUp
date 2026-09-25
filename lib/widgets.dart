
import 'dart:math' as math;

import 'package:flutter/material.dart';

// Button Components
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const PrimaryButton({super.key, required this.text, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SecondaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// Cards
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String primaryValue;
  final String secondaryValue;
  final IconData icon;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryValue,
    required this.secondaryValue,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(primaryValue, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(secondaryValue, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// Empty State
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({super.key, required this.message, this.icon = Icons.inbox});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}

// Bar Chart
class SimpleBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final int? highlightIndex;
  final double height;

  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.highlightIndex,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final maxValue = values.fold<double>(0, (m, v) => v > m ? v : m);

    return SizedBox(
      height: height + 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: values.length > 10 ? 1 : 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      // Batang kosong tetap terlihat tipis supaya sumbu terbaca
                      height: maxValue == 0 ? 3 : (values[i] / maxValue * height).clamp(3, height),
                      decoration: BoxDecoration(
                        color: values[i] == 0
                            ? Theme.of(context).dividerColor.withValues(alpha: 0.2)
                            : (highlightIndex == null || highlightIndex == i ? primary : primary.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 16,
                      child: Text(labels[i], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Efek butiran film seperti foto hitam-putih; ditaruh di atas latar dengan Stack
class FilmGrain extends StatelessWidget {
  final double opacity;

  const FilmGrain({super.key, this.opacity = 0.06});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(size: Size.infinite, painter: _GrainPainter(opacity)),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter(this.opacity);

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    // Seed tetap supaya pola butiran tidak berkedip setiap kali digambar ulang
    final random = math.Random(7);
    final light = Paint()..color = Colors.white.withValues(alpha: opacity);
    final dark = Paint()..color = Colors.black.withValues(alpha: opacity);
    final count = (size.width * size.height / 30).round();
    for (var i = 0; i < count; i++) {
      final rect = Rect.fromLTWH(random.nextDouble() * size.width, random.nextDouble() * size.height, 1.2, 1.2);
      canvas.drawRect(rect, i.isEven ? light : dark);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter old) => old.opacity != opacity;
}
