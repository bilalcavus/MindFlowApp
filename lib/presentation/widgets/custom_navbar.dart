import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/widgets/theme/custom_color_theme.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavbar({
    super.key, 
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.08),
      decoration: BoxDecoration(
        color: CustomColorTheme.bottomNavBarColor(context),
        boxShadow: [
          BoxShadow(
            color: CustomColorTheme.containerShadow(context),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildNavItem(
              context,
              index: 0,
              icon: HugeIcons.strokeRoundedHome04,
              label: 'home'.tr(),
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 1,
              icon: Iconsax.calendar,
              label: 'history'.tr(),
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 2,
              icon: HugeIcons.strokeRoundedUserAccount,
              label: 'profile'.tr(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.02),
        ),
        decoration: BoxDecoration(
          // color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? CustomColorTheme.navbarSelectedColor(context) : Colors.grey[600],
              size: context.dynamicWidth(0.06),
            ),
            Text(
              label,
              style: TextStyle(
                color:  isSelected ? CustomColorTheme.navbarSelectedColor(context)  : Colors.grey[600],
                fontSize: context.dynamicHeight(0.014),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        )
      ),
    );
  }
}