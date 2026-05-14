import 'package:flutter/material.dart';

import '../services/measurement_service.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final measurement = MeasurementService();
    const baseline = 100.0;
    const current = 92.0;
    final status = measurement.classifyChange(
      baselineArea: baseline,
      currentArea: current,
    );
    final percent = measurement.percentChange(
      baselineArea: baseline,
      currentArea: current,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Comparison')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: Center(
                child: Text('Before / After comparison slider placeholder'),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Status: $status'),
                    const SizedBox(height: 8),
                    Text('Perubahan area: ${percent.toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
