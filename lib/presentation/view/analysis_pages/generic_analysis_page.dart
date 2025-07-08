import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mind_flow/core/helper/dynamic_size_helper.dart';
import 'package:mind_flow/presentation/widgets/custom_text_field.dart';

class GenericAnalysisPage extends StatelessWidget {
  final String title;
  final String textFieldLabel;
  final String textFieldHint;
  final String analyzeButtonText;
  final bool isLoading;
  final VoidCallback onAnalyze;
  final TextEditingController textController;
  final List<String> availableModels;
  final String selectedModel;
  final void Function(String?) onModelChange;
  final String Function(String) getModelDisplayName;
  final Widget resultPage;

  const GenericAnalysisPage({
    super.key,
    required this.title,
    required this.textFieldLabel,
    required this.textFieldHint,
    required this.analyzeButtonText,
    required this.isLoading,
    required this.onAnalyze,
    required this.textController,
    required this.availableModels,
    required this.selectedModel,
    required this.onModelChange,
    required this.getModelDisplayName,
    required this.resultPage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        centerTitle: true,
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        backgroundColor: Colors.transparent
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E0249),
              Color(0xFF3A0CA3),
              Color.fromARGB(255, 22, 5, 63),
              Color(0xFF000000),

            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.dynamicHeight(0.018)),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(context.dynamicHeight(0.016)),
                child: DropdownButtonFormField<String>(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.03),
                  value: selectedModel,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.02),
                    labelText: 'Model',
                  ),
                  items: availableModels.map((model) {
                    return DropdownMenuItem(
                      value: model,
                      child: Text(getModelDisplayName(model)),
                    );
                  }).toList(),
                  onChanged: onModelChange,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.02)),
              Padding(
                padding: EdgeInsets.all(context.dynamicHeight(0.016)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: textController,
                      label: textFieldLabel,
                      hint: textFieldHint,
                      maxLines: 10),
                    SizedBox(height: context.dynamicHeight(0.02)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : onAnalyze,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(HugeIcons.strokeRoundedAiBrowser),
                        label: Text(isLoading ? 'Analiz Ediliyor...' : analyzeButtonText),
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
            ],
          ),
        ),
      ),
    );
  }
} 


// Color(0xFF1A1A2E), // Koyu mavi
// Color.fromARGB(255, 25, 18, 51),
// Color.fromARGB(255, 74, 26, 58),