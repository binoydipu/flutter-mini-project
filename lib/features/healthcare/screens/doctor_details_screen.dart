// ============================================================
// doctor_details_screen.dart
// ============================================================
// Detailed profile view for a single doctor.
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_project/main.dart' show supabase;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/doctor_model.dart';
import '../../profile/services/profile_service.dart';
import '../../admin/services/admin_service.dart';
import '../../healthcare/services/healthcare_service.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  bool _isAdmin = false;
  List<Map<String, dynamic>> _specialities = [];
  List<Map<String, dynamic>> _hospitals = [];
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _fetchDoctorDetails();
  }

  Future<void> _checkAdmin() async {
    final isAdmin = await ProfileService.isAdmin();
    if (mounted) setState(() => _isAdmin = isAdmin);
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      final response = await supabase
          .from('doctors')
          .select('''
            doctor_specialities(specialities(id, name, icon)),
            doctor_hospitals(
              hospital_id,
              chamber_name,
              room_no,
              appointment_phone,
              hospitals(name, area, city, address, phone)
            )
          ''')
          .eq('id', widget.doctor.id)
          .single();

      if (mounted) {
        final specs = (response['doctor_specialities'] as List?) ?? [];
        final hosps = (response['doctor_hospitals'] as List?) ?? [];

        setState(() {
          _specialities = specs
              .where((s) => s['specialities'] != null)
              .map<Map<String, dynamic>>(
                (s) => s['specialities'] as Map<String, dynamic>,
              )
              .toList();
          _hospitals = hosps
              .where((h) => h['hospitals'] != null)
              .map<Map<String, dynamic>>((h) {
                final hosp = h['hospitals'] as Map<String, dynamic>;
                return {
                  ...hosp,
                  'chamber_name': h['chamber_name'],
                  'room_no': h['room_no'],
                  'appointment_phone': h['appointment_phone'],
                };
              })
              .toList();
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching doctor details: $e');
      if (mounted) setState(() => _isLoadingDetails = false);
    }
  }

  Future<void> _editDoctor() async {
    final updated = await context.push<bool>(
      '/admin/edit-doctor',
      extra: widget.doctor,
    );
    if (updated == true && mounted) {
      // Refresh after edit
      _fetchDoctorDetails();
    }
  }

  Future<void> _addSpeciality() async {
    final specialities = await HealthcareService.getSpecialities();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        int? selectedSpecId;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: const Text('Add Speciality'),
            content: specialities.isEmpty
                ? const Text('No specialities available.')
                : DropdownButtonFormField<int>(
                    hint: const Text('Choose Speciality'),
                    items: specialities
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedSpecId = val),
                  ),
            actions: [
              TextButton(
                onPressed: () => ctx.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: selectedSpecId == null
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await AdminService.addDoctorSpeciality(
                          doctorId: widget.doctor.id,
                          specialityId: selectedSpecId!,
                        );
                        if (ctx.mounted) {
                          ctx.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Speciality added!'
                                    : 'Failed to add speciality',
                              ),
                            ),
                          );
                          if (ok) _fetchDoctorDetails();
                        }
                      },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: CustomScrollView(
        slivers: [
          // ─── Hero Header ───────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              if (_isAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (v) {
                    if (v == 'edit') _editDoctor();
                    if (v == 'speciality') _addSpeciality();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text('Edit Doctor'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'speciality',
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text('Add Speciality'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      // Avatar
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        backgroundImage:
                            doctor.profileImage != null &&
                                doctor.profileImage!.isNotEmpty
                            ? NetworkImage(doctor.profileImage!)
                            : null,
                        child:
                            doctor.profileImage == null ||
                                doctor.profileImage!.isEmpty
                            ? Text(
                                doctor.fullName.isNotEmpty
                                    ? doctor.fullName[0].toUpperCase()
                                    : 'D',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Dr. ${doctor.fullName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (doctor.designation != null &&
                          doctor.designation!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            doctor.designation!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      if (doctor.qualification != null &&
                          doctor.qualification!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            doctor.qualification!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Body Content ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats row
                  _buildStatsRow(doctor),
                  const SizedBox(height: 20),

                  // Bio
                  if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
                    _sectionTitle('About'),
                    const SizedBox(height: 8),
                    _buildCard(
                      child: Text(
                        doctor.bio!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Specialities
                  _sectionTitle('Specialities'),
                  const SizedBox(height: 8),
                  _isLoadingDetails
                      ? const Center(child: CircularProgressIndicator())
                      : _specialities.isEmpty
                      ? _buildCard(
                          child: const Text(
                            'No specialities assigned.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : _buildCard(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _specialities
                                .map(
                                  (s) => Chip(
                                    label: Text(s['name'] ?? ''),
                                    backgroundColor: AppTheme.primaryColor
                                        .withValues(alpha: 0.08),
                                    labelStyle: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    avatar: const Icon(
                                      Icons.local_hospital_rounded,
                                      size: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                    side: BorderSide.none,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                  const SizedBox(height: 20),

                  // Hospitals / Chambers
                  _sectionTitle('Available At'),
                  const SizedBox(height: 8),
                  _isLoadingDetails
                      ? const Center(child: CircularProgressIndicator())
                      : _hospitals.isEmpty
                      ? _buildCard(
                          child: const Text(
                            'No hospital information available.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : Column(
                          children: _hospitals
                              .map((h) => _buildHospitalTile(h))
                              .toList(),
                        ),
                  const SizedBox(height: 20),

                  // Contact Information
                  _sectionTitle('Contact Information'),
                  const SizedBox(height: 8),
                  _buildCard(
                    child: Column(
                      children: [
                        if (doctor.phone != null && doctor.phone!.isNotEmpty)
                          _infoRow(
                            Icons.phone_rounded,
                            'Phone',
                            doctor.phone!,
                            onTap: () async {
                              final Uri phoneUri = Uri(
                                scheme: 'tel',
                                path: doctor.phone!,
                              );
                              await launchUrl(phoneUri);
                            },
                          ),
                        if (doctor.email != null && doctor.email!.isNotEmpty)
                          _infoRow(Icons.email_rounded, 'Email', doctor.email!),
                        if ((doctor.phone == null || doctor.phone!.isEmpty) &&
                            (doctor.email == null || doctor.email!.isEmpty))
                          const Text(
                            'No contact info available.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Book Appointment Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text('Book Appointment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────

  Widget _buildStatsRow(DoctorModel doctor) {
    return Row(
      children: [
        if (doctor.experienceYears != null)
          Expanded(
            child: _statCard(
              icon: Icons.workspace_premium_rounded,
              color: const Color(0xFF7C3AED),
              label: 'Experience',
              value: '${doctor.experienceYears} yrs',
            ),
          ),
        if (doctor.experienceYears != null && doctor.consultationFee != null)
          const SizedBox(width: 12),
        if (doctor.consultationFee != null)
          Expanded(
            child: _statCard(
              icon: Icons.payments_rounded,
              color: const Color(0xFF059669),
              label: 'Consult Fee',
              value: '\$${doctor.consultationFee!.toStringAsFixed(0)}',
            ),
          ),
        if (doctor.gender != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              icon: Icons.person_rounded,
              color: const Color(0xFFEC4899),
              label: 'Gender',
              value: doctor.gender!,
            ),
          ),
        ],
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: child,
    );
  }

  Widget _buildHospitalTile(Map<String, dynamic> h) {
    final name = h['name'] as String? ?? 'Unknown Hospital';
    final area = h['area'] as String?;
    final city = h['city'] as String?;
    final chamberName = h['chamber_name'] as String?;
    final roomNo = h['room_no'] as String?;
    final appointmentPhone = h['appointment_phone'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: AppTheme.secondaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (area != null || city != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      [
                        area,
                        city,
                      ].where((e) => e != null && e.isNotEmpty).join(', '),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                if (chamberName != null && chamberName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Chamber: $chamberName',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                if (roomNo != null && roomNo.isNotEmpty)
                  Text(
                    'Room: $roomNo',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                if (appointmentPhone != null && appointmentPhone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 13,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appointmentPhone,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
