import 'package:flutter/material.dart';
import 'package:mind_flow/presentation/view/chat_screen.dart';
import 'package:mind_flow/presentation/viewmodel/journal_provider.dart';
import 'package:provider/provider.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<JournalViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Günlük & Zihin Haritası'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Günlük', icon: Icon(Icons.edit)),
            Tab(text: 'Analiz', icon: Icon(Icons.psychology)),
            Tab(text: 'Chat Bot', icon: Icon(Icons.chat)),
            Tab(text: 'Geçmiş', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJournalTab(vm),
          _buildAnalysisTab(vm),
          const ChatScreen(),
          _buildHistoryTab(vm),
        ],
      ),
    );
  }

  Widget _buildJournalTab(JournalViewModel vm) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
          // Model Seçimi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Model Seçimi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: vm.selectedModel,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Günlük Yazma Alanı
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bugün nasıl hissediyorsun?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TextField(
              controller: _controller,
                        maxLines: null,
                        expands: true,
              decoration: const InputDecoration(
                          hintText: 'Duygularını, düşüncelerini, yaşadıklarını yaz...',
                border: OutlineInputBorder(),
              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: vm.isLoading ? null : () => vm.analyzeText(_controller.text),
                        icon: vm.isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.psychology),
                        label: Text(vm.isLoading ? 'Analiz Ediliyor...' : 'AI ile Analiz Et'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab(JournalViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI analiz ediyor...'),
          ],
        ),
      );
    }

    if (vm.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              "Hata: ${vm.error}",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.analyzeText(_controller.text),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (vm.analysisResult == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Analiz sonucu görüntülemek için günlük yazın',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model Bilgisi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    'Model: ${vm.getModelDisplayName(vm.analysisResult!.modelUsed)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Özet
          if (vm.analysisResult!.summary.isNotEmpty) ...[
            _buildSectionCard(
              '📝 Özet',
              vm.analysisResult!.summary,
              Colors.blue,
            ),
            const SizedBox(height: 16),
          ],

          // Duygular
          _buildSectionCard(
            '🎭 Duygular',
            vm.analysisResult!.emotions.join(', '),
            Colors.red,
          ),
          const SizedBox(height: 16),

          // Temalar
          _buildSectionCard(
            '🧩 Ana Temalar',
            vm.analysisResult!.themes.join(', '),
            Colors.green,
          ),
          const SizedBox(height: 16),

          // Tavsiye
          _buildSectionCard(
            '💡 Tavsiye',
            vm.analysisResult!.advice,
            Colors.orange,
          ),
          const SizedBox(height: 16),

          // Zihin Haritası
          _buildMindMapCard(vm.analysisResult!.mindMap),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(JournalViewModel vm) {
    if (vm.analysisHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz analiz geçmişi yok',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Analiz Geçmişi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Geçmişi Temizle'),
                      content: const Text('Tüm analiz geçmişini silmek istediğinizden emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () {
                            vm.clearHistory();
                            Navigator.pop(context);
                          },
                          child: const Text('Temizle'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete),
                label: const Text('Temizle'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vm.analysisHistory.length,
            itemBuilder: (context, index) {
              final analysis = vm.analysisHistory[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.psychology, color: Colors.deepPurple),
                  title: Text(
                    analysis.summary.isNotEmpty 
                      ? analysis.summary 
                      : 'Analiz ${index + 1}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Model: ${vm.getModelDisplayName(analysis.modelUsed)}'),
                      Text(
                        'Tarih: ${analysis.analysisDate.day}/${analysis.analysisDate.month}/${analysis.analysisDate.year}',
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    vm.loadAnalysis(analysis);
                    _tabController.animateTo(1); // Analiz sekmesine geç
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, String content, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  Widget _buildMindMapCard(Map<String, List<String>> mindMap) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.circle, size: 12, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  '🧠 Zihin Haritası',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...mindMap.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📌 ${entry.key}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...entry.value.map((subItem) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, top: 2),
                        child: Row(
                          children: [
                            const Text('• ', style: TextStyle(color: Colors.grey)),
                            Expanded(child: Text(subItem)),
                ],
              ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
