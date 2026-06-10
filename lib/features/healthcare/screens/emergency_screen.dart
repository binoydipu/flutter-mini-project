import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'In case of an emergency, please call the nearest hospital or emergency services immediately.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Handle emergency call
              },
              icon: const Icon(Icons.phone),
              label: const Text('Call Emergency Services'),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                context.push('/nearest-hospitals');
              },
              icon: const Icon(Icons.near_me_outlined),
              label: const Text('Nearest Hospitals'),
            ),
          ],
        ),
      ),
    );
  }
}
