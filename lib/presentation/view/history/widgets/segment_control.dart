import 'package:flutter/material.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';

class SegmentControl extends StatelessWidget {
  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SegmentControl({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.015),
      ),
      child: Container(
        height: context.dynamicHeight(.04),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 3, 0, 3),
          borderRadius: BorderRadius.circular(context.dynamicHeight(.015)),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(context.dynamicHeight(.01)),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: context.dynamicHeight(0.016),
                      color: isSelected ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
