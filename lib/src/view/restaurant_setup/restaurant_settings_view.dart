import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dribbble_challenge/src/common/color_extension.dart';
import 'package:dribbble_challenge/src/view/restaurant_setup/restaurant_setup_view.dart';

class RestaurantSettingsView extends StatefulWidget {
  const RestaurantSettingsView({Key? key}) : super(key: key);

  @override
  State<RestaurantSettingsView> createState() => _RestaurantSettingsViewState();
}

class _RestaurantSettingsViewState extends State<RestaurantSettingsView> {
  String _restaurantName = '';
  String _restaurantId = '';
  String _tableId = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _restaurantName = prefs.getString('restaurant_name') ?? 'Não configurado';
      _restaurantId = prefs.getString('restaurant_id') ?? 'Não configurado';
      _tableId = prefs.getString('table_id') ?? 'Não configurada';
    });
  }

  Future<void> _reconfigureRestaurant() async {
    // Mostrar confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reconfigurar Restaurante'),
        content: const Text(
          'Tem certeza que deseja reconfigurar o restaurante? '
          'Isso irá apagar as configurações atuais e reiniciar o app.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Reconfigurar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Limpar configurações
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('restaurant_setup_completed', false);
      await prefs.remove('restaurant_id');
      await prefs.remove('restaurant_name');
      await prefs.remove('table_id');

      // Navegar para tela de configuração
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const RestaurantSetupView(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset(
            "assets/img/btn_back.png",
            width: 20,
            height: 20,
          ),
        ),
        title: Text(
          'Configurações do Restaurante',
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações atuais
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColor.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: TColor.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: TColor.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Configuração Atual',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColor.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Restaurante:', _restaurantName),
                  const SizedBox(height: 12),
                  _buildInfoRow('ID do Restaurante:', _restaurantId),
                  const SizedBox(height: 12),
                  _buildInfoRow('Mesa:', _tableId.isEmpty ? 'Não configurada' : _tableId),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Botão de reconfiguração
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.settings_backup_restore,
                    color: Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reconfigurar Restaurante',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Se você precisar alterar o restaurante ou recebeu um novo QR Code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: TColor.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _reconfigureRestaurant,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Reconfigurar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Informações adicionais
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Informações Importantes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoPoint('• O ID do restaurante é único para cada estabelecimento'),
                  const SizedBox(height: 8),
                  _buildInfoPoint('• A mesa pode ser alterada a qualquer momento'),
                  const SizedBox(height: 8),
                  _buildInfoPoint('• Reconfigurar não afeta os pedidos já feitos'),
                  const SizedBox(height: 8),
                  _buildInfoPoint('• Entre em contato com o restaurante se tiver problemas'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: TColor.secondaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TColor.primaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPoint(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.blue.shade700,
      ),
    );
  }
}
