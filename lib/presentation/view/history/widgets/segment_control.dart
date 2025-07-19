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
    const tabsPerRow = 3; 
    final rows = (tabs.length / tabsPerRow).ceil();
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.015),
      ),
      child: Container(
        height: context.dynamicHeight(.04) * rows + (rows > 1 ? context.dynamicHeight(0.008) : 0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 3, 0, 3),
          borderRadius: BorderRadius.circular(context.dynamicHeight(.015)),
        ),
        child: Column(
          children: List.generate(rows, (rowIndex) {
            final startIndex = rowIndex * tabsPerRow;
            final endIndex = (startIndex + tabsPerRow).clamp(0, tabs.length);
            final rowTabs = tabs.sublist(startIndex, endIndex);
            
            return Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: List.generate(rowTabs.length, (index) {
                        final actualIndex = startIndex + index;
                        final isSelected = currentIndex == actualIndex;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onTap(actualIndex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(context.dynamicHeight(.01)),
                              ),
                              child: Text(
                                rowTabs[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: context.dynamicHeight(0.016),
                                  color: isSelected ? Colors.black : Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  // İlk 3 tabdan sonra alt sıraya geçen tablar arasına boşluk ekle
                  if (rowIndex == 0 && rows > 1)
                    SizedBox(height: context.dynamicHeight(0.008)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
