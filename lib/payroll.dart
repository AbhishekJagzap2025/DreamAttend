import 'package:flutter/material.dart';
import 'package:dream_attend/Constant/app_color.dart';
import 'advance_pay.dart';
import 'contracts_page.dart';
import 'payslip_page.dart';

class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  bool _showConfigOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.payrollLightBlue,
                  AppColor.payrollBackground,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Decorative Circles
          Positioned(
            top: -80,
            right: -80,
            child:
                _backgroundCircle(200, AppColor.payrollMuted.withOpacity(0.1)),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child:
                _backgroundCircle(250, AppColor.payrollInfo.withOpacity(0.15)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  _buildHeaderCard(),
                  const SizedBox(height: 32),
                  _buildMenuButton(
                    context,
                    icon: Icons.receipt_long_rounded,
                    label: 'Payslips',
                    gradient: const LinearGradient(
                      colors: [
                        AppColor.payrollIndigo,
                        AppColor.payrollIndigoDark
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PayslipPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildMenuButton(
                    context,
                    icon: Icons.assignment_turned_in_rounded,
                    label: 'Contracts',
                    gradient: const LinearGradient(
                      colors: [
                        AppColor.payrollGreen,
                        AppColor.payrollGreenDark
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ContractsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildMenuButton(
                    context,
                    icon: Icons.payment,
                    label: 'Advance Pay',
                    gradient: const LinearGradient(
                      colors: [
                        AppColor.payrollAccentDark,
                        AppColor.payrollAccent
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdvancePayPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // _buildConfigDropdown(context),
                  AnimatedOpacity(
                    opacity: _showConfigOptions ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _showConfigOptions ? null : 0,
                      child: _showConfigOptions
                          ? const Column(
                              children: [
                                SizedBox(height: 10),
                                // _buildDropdownOption(
                                //   context,
                                //   label: 'Salary Rules',
                                //   onPressed: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) => SalaryRulePage(
                                //           configurationService:
                                //               ConfigurationService(),
                                //         ),
                                //       ),
                                //     );
                                //     setState(() {
                                //       _showConfigOptions = false;
                                //     });
                                //   },
                                // ),
                                SizedBox(height: 10),
                                // _buildDropdownOption(
                                //   context,
                                //   label: 'Salary Structure',
                                //   onPressed: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) =>
                                //             SalaryStructurePage(
                                //           configurationService:
                                //               ConfigurationService(),
                                //         ),
                                //       ),
                                //     );
                                //     setState(() {
                                //       _showConfigOptions = false;
                                //     });
                                //   },
                                // ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 100),
                  Text(
                    // '© 2025 Payroll System (Dreamwarez)',
                    '© ${DateTime.now().year} Payroll System (Dreamwarez)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColor.white,
        // boxShadow: [],
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
        border: Border.all(color: AppColor.grey.shade200),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            size: 80,
            color: AppColor.payrollBlue,
          ),
          const SizedBox(height: 16),
          const Text(
            'Payroll Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColor.payrollBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Streamline payslips, contracts, and settings with ease.',
            style: TextStyle(
              fontSize: 14,
              color: AppColor.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onPressed,
  }) {
    // return GestureDetector(
    //   onTap: onPressed,
    //   child: AnimatedContainer(
    return Material(
        color: AppColor.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColor.grey.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 32, color: AppColor.white),
                const SizedBox(width: 20),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColor.white,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildConfigDropdown(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showConfigOptions = !_showConfigOptions;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // gradient: const LinearGradient(
          //   colors: [AppColor.payrollOrange, AppColor.payrollOrangeDark],
          // ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: const Row(
          children: [
            // const Icon(Icons.settings_suggest, size: 32, color: AppColor.white),
            // const SizedBox(width: 20),
            // const Text(
            //   'Configuration',
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w500,
            //     color: AppColor.white,
            //   ),
            // ),
            // const Spacer(),
            // Icon(
            //   _showConfigOptions
            //       ? Icons.arrow_drop_up_rounded
            //       : Icons.arrow_drop_down_rounded,
            //   size: 32,
            //   color: AppColor.white,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownOption(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColor.payrollOrangeLight,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColor.grey.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            const SizedBox(width: 52),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColor.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backgroundCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
