import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mind_flow/core/services/adapty_billing_service.dart';
import 'package:mind_flow/core/services/adapty_test_helper.dart';
import 'package:mind_flow/injection/injection.dart';

/// Adapty debug widget - Geliştirme sırasında kullanın
class AdaptyDebugWidget extends StatefulWidget {
  const AdaptyDebugWidget({super.key});

  @override
  State<AdaptyDebugWidget> createState() => _AdaptyDebugWidgetState();
}

class _AdaptyDebugWidgetState extends State<AdaptyDebugWidget> {
  String _status = 'Checking...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking Adapty status...';
    });

    try {
      final billingService = getIt<AdaptyBillingService>();
      
      final buffer = StringBuffer();
      buffer.writeln('Platform: ${Platform.operatingSystem}');
      buffer.writeln('isAvailable: ${billingService.isAvailable}');
      buffer.writeln('Profile: ${billingService.profile?.profileId ?? "null"}');
      
      if (!billingService.isAvailable) {
        buffer.writeln('\n❌ Adapty NOT AVAILABLE');
        buffer.writeln('Possible reasons:');
        buffer.writeln('1. Running on unsupported platform (web/desktop)');
        buffer.writeln('2. Adapty initialization failed');
        buffer.writeln('3. API key incorrect');
      } else {
        buffer.writeln('\n✅ Adapty is available');
        
        // Test paywall
        final paywall = await billingService.getPaywall('subscription');
        if (paywall != null) {
          buffer.writeln('✅ Subscription paywall found');
        } else {
          buffer.writeln('❌ Subscription paywall NOT found');
          buffer.writeln('Make sure placement "subscription" exists in Adapty Dashboard');
        }
      }
      
      setState(() {
        _status = buffer.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _reinitialize() async {
    setState(() {
      _isLoading = true;
      _status = 'Reinitializing...';
    });

    try {
      await AdaptyTestHelper.reinitializeAdapty();
      await _checkStatus();
    } catch (e) {
      setState(() {
        _status = 'Reinitialization failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _runFullTest() async {
    setState(() {
      _isLoading = true;
      _status = 'Running full test...';
    });

    try {
      await AdaptyTestHelper.testAdaptyStatus();
      await _checkStatus();
    } catch (e) {
      setState(() {
        _status = 'Test failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adapty Debug'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Adapty Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      SelectableText(
                        _status,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _reinitialize,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reinitialize Adapty'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runFullTest,
              icon: const Icon(Icons.bug_report),
              label: const Text('Run Full Test'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Tips:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Make sure you\'re running on iOS or Android\n'
                      '• Check console logs for detailed errors\n'
                      '• Verify placement "subscription" exists in Adapty Dashboard\n'
                      '• Ensure paywall is published (not draft)',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
