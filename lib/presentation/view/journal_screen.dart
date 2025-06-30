import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/core/helper/route_helper.dart';
import 'package:mind_flow/presentation/view/chat_screen.dart';
import 'package:mind_flow/presentation/view/journal_analysis_screen.dart';
import 'package:mind_flow/presentation/viewmodel/journal_provider.dart';
import 'package:mind_flow/presentation/widgets/journal_text_field.dart';
import 'package:provider/provider.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JournalViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Günlük & Zihin Haritası'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Model Seçimi
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16)
                ),
                child: DropdownButtonFormField<String>(
                  padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.03)),
                  value: vm.selectedModel,
                  decoration:  InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: context.dynamicWidth(0.02)),
                    labelText: 'Model',
                  ),
                  items: vm.availableModels.map((model) {
                    return DropdownMenuItem(
                      value: model,
                      child: Text(vm.getModelDisplayName(model)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) vm.changeModel(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Günlük Yazma Alanı
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  
                    JournalTextField(controller: vm.textController, label: 'Bugün nasıl hissediyorsun?', hint: "Bugün ne hissettiğini, neler yaşadığını, paylaşmak istediklerini istediğin şekilde yaz, sana yardımcı olayım!", maxLines: 10),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: vm.isLoading
                            ? null
                            : () async {
                                await vm.analyzeText(vm.textController.text);
                                vm.clearText();
                                RouteHelper.push(context, JournalAnalysisScreen());
                              },
                        icon: vm.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.psychology),
                        label: Text(vm.isLoading ? 'Analiz Ediliyor...' : 'Gönder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        autofocus: true,
        backgroundColor: const Color.fromARGB(255, 146, 140, 233),
        tooltip: "Flow ile konuşmak için üstüme bas!",
        child: const Icon(HugeIcons.strokeRoundedAiBrain01),
        onPressed: () => RouteHelper.push(context, const ChatScreen())
      ),
    );
  }
}
