import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_project/features/remainder/services/remainder_service.dart';
import 'package:mini_project/features/remainder/services/remainder_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddRemainderScreen extends StatefulWidget {
  const AddRemainderScreen({super.key});

  @override
  State<AddRemainderScreen> createState() => _AddRemainderScreenState();
}

class _AddRemainderScreenState extends State<AddRemainderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  late final RemainderService _service;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  _ReminderType _reminderType = _ReminderType.oneTime;
  AppRepeatInterval _repeatInterval = AppRepeatInterval.daily;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser!.id;
    _service = RemainderService(RemainderStorage(userId: userId));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  DateTime _selectedDateTime() {
    final date = _selectedDate;
    final time = _selectedTime;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final scheduledTime = _selectedDateTime();
    if (!scheduledTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a future date and time')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = RemainderPayload(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      scheduledTime: scheduledTime,
      repeat: _reminderType == _ReminderType.oneTime ? null : _repeatInterval,
    );

    try {
      if (payload.repeat == null) {
        await _service.scheduleOnce(payload);
      } else {
        await _service.scheduleRecurring(payload);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remainder saved successfully')),
      );
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save remainder: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Remainder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Reminder title',
                  hintText: 'e.g. Take medicine',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Reminder details',
                  hintText: 'Add a short description',
                ),
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Details are required'
                    : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Reminder type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    RadioListTile<_ReminderType>(
                      value: _ReminderType.oneTime,
                      groupValue: _reminderType,
                      title: const Text('One time'),
                      subtitle: const Text('Runs once at the selected time'),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _reminderType = value);
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<_ReminderType>(
                      value: _ReminderType.repeating,
                      groupValue: _reminderType,
                      title: const Text('Repeating'),
                      subtitle: const Text('Runs daily, weekly, or monthly'),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _reminderType = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppRepeatInterval>(
                value: _repeatInterval,
                decoration: const InputDecoration(labelText: 'Repeat interval'),
                items: const [
                  DropdownMenuItem(
                    value: AppRepeatInterval.daily,
                    child: Text('Daily'),
                  ),
                  DropdownMenuItem(
                    value: AppRepeatInterval.weekly,
                    child: Text('Weekly'),
                  ),
                  DropdownMenuItem(
                    value: AppRepeatInterval.monthly,
                    child: Text('Monthly'),
                  ),
                ],
                onChanged: _reminderType == _ReminderType.repeating
                    ? (value) {
                        if (value == null) return;
                        setState(() => _repeatInterval = value);
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Schedule date'),
                  subtitle: Text(_formatDate(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Schedule time'),
                  subtitle: Text(_formatTime(_selectedTime)),
                  trailing: const Icon(Icons.schedule_outlined),
                  onTap: _pickTime,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

enum _ReminderType { oneTime, repeating }
