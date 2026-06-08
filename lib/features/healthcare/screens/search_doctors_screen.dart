import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/models/hospital_model.dart';
import '../../../core/models/speciality_model.dart';
import '../../healthcare/services/healthcare_service.dart';

class SearchDoctorsScreen extends StatefulWidget {
  const SearchDoctorsScreen({super.key});

  @override
  State<SearchDoctorsScreen> createState() => _SearchDoctorsScreenState();
}

class _SearchDoctorsScreenState extends State<SearchDoctorsScreen> {
  // Services data
  List<SpecialityModel> _specialities = [];
  List<HospitalModel> _hospitals = [];
  List<String> _areas = [];

  // Filter states
  final TextEditingController _searchController = TextEditingController();
  int? _selectedSpecialityId;
  String? _selectedArea;
  int? _selectedHospitalId;
  int? _selectedExperience; // e.g., 1, 5, 10
  double? _selectedFee; // e.g., 50.0, 100.0, 200.0

  // Search results state
  List<DoctorModel> _doctors = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _isResultsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final specs = await HealthcareService.getSpecialities();
      final hosps = await HealthcareService.getHospitals();
      final uniqueAreas = await HealthcareService.getUniqueAreas();

      if (mounted) {
        setState(() {
          _specialities = specs;
          _hospitals = hosps;
          _areas = uniqueAreas;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performSearch() async {
    setState(() {
      _isResultsLoading = true;
      _isSearching = true;
    });

    try {
      final results = await HealthcareService.getDoctors(
        searchQuery: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        specialityId: _selectedSpecialityId,
        area: _selectedArea,
        hospitalId: _selectedHospitalId,
        minExperience: _selectedExperience,
        maxFee: _selectedFee,
      );

      if (mounted) {
        setState(() {
          _doctors = results;
          _isResultsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching doctors: $e');
      if (mounted) {
        setState(() {
          _isResultsLoading = false;
        });
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedSpecialityId = null;
      _selectedArea = null;
      _selectedHospitalId = null;
      _selectedExperience = null;
      _selectedFee = null;
      _isSearching = false;
      _doctors = [];
    });
  }

  // Pre-configured styling parameters for Specialists (mockup values)
  Map<String, dynamic> _getSpecialityStyle(String name) {
    switch (name.toLowerCase()) {
      case 'cardiology':
        return {
          'color': const Color(0xFFFDE8E8),
          'iconColor': const Color(0xFFE02424),
          'icon': Icons.favorite_rounded,
          'desc': 'Heart health and diseases',
        };
      case 'pediatrics':
        return {
          'color': const Color(0xFFE1FDF4),
          'iconColor': const Color(0xFF0E9F6E),
          'icon': Icons.child_care_rounded,
          'desc': 'Children and adolescent care',
        };
      case 'neurology':
        return {
          'color': const Color(0xFFEDEBFE),
          'iconColor': const Color(0xFF6B7280),
          'icon': Icons.psychology_rounded,
          'desc': 'Brain and nerve specialists',
        };
      case 'orthopedics':
        return {
          'color': const Color(0xFFEBF5FF),
          'iconColor': const Color(0xFF1C64F2),
          'icon': Icons.accessibility_new_rounded,
          'desc': 'Bone and joint care',
        };
      case 'dermatology':
        return {
          'color': const Color(0xFFE5E7EB),
          'iconColor': const Color(0xFF374151),
          'icon': Icons.clean_hands_rounded,
          'desc': 'Skin and hair treatments',
        };
      case 'dentistry':
        return {
          'color': const Color(0xFFFDF2F8),
          'iconColor': const Color(0xFFD61F69),
          'icon': Icons.face_retouching_natural_rounded,
          'desc': 'Oral health and hygiene',
        };
      case 'ophthalmology':
        return {
          'color': const Color(0xFFE1FDF4),
          'iconColor': const Color(0xFF057A55),
          'icon': Icons.visibility_rounded,
          'desc': 'Eye and vision specialists',
        };
      case 'psychology':
        return {
          'color': const Color(0xFFF5F3FF),
          'iconColor': const Color(0xFF7E3AF2),
          'icon': Icons.chat_bubble_rounded,
          'desc': 'Mental health and counseling',
        };
      default:
        return {
          'color': const Color(0xFFF3F4F6),
          'iconColor': const Color(0xFF4B5563),
          'icon': Icons.medical_services_rounded,
          'desc': 'General medical care',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          'Search Doctors',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Your Doctor',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filters card panel
                  _buildFilterCard(),
                  const SizedBox(height: 24),

                  // Results panel or Browse by Specialist panel
                  _isSearching
                      ? _buildSearchResultsSection()
                      : _buildBrowseBySpecialistSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF), // Soft lavender blue background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or condition...',
              fillColor: Colors.white,
              filled: true,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Search Now Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A4FB3), // Rich primary blue
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _performSearch,
              child: const Text(
                'Search Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Specialist Dropdown
          const Text(
            'Specialist',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          _buildDropdownContainer(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedSpecialityId,
                hint: const Text(
                  'All Specialists',
                  style: TextStyle(fontSize: 14),
                ),
                isExpanded: true,
                onChanged: (val) {
                  setState(() {
                    _selectedSpecialityId = val;
                  });
                },
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text(
                      'All Specialists',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  ..._specialities.map(
                    (s) => DropdownMenuItem<int>(
                      value: s.id,
                      child: Text(s.name, style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Area Dropdown
          const Text(
            'Area',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          _buildDropdownContainer(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedArea,
                hint: const Text('All Areas', style: TextStyle(fontSize: 14)),
                isExpanded: true,
                onChanged: (val) {
                  setState(() {
                    _selectedArea = val;
                  });
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Areas', style: TextStyle(fontSize: 14)),
                  ),
                  ..._areas.map(
                    (a) => DropdownMenuItem<String>(
                      value: a,
                      child: Text(a, style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Hospital Dropdown
          const Text(
            'Hospital',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          _buildDropdownContainer(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedHospitalId,
                hint: const Text(
                  'All Hospitals',
                  style: TextStyle(fontSize: 14),
                ),
                isExpanded: true,
                onChanged: (val) {
                  setState(() {
                    _selectedHospitalId = val;
                  });
                },
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text(
                      'All Hospitals',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  ..._hospitals.map(
                    (h) => DropdownMenuItem<int>(
                      value: h.id,
                      child: Text(h.name, style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // More Filters
          const Text(
            'More Filters',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildDropdownContainer(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedExperience,
                      hint: const Text(
                        'Experience',
                        style: TextStyle(fontSize: 14),
                      ),
                      isExpanded: true,
                      onChanged: (val) {
                        setState(() {
                          _selectedExperience = val;
                        });
                      },
                      items: const [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text(
                            'Any Experience',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 1,
                          child: Text(
                            '1+ Years',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 5,
                          child: Text(
                            '5+ Years',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 10,
                          child: Text(
                            '10+ Years',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownContainer(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: _selectedFee,
                      hint: const Text('Fee', style: TextStyle(fontSize: 14)),
                      isExpanded: true,
                      onChanged: (val) {
                        setState(() {
                          _selectedFee = val;
                        });
                      },
                      items: const [
                        DropdownMenuItem<double>(
                          value: null,
                          child: Text(
                            'Any Fee',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem<double>(
                          value: 50.0,
                          child: Text(
                            '< Tk.50',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem<double>(
                          value: 100.0,
                          child: Text(
                            '< Tk.100',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem<double>(
                          value: 200.0,
                          child: Text(
                            '< Tk.200',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }

  Widget _buildBrowseBySpecialistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Browse by Specialist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/doctors');
              },
              child: const Row(
                children: [
                  Text('View All'),
                  Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemCount: _specialities.length,
          itemBuilder: (context, index) {
            final speciality = _specialities[index];
            final style = _getSpecialityStyle(speciality.name);

            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _selectedSpecialityId = speciality.id;
                  });
                  _performSearch();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: style['color'],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          style['icon'],
                          color: style['iconColor'],
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        speciality.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        style['desc'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Search Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: _clearFilters,
              child: const Row(
                children: [
                  Icon(Icons.clear, size: 16),
                  SizedBox(width: 4),
                  Text('Clear Filters'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _isResultsLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(),
                ),
              )
            : _doctors.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No doctors found matching your criteria.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _doctors.length,
                itemBuilder: (context, index) {
                  final doctor = _doctors[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppTheme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
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
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${doctor.qualification ?? "MBBS"} - ${doctor.designation ?? "Consultant"}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${doctor.experienceYears ?? 0} yrs exp',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.payments_outlined,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '\$${doctor.consultationFee?.toStringAsFixed(0) ?? "0"}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              // Navigate to doctor details if available, or show snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Details for ${doctor.fullName} coming soon!',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
