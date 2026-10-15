import 'package:chefadmin/screens/AdminMenuUploadScreen.dart';
import 'package:chefadmin/screens/DayScholarOrdersScreen.dart';
import 'package:chefadmin/screens/Skip%20_StatsScreen.dart';
import 'package:chefadmin/screens/payment_notice_banner.dart';
import 'package:chefadmin/screens/student_financial_screen.dart';
import 'package:chefadmin/screens/studetns_feesbackscreen.dart';
import 'package:chefadmin/screens/payment_history_screen.dart';
import 'package:chefadmin/screens/token_history_screen.dart';
import 'package:chefadmin/screens/token_status_scrren.dart';
import 'package:chefadmin/screens/updateing_user_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  static const Color chefYellow = Color(0xFFFFC800);
  static const Color background = Color(0xFFF7F8FA);
  static const Color textPrimary = Color(0xFF171A21);
  static const Color textSecondary = Color(0xFF737B8C);
  static const Color borderColor = Color(0xFFE2E6EC);

  static const Color teal = Color(0xFF00897B);
  static const Color orange = Color(0xFFE58F00);
  static const Color greyBlue = Color(0xFF546E7A);
  static const Color green = Color(0xFF2E7D32);
  static const Color red = Color(0xFFD84315);
  static const Color purple = Color(0xFF7656A6);
  static const Color blue = Color(0xFF3949AB);

  @override
  Widget build(BuildContext context) {
    // ⚠️ First tap anywhere shows the payment notice; screen unlocks after "I understand".
    return PaymentNoticeGate(
      child: Scaffold(
        backgroundColor: background,
        appBar: _buildAppBar(context),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isMobile = width < 600;
            final isTablet = width >= 600 && width < 1000;
            final isDesktop = width >= 1000;

            final columns = isDesktop ? 4 : (isTablet ? 2 : 1);

            final horizontalPadding =
                isMobile ? 14.0 : (isTablet ? 22.0 : 26.0);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1500),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isMobile ? 16 : 24,
                    horizontalPadding,
                    isMobile ? 14 : 24,
                  ),
                  child: Column(
                    children: [
                      const PaymentNoticeBanner(),
                      _buildDashboardHeader(
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: isMobile ? 14 : 20),
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(bottom: isMobile ? 10 : 24),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: isMobile ? 10 : 16,
                            mainAxisSpacing: isMobile ? 10 : 16,
                            childAspectRatio: _getCardAspectRatio(width),
                          ),
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            return _buildMenuItem(index, isMobile: isMobile);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return AppBar(
      backgroundColor: chefYellow,
      surfaceTintColor: chefYellow,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: isMobile ? 60 : 66,
      titleSpacing: isMobile ? 14 : 20,
      title: Row(
        children: [
          Container(
            width: isMobile ? 36 : 40,
            height: isMobile ? 36 : 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 11),
            ),
            child: Icon(
              Icons.restaurant_rounded,
              color: Colors.black,
              size: isMobile ? 19 : 21,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chef Hospitality',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: isMobile ? 15 : 16.5,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Admin Control Center',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF5C4900),
                  fontSize: isMobile ? 9.5 : 10.5,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: isMobile ? 12 : 20),
          child: _buildAdminBadge(isMobile),
        ),
      ],
    );
  }

  Widget _buildAdminBadge(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 11,
        vertical: isMobile ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Admin',
            style: GoogleFonts.poppins(
              color: textPrimary,
              fontSize: isMobile ? 9.5 : 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader({
    required bool isMobile,
    required bool isTablet,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontSize: isMobile ? 19 : (isTablet ? 22 : 25),
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isMobile
                    ? 'Manage mess operations'
                    : 'Manage your mess operations from one place',
                style: GoogleFonts.poppins(
                  color: textSecondary,
                  fontSize: isMobile ? 10.5 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (!isMobile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'System Active',
                  style: GoogleFonts.poppins(
                    color: textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  double _getCardAspectRatio(double width) {
    if (width < 600) return 3.0;
    if (width < 1000) return 2.05;

    // Bigger desktop cards.
    return 1.65;
  }

  Widget _buildMenuItem(int index, {required bool isMobile}) {
    switch (index) {
      case 0:
        return _buildMenuCard(
          title: 'Token Dashboard',
          subtitle: 'Real-time meal tracking',
          icon: Icons.dashboard_customize_rounded,
          color: teal,
          isPrimary: true,
          isMobile: isMobile,
          onTap: () => Get.to(() => TokenStatusScreen()),
        );

      case 1:
        return _buildMenuCard(
          title: 'Student Financial',
          subtitle: 'Payments & access management',
          icon: Icons.account_balance_wallet_rounded,
          color: orange,
          isPrimary: true,
          isMobile: isMobile,
          onTap: () => Get.to(() => StudentFinancialScreen()),
        );

      case 2:
        return _buildMenuCard(
          title: 'Token Logs',
          subtitle: 'Full token generation history',
          icon: Icons.history_edu_rounded,
          color: greyBlue,
          isMobile: isMobile,
          onTap: () => Get.to(() => const TokenHistoryScreen()),
        );

      case 3:
        return _buildMenuCard(
          title: 'Revenue Records',
          subtitle: 'Online & offline payments',
          icon: Icons.payments_rounded,
          color: green,
          isMobile: isMobile,
          onTap: () => Get.to(() => const GlobalPaymentHistoryScreen()),
        );

      case 4:
        return _buildMenuCard(
          title: 'Menu Upload',
          subtitle: 'Manage daily food menu',
          icon: Icons.restaurant_menu_rounded,
          color: red,
          isMobile: isMobile,
          onTap: () => Get.to(() => const AdminMenuUploadScreen()),
        );

      case 5:
        return _buildMenuCard(
          title: 'Day Scholar Orders',
          subtitle: 'Manage day scholar orders',
          icon: Icons.set_meal_rounded,
          color: purple,
          isMobile: isMobile,
          onTap: () => Get.to(() => DayScholarOrdersScreen()),
        );

      case 6:
        return _buildMenuCard(
          title: 'Student Feedback',
          subtitle: 'Ratings & student reviews',
          icon: Icons.feedback_rounded,
          color: const Color(0xFFB77900),
          isMobile: isMobile,
          onTap: () => Get.to(() => const StudentsFeedbackScreen()),
        );

      case 7:
        return _buildMenuCard(
          title: 'User Management',
          subtitle: 'Approve & renew access',
          icon: Icons.manage_accounts_rounded,
          color: blue,
          isLast: true,
          isMobile: isMobile,
          onTap: () => Get.to(() => UpdateingUserStatusScreen()),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isMobile,
    bool isPrimary = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 14 : 17),
        hoverColor: chefYellow.withValues(alpha: 0.035),
        splashColor: chefYellow.withValues(alpha: 0.08),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 13 : 20,
            vertical: isMobile ? 10 : 18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 14 : 17),
            border: Border.all(
              color: isPrimary
                  ? chefYellow.withValues(alpha: 0.85)
                  : isLast
                  ? const Color(0xFFD6DCE6)
                  : borderColor,
              width: isPrimary ? 1.35 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: isMobile ? 43 : 62,
                height: isMobile ? 43 : 62,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(isMobile ? 11 : 16),
                ),
                child: Icon(icon, color: color, size: isMobile ? 21 : 29),
              ),

              SizedBox(width: isMobile ? 10 : 17),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: textPrimary,
                              fontSize: isMobile ? 12.5 : 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isPrimary) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: chefYellow,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'MAIN',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 7,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: textSecondary,
                        fontSize: isMobile ? 9.5 : 11,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Container(
                width: isMobile ? 30 : 40,
                height: isMobile ? 30 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(isMobile ? 9 : 11),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: isMobile ? 11 : 14,
                  color: const Color(0xFF89909E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}