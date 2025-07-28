import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';

class AnalysisTypes {
  static const  List<Map<String, dynamic>> analysisTypes = [
    {
      'title': "analysis_emotion_title",
      'icon': Iconsax.heart,
      'color': Colors.red,
    },
    {
      'title': "analysis_dream_title",
      'icon': HugeIcons.strokeRoundedBlackHole,
      'color': Colors.purple,
    },
    {
      'title': "analysis_personality_title",
      'icon': Iconsax.personalcard,
      'color': Colors.blue,
    },
    {
      'title': "analysis_habit_title",
      'icon': Iconsax.repeat,
      'color': Colors.green,
    },
    {
      'title': "analysis_mental_title",
      'icon': HugeIcons.strokeRoundedBrain,
      'color': Colors.orange,
    },
    {
      'title': "analysis_stress_title",
      'icon': HugeIcons.strokeRoundedFire,
      'color': Colors.amber,
    },
  ];
  static int selectedAnalysisType = 0;
}

