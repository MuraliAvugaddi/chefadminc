import 'dart:html' as html;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../apis/apis_localhost.dart';
import '../models/user_models.dart';
import '../controllers/updateing_user_status_controller.dart';

/// Chef Hospitality - Student Financial & Access Center
///
/// UX/UI refresh:
/// - Clean Chef blue primary palette instead of yellow/black.
/// - Responsive layout for Flutter Web/Desktop and narrow screens.
/// - Compact KPI cards.
/// - Search/filter controls grouped into one surface.
/// - Student cards use clear hierarchy and status chips.
/// - Payment dialog has clearer sections and stronger CTA.
/// - Uses the same visual language on web and mobile.
///
/// Backend/API logic is intentionally kept compatible with the original screen.

class ChefColors {
  static const primary = Color(0xFFFFC800);
  static const primaryDark = Color(0xFF9A7600);
  static const primarySoft = Color(0xFFFFF6CC);

  static const background = Color(0xFFF6F8FC);
  static const surface = Colors.white;
  static const border = Color(0xFFE5EAF2);

  static const text = Color(0xFF172033);
  static const muted = Color(0xFF667085);

  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFEAF8EF);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFFEEEE);
  static const warning = Color(0xFFF59E0B);
  static const warningSoft = Color(0xFFFFF7E6);
}

class StudentFinancialScreen extends StatefulWidget {
  const StudentFinancialScreen({super.key});

  @override
  State<StudentFinancialScreen> createState() => _StudentFinancialScreenState();
}

class _StudentFinancialScreenState extends State<StudentFinancialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final AdminController adminController = Get.put(AdminController());

  String selectedGender = 'All';
  String selectedMonth = 'September 2026';
  bool showUnpaidOnly = false;

  final List<String> monthsList = ['All Year', 'August 2026', 'September 2026'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    adminController.fetchUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TextStyle get _bodyText => GoogleFonts.poppins(color: ChefColors.text);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: ChefColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ChefColors.primary,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ChefColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ChefColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ChefColors.primary, width: 1.4),
          ),
          labelStyle: const TextStyle(color: ChefColors.muted),
          hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
        ),
      ),
      child: Scaffold(
        backgroundColor: ChefColors.background,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 850;

              return Column(
                children: [
                  _buildMetricsSummaryBar(isCompact),
                  _buildFilterToolbar(isCompact),
                  _buildTabs(isCompact),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildStudentListView(
                          isJunior: true,
                          isCompact: isCompact,
                        ),
                        _buildStudentListView(
                          isJunior: false,
                          isCompact: isCompact,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ChefColors.primary,
      surfaceTintColor: ChefColors.primary,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (Get.isDialogOpen == true) {
              Get.back();
              return;
            }

            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else if (Get.key.currentState?.canPop() == true) {
              Get.back();
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A1A),
            size: 19,
          ),
        ),
      ),
      toolbarHeight: 62,
      titleSpacing: 4,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ChefColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: ChefColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chef Hospitality',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1A1A1A),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Student finance & access',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF5F4B00),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildExcelExportButton(),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: ChefColors.border),
      ),
    );
  }

  Widget _buildTabs(bool isCompact) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isCompact ? 12 : 20,
        3,
        isCompact ? 12 : 20,
        5,
      ),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 38,
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: ChefColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          labelColor: const Color(0xFF1A1A1A),
          unselectedLabelColor: ChefColors.muted,
          labelStyle: GoogleFonts.poppins(
            fontSize: isCompact ? 11 : 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: isCompact ? 11 : 12,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Juniors · 1st Year'),
            Tab(text: 'Seniors · 2nd–5th Year'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSummaryBar(bool isCompact) {
    return Obx(() {
      final allUsers = adminController.filteredUsers;
      final totalCount = allUsers.length;
      final activeCount = allUsers.where((u) => u.isApproved.value).length;
      final noAccessCount = totalCount - activeCount;

      return Padding(
        padding: EdgeInsets.fromLTRB(
          isCompact ? 12 : 20,
          8,
          isCompact ? 12 : 20,
          2,
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total Students',
                count: totalCount.toString(),
                icon: Icons.people_alt_outlined,
                iconBackground: ChefColors.primarySoft,
                iconColor: ChefColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Active Access',
                count: activeCount.toString(),
                icon: Icons.verified_outlined,
                iconBackground: ChefColors.successSoft,
                iconColor: ChefColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Needs Attention',
                count: noAccessCount.toString(),
                icon: Icons.warning_amber_rounded,
                iconBackground: ChefColors.warningSoft,
                iconColor: ChefColors.warning,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ChefColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: ChefColors.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: GoogleFonts.poppins(
                    color: ChefColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar(bool isCompact) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isCompact ? 12 : 20,
        6,
        isCompact ? 12 : 20,
        2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: ChefColors.border),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: adminController.updateSearchQuery,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: ChefColors.text,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Search name, phone or student ID',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: ChefColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        value: selectedGender,
                        icon: Icons.people_outline_rounded,
                        items: const ['All', 'Male', 'Female'],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedGender = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterDropdown(
                        value: selectedMonth,
                        icon: Icons.calendar_month_outlined,
                        items: monthsList,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedMonth = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildUnpaidFilter(),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: adminController.updateSearchQuery,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: ChefColors.text,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search name, phone or student ID',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: ChefColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: _buildFilterDropdown(
                    value: selectedGender,
                    icon: Icons.people_outline_rounded,
                    items: const ['All', 'Male', 'Female'],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedGender = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 165,
                  child: _buildFilterDropdown(
                    value: selectedMonth,
                    icon: Icons.calendar_month_outlined,
                    items: monthsList,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedMonth = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                _buildUnpaidFilter(),
              ],
            ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      height: 44,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: ChefColors.muted,
          size: 20,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFFAFBFD),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
          prefixIcon: Icon(icon, size: 17, color: ChefColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ChefColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ChefColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ChefColors.primary, width: 1.3),
          ),
        ),
        style: GoogleFonts.poppins(
          color: ChefColors.text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildUnpaidFilter() {
    return FilterChip(
      selected: showUnpaidOnly,
      showCheckmark: false,
      avatar: Icon(
        showUnpaidOnly
            ? Icons.check_circle_rounded
            : Icons.error_outline_rounded,
        size: 17,
        color: showUnpaidOnly ? const Color(0xFF8A6800) : ChefColors.muted,
      ),
      label: const Text('Unpaid only'),
      selectedColor: ChefColors.primarySoft,
      backgroundColor: const Color(0xFFFAFBFD),
      side: BorderSide(
        color: showUnpaidOnly ? ChefColors.primary : ChefColors.border,
      ),
      labelStyle: GoogleFonts.poppins(
        color: showUnpaidOnly ? const Color(0xFF6B5200) : ChefColors.text,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (value) {
        setState(() => showUnpaidOnly = value);
      },
    );
  }

  Widget _buildStudentListView({
    required bool isJunior,
    required bool isCompact,
  }) {
    return Obx(() {
      if (adminController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: ChefColors.primary,
            strokeWidth: 2.5,
          ),
        );
      }

      final filtered = adminController.filteredUsers.where((u) {
        final matchesYear = isJunior
            ? (u.year == '1' || u.year.toLowerCase().contains('1'))
            : (u.year != '1' && !u.year.toLowerCase().contains('1'));

        final matchesUnpaid = !showUnpaidOnly || !u.isApproved.value;

        final matchesGender =
            selectedGender == 'All' ||
            u.gender.trim().toLowerCase() ==
                selectedGender.trim().toLowerCase();

        return matchesYear && matchesUnpaid && matchesGender;
      }).toList();

      if (filtered.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.separated(
        padding: EdgeInsets.fromLTRB(
          isCompact ? 12 : 20,
          4,
          isCompact ? 12 : 20,
          20,
        ),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _buildStudentCard(filtered[index], isCompact: isCompact);
        },
      );
    });
  }

  Widget _buildStudentCard(AppUser student, {required bool isCompact}) {
    final isActive = student.isApproved.value;
    final initial = student.name.trim().isNotEmpty
        ? student.name.trim()[0].toUpperCase()
        : '?';

    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ChefColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: isCompact
          ? _buildCompactStudentContent(student, initial, isActive)
          : _buildDesktopStudentContent(student, initial, isActive),
    );
  }

  Widget _buildDesktopStudentContent(
    AppUser student,
    String initial,
    bool isActive,
  ) {
    return Row(
      children: [
        _buildAvatar(initial, isActive),
        const SizedBox(width: 13),
        Expanded(child: _buildStudentDetails(student, isActive)),
        const SizedBox(width: 16),
        _buildStudentActions(student, isActive),
      ],
    );
  }

  Widget _buildCompactStudentContent(
    AppUser student,
    String initial,
    bool isActive,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(initial, isActive),
            const SizedBox(width: 11),
            Expanded(child: _buildStudentDetails(student, isActive)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showManualPaymentDialog(student),
                icon: const Icon(Icons.payments_outlined, size: 17),
                label: const Text('Record payment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A1A1A),
                  side: const BorderSide(color: ChefColors.primary),
                  minimumSize: const Size(0, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => adminController.toggleApproval(student),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive
                      ? ChefColors.dangerSoft
                      : ChefColors.primary,
                  foregroundColor: isActive ? ChefColors.danger : Colors.white,
                  elevation: 0,
                  minimumSize: const Size(0, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isActive ? 'Revoke access' : 'Grant access',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(String initial, bool isActive) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isActive ? ChefColors.primarySoft : const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.poppins(
          color: isActive ? ChefColors.primaryDark : ChefColors.muted,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildStudentDetails(AppUser student, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                student.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: ChefColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 7),
            _buildStatusChip(isActive),
          ],
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          children: [
            _infoItem(Icons.badge_outlined, student.enrollmentNo),
            _infoItem(Icons.menu_book_outlined, student.course),
            _infoItem(Icons.meeting_room_outlined, 'Room ${student.room}'),
            _infoItem(Icons.person_outline, student.gender),
          ],
        ),
      ],
    );
  }

  Widget _infoItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: ChefColors.muted),
        const SizedBox(width: 4),
        Text(
          value.isEmpty ? '—' : value,
          style: GoogleFonts.poppins(
            color: ChefColors.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? ChefColors.successSoft : ChefColors.dangerSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 12,
            color: isActive ? ChefColors.success : ChefColors.danger,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'ACTIVE' : 'UNPAID',
            style: GoogleFonts.poppins(
              color: isActive ? ChefColors.success : ChefColors.danger,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentActions(AppUser student, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: () => _showManualPaymentDialog(student),
          icon: const Icon(Icons.payments_outlined, size: 17),
          label: const Text('Record payment'),
          style: OutlinedButton.styleFrom(
            foregroundColor: ChefColors.primaryDark,
            side: const BorderSide(color: ChefColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => adminController.toggleApproval(student),
          style: TextButton.styleFrom(
            foregroundColor: isActive ? ChefColors.danger : ChefColors.success,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            textStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(isActive ? 'Revoke access' : 'Grant access'),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ChefColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: ChefColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: ChefColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No students found',
                style: GoogleFonts.poppins(
                  color: ChefColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Try changing the search or filters.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: ChefColors.muted,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showManualPaymentDialog(AppUser student) async {
    final utrController = TextEditingController();
    final amountController = TextEditingController(text: '4000');
    final dateController = TextEditingController(text: '2026-09-23');

    final List<String> allSystemMonths = ['August 2026', 'September 2026'];
    List<String> paidMonths = [];

    try {
      final res = await http.get(
        Uri.parse('${ApiEndpoints.adminAllPayments}?userId=${student.id}'),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List payments = data['payments'] ?? [];
        paidMonths = payments.map((p) => p['month'].toString()).toList();
      }
    } catch (_) {}

    if (!mounted) return;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: ChefColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: ChefColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Record payment',
                            style: GoogleFonts.poppins(
                              color: ChefColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            student.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: ChefColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle('Payment history', Icons.history_rounded),
                const SizedBox(height: 9),
                ...allSystemMonths.map((month) {
                  final isPaid = paidMonths.contains(month);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? ChefColors.successSoft
                          : ChefColors.dangerSoft,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: isPaid
                            ? const Color(0xFFBDE8C9)
                            : const Color(0xFFF4C5C3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPaid
                              ? Icons.check_circle_rounded
                              : Icons.pending_outlined,
                          size: 18,
                          color: isPaid
                              ? ChefColors.success
                              : ChefColors.danger,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            month,
                            style: GoogleFonts.poppins(
                              color: ChefColors.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          isPaid ? 'PAID' : 'PENDING',
                          style: GoogleFonts.poppins(
                            color: isPaid
                                ? ChefColors.success
                                : ChefColors.danger,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                _sectionTitle('Payment details', Icons.payments_outlined),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    prefixIcon: Icon(Icons.currency_rupee_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: utrController,
                  decoration: const InputDecoration(
                    labelText: 'UTR / Cash receipt ID *',
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Payment date (YYYY-MM-DD)',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (utrController.text.trim().isEmpty) {
                        Get.snackbar(
                          'Payment details missing',
                          'Enter a UTR number or cash receipt ID.',
                          backgroundColor: ChefColors.danger,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(12),
                        );
                        return;
                      }

                      try {
                        final res = await http.post(
                          Uri.parse(ApiEndpoints.adminManualPayment),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'userId': student.id,
                            'amount': num.tryParse(amountController.text) ?? 0,
                            'month': selectedMonth,
                            'transactionId': utrController.text.trim(),
                            'paymentDate': dateController.text.trim(),
                          }),
                        );

                        if (res.statusCode == 200) {
                          Get.back();
                          adminController.fetchUsers();

                          Get.snackbar(
                            'Payment recorded',
                            'Payment saved and app access granted.',
                            backgroundColor: ChefColors.success,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(12),
                          );
                        } else {
                          Get.snackbar(
                            'Unable to save',
                            'The payment could not be recorded.',
                            backgroundColor: ChefColors.danger,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(12),
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          'Connection error',
                          'Please check the server connection and try again.',
                          backgroundColor: ChefColors.danger,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(12),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      'Save payment & approve access',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ChefColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 17, color: ChefColors.primary),
        const SizedBox(width: 7),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: ChefColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildExcelExportButton() {
    return OutlinedButton.icon(
      onPressed: () async {
        try {
          final group = _tabController.index == 0 ? 'Junior' : 'Senior';

          final urlString =
              '${ApiEndpoints.adminExportExcel}'
              '?yearGroup=$group'
              '&gender=$selectedGender'
              '&month=$selectedMonth';

          Get.snackbar(
            'Preparing report',
            'Generating Excel sheet...',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12),
          );

          final response = await http.get(Uri.parse(urlString));

          if (response.statusCode == 200) {
            final blob = html.Blob(
              [response.bodyBytes],
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            );

            final url = html.Url.createObjectUrlFromBlob(blob);

            // Create a clear, human-friendly report name.
            // Example:
            // Chef Hospitality Junior Boys September 2026.xlsx
            // Chef Hospitality Senior Girls September 2026.xlsx
            // Chef Hospitality Junior All Students September 2026.xlsx
            final yearName = group == 'Junior' ? 'Junior' : 'Senior';

            final genderName = selectedGender == 'All'
                ? 'All Students'
                : selectedGender == 'Male'
                ? 'Boys'
                : 'Girls';

            final safeMonth = selectedMonth
                .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ')
                .trim();

            final fileName =
                'Chef Hospitality $yearName $genderName $safeMonth.xlsx';

            html.AnchorElement(href: url)
              ..setAttribute('download', fileName)
              ..click();

            html.Url.revokeObjectUrl(url);

            Get.snackbar(
              'Report downloaded',
              'Excel report is ready.',
              backgroundColor: ChefColors.success,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(12),
            );
          } else {
            Get.snackbar(
              'Download failed',
              'Unable to generate the Excel report.',
              backgroundColor: ChefColors.danger,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(12),
            );
          }
        } catch (e) {
          Get.snackbar(
            'Download error',
            'Please try again.',
            backgroundColor: ChefColors.danger,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12),
          );
        }
      },
      icon: const Icon(Icons.file_download_outlined, size: 18),
      label: Text(
        'Export Excel',
        style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1A1A1A),
        side: const BorderSide(color: Color(0xFF1A1A1A)),
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
