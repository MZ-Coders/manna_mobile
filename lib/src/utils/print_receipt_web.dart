
import 'package:dribbble_challenge/src/utils/pdf_receipt_58mm.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

Future<void> imprimirRecibo58mm({
  required String mesa,
  required List<Map<String, dynamic>> itens,
  required double total,
  String? observacoes,
  String? restaurantNome,
  String? garcom,
  int? order_id,
}) async {
  final Uint8List pdfBytes = await gerarReciboPDF58mm(
    mesa: mesa,
    itens: itens,
    total: total,
    observacoes: observacoes,
    restaurantNome: restaurantNome ?? 'MannaSoftware',
    garcom: garcom,
    order_id: order_id,
  );
  
  // Para todas as plataformas, usar o pacote printing
  try {
    if (kIsWeb) {
      // Na web, usar layoutPdf que abre a caixa de diálogo de impressão
      await Printing.layoutPdf(
        onLayout: (_) => Future.value(pdfBytes),
        name: 'Recibo Mesa $mesa',
      );
    } else {
      // Em plataformas móveis/desktop, compartilhar o PDF
      await Printing.sharePdf(bytes: pdfBytes, filename: 'recibo_mesa_$mesa.pdf');
    }
  } catch (e) {
    print('Erro ao processar recibo: $e');
    // Fallback: tentar compartilhar em qualquer plataforma
    try {
      await Printing.sharePdf(bytes: pdfBytes, filename: 'recibo_mesa_$mesa.pdf');
    } catch (e2) {
      print('Erro no fallback: $e2');
      // Se tudo falhar, pelo menos salvar localmente se possível
      if (kDebugMode) {
        print('PDF gerado com ${pdfBytes.length} bytes');
      }
    }
  }
}
