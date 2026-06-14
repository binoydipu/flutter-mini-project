import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_project/features/remainder/services/remainder_service.dart';
import 'package:mini_project/features/remainder/services/remainder_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemainderScreen extends StatefulWidget {
  const RemainderScreen({super.key});

  @override
  State<RemainderScreen> createState() => _RemainderScreenState();
}

class _RemainderScreenState extends State<RemainderScreen> {
  late final RemainderService _service;
  late Future<List<RemainderPayload>> _scheduledFuture;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser!.id;
    _service = RemainderService(RemainderStorage(userId: userId));
    _scheduledFuture = _service.getAllScheduled();
  }

  Future<void> _refreshScheduled() async {
    setState(() {
      _scheduledFuture = _service.getAllScheduled();
    });
  }

  Future<void> _deleteRemainder(BuildContext context, int id) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Remainder'),
            content: const Text(
              'Are you sure you want to delete this remainder?',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => context.pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await _service.cancel(id);
      _refreshScheduled();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Remainder deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remainders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/add-remainder').then((_) => _refreshScheduled());
            },
          ),
        ],
      ),
      body: FutureBuilder<List<RemainderPayload>>(
        future: _scheduledFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load scheduled remainders.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final scheduled = List<RemainderPayload>.from(snapshot.data ?? [])
            ..sort(
              (left, right) =>
                  left.scheduledTime.compareTo(right.scheduledTime),
            );

          if (scheduled.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshScheduled,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'No scheduled reminders yet. Tap + to add one.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshScheduled,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: scheduled.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = scheduled[index];
                final isExpired =
                    item.repeat == null &&
                    DateTime.now().isAfter(item.scheduledTime);
                    
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.redAccent,
                              ),
                              onPressed: () =>
                                  _deleteRemainder(context, item.id!),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 4),
                            Text(item.body),
                            const SizedBox(height: 8),
                            Text(_formatScheduledTime(item.scheduledTime)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoChip(
                                  label: isExpired ? 'Expired' : 'Active',
                                ),
                                _InfoChip(
                                  label: item.repeat == null
                                      ? 'One-time'
                                      : 'Repeats',
                                ),
                                if (item.repeat != null)
                                  _InfoChip(label: item.repeat!.name),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatScheduledTime(DateTime scheduledTime) {
    final local = scheduledTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return 'Scheduled for $day/$month/${local.year} at $hour:$minute';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), visualDensity: VisualDensity.compact);
  }
}
