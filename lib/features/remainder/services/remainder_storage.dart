import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RemainderStorage {
  static const _key = 'scheduled_remainders';
  static const _idKey = 'remainder_id_counter';
  
  Future<void> save(RemainderPayload payload) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();
    all[payload.id.toString()] = payload.toJson();
    await prefs.setString(_key, jsonEncode(all));
  }

  Future<void> remove(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();
    all.remove(id.toString());
    await prefs.setString(_key, jsonEncode(all));
  }

  Future<Map<String, dynamic>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<int> nextId() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_idKey) ?? 0;
    final next = current + 1;
    await prefs.setInt(_idKey, next);
    return next;
  }
}

// ── Payload model ─────────────────────────────────────────────────────────────

class RemainderPayload {
  final int? id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final AppRepeatInterval? repeat; // null = one-time
  final bool isActive;

  const RemainderPayload({
    this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.repeat,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'scheduledTime': scheduledTime.toIso8601String(),
        'repeat': repeat?.name,
        'isActive': isActive,
      };

  factory RemainderPayload.fromJson(Map<String, dynamic> json) =>
      RemainderPayload(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        scheduledTime: DateTime.parse(json['scheduledTime']),
        repeat: json['repeat'] != null
            ? AppRepeatInterval.values.byName(json['repeat'])
            : null,
        isActive: json['isActive'] ?? true,
      );

  RemainderPayload copyWith({bool? isActive}) => RemainderPayload(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        repeat: repeat,
        isActive: isActive ?? this.isActive,
      );

  // Resolve to a concrete id before saving
  RemainderPayload withId(int resolvedId) => RemainderPayload(
        id: resolvedId,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        repeat: repeat,
        isActive: isActive,
      );
}

enum AppRepeatInterval { daily, weekly, monthly }