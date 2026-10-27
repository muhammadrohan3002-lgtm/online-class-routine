import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ServerConfigScreen extends ConsumerStatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  ConsumerState<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends ConsumerState<ServerConfigScreen> {
  late final TextEditingController _urlController;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _urlController = TextEditingController(
      text: storage.getBaseUrl() ?? ApiEndpoints.baseUrl,
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _applyPreset(String url) {
    setState(() {
      _urlController.text = url;
      _testResult = null;
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final targetUrl = _urlController.text.trim();
    final storage = ref.read(storageServiceProvider);
    await storage.setBaseUrl(targetUrl);
    ref.read(apiClientProvider).updateBaseUrl(targetUrl);

    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get(ApiEndpoints.health);

      setState(() {
        _isTesting = false;
        _testSuccess = true;
        _testResult = 'Connection Successful!\nStatus: ${res['status']}\nDatabase: ${res['database']}\nTimestamp: ${res['timestamp']}';
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _testSuccess = false;
        _testResult = 'Connection Failed:\n$e\n\nEnsure Next.js backend is running (npm run dev) at this address.';
      });
    }
  }

  Future<void> _saveAndClose() async {
    final targetUrl = _urlController.text.trim();
    final storage = ref.read(storageServiceProvider);
    await storage.setBaseUrl(targetUrl);
    ref.read(apiClientProvider).updateBaseUrl(targetUrl);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server URL set to: $targetUrl'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Server Setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Configure API Endpoint',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Specify the URL where your Next.js backend server is running.',
                style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _urlController,
                label: 'Base API URL',
                hint: 'http://localhost:5000/api',
                prefixIcon: Icons.dns_outlined,
              ),
              const SizedBox(height: 16),

              // Quick Presets
              const Text('Quick Environment Presets:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.wifi_rounded, size: 16),
                    label: const Text('Wi-Fi Phone (192.168.0.102)'),
                    onPressed: () => _applyPreset('http://192.168.0.102:5000/api'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.usb_rounded, size: 16),
                    label: const Text('USB / ADB Reverse (127.0.0.1)'),
                    onPressed: () => _applyPreset('http://127.0.0.1:5000/api'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.android_rounded, size: 16),
                    label: const Text('Android Emulator (10.0.2.2)'),
                    onPressed: () => _applyPreset('http://10.0.2.2:5000/api'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.computer_rounded, size: 16),
                    label: const Text('Localhost (Port 5000)'),
                    onPressed: () => _applyPreset('http://localhost:5000/api'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Test Connection Button
              CustomButton(
                text: 'Test Server Connection',
                variant: ButtonVariant.secondary,
                isLoading: _isTesting,
                icon: Icons.network_check_rounded,
                onPressed: _testConnection,
              ),
              const SizedBox(height: 16),

              if (_testResult != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _testSuccess ? AppColors.successContainer : AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _testSuccess ? AppColors.success : AppColors.error,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _testSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                        color: _testSuccess ? AppColors.successText : AppColors.errorText,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _testResult!,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontFamily: 'monospace',
                            color: _testSuccess ? AppColors.successText : AppColors.errorText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              CustomButton(
                text: 'Save and Apply',
                onPressed: _saveAndClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
