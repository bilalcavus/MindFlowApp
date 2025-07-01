import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/analysis_pages/dream_analysis_page.dart';
import 'package:mind_flow/presentation/view/chat_screen.dart';
import 'package:mind_flow/presentation/view/journal_screen.dart';
import 'package:mind_flow/presentation/viewmodel/chat_bot_provider.dart';
import 'package:provider/provider.dart';

import '../viewmodel/analysis/journal_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String> analysisList = [
    "Rüya Analizi",
    "Duygu Analizi",
    "Kişilik Analizi",
    "Alışkanlık Analizi",
    "Zihinsel Analiz",
    "Stres/Tükenmişlik Analizi"
  ];

  IconData getModelIcon(String modelKey) {
  switch (modelKey) {
    case 'mistral-small-3.2':
      return HugeIcons.strokeRoundedMistral;
    case 'mistral-nemo':
      return HugeIcons.strokeRoundedMistral;
    case 'llama-3.1':
      return Icons.pets;
    case 'gpt-4.1-nano':
      return HugeIcons.strokeRoundedChatGpt;
    case 'deepsek-v3':
      return HugeIcons.strokeRoundedDeepseek;
    case 'gemini-2.0-flash':
      return HugeIcons.strokeRoundedGoogleGemini;
    case 'qwen3-32b':
      return HugeIcons.strokeRoundedQwen;
    default:
      return Icons.device_unknown;
  }
}

  Widget getPageType(String analysisType){
    switch(analysisType){
      case 'Rüya Analizi' :
      return const DreamAnalysisPage();
      case 'Duygu Analizi' :
      return const JournalScreen();
      default: 
        return  throw Exception('Desteklenmeyen analiz tipi: $analysisType');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _homeModelAvatars(context),
            SizedBox(
              height: context.dynamicHeight(0.5),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: analysisList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 6.0,
                    mainAxisSpacing: 6.0
                    ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                       RouteHelper.push(context, getPageType(analysisList[index]));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(context.dynamicHeight(0.03))
                        ),
                        child: Center(child: Text(analysisList[index], textAlign: TextAlign.center,)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeModelAvatars(BuildContext context) {
    final journalProvider = context.watch<JournalViewModel>();
    final models = journalProvider.availableModels;
    final chatbotProvider = context.watch<ChatBotProvider>();
    return SizedBox(
      height: context.dynamicHeight(0.08),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: models.length,
        itemBuilder: (context, index) {
          final modelKey = models[index];
          final modelName = journalProvider.getModelDisplayName(modelKey);
          return InkWell(
            onTap: () {
              chatbotProvider.changeModel(modelKey);
              RouteHelper.push(context, const ChatScreen());
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.03)),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(getModelIcon(modelKey)),
                  ),
                  SizedBox(height: context.dynamicHeight(0.002)),
                  Text(modelName, style: TextStyle(fontSize: context.dynamicHeight(0.012)), textAlign: TextAlign.center,)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  
}