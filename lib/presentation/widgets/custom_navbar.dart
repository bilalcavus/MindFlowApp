import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

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
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              label: 'Anasayfa',
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 1,
              icon: HugeIcons.strokeRoundedEnergy,
              label: 'Analiz Et',
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context,
              index: 2,
              icon: HugeIcons.strokeRoundedTransactionHistory,
              label: 'Geçmiş',
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
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.01),
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.grey[600],
              size: context.dynamicWidth(0.06),
            ),
            SizedBox(height: context.dynamicHeight(0.005)),
            // Text(
            //   label,
            //   style: TextStyle(
            //     color:  Colors.grey[600],
            //     fontSize: context.dynamicHeight(0.014),
            //     fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            //   ),
            // ),
          ],
        )
      ),
    );
  }
}