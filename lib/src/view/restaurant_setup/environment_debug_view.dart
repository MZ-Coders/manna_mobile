import 'package:flutter/material.dart';
import 'package:dribbble_challenge/src/common/api_config.dart';

class EnvironmentDebugView extends StatelessWidget {
  const EnvironmentDebugView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final envInfo = ApiConfig.environmentInfo;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração do Ambiente'),
        backgroundColor: envInfo['environment'] == 'Produção' ? Colors.green : Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ambiente Atual',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Ambiente:', envInfo['environment']!),
                    _buildInfoRow('URL da API:', envInfo['api_url']!),
                    _buildInfoRow('É Produção:', envInfo['is_production']!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Como Funciona a Detecção',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('1. QR Code de teste: https://test.app.manna.software/...'),
                    const Text('   → API: https://test.manna.software'),
                    const SizedBox(height: 8),
                    const Text('2. QR Code de produção: https://app.manna.software/...'),
                    const Text('   → API: https://manna.software'),
                    const SizedBox(height: 8),
                    const Text('3. Outras URLs → API de teste (padrão)'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
