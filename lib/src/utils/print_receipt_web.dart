
import 'package:dribbble_challenge/src/utils/pdf_receipt_58mm.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'dart:html' as html;

Future<void> imprimirRecibo58mm({
  required String mesa,
  required List<Map<String, dynamic>> itens,
  required double total,
  String? observacoes,
  String? restaurantNome,
  String? garcom,
  int? order_id, // Adicionando o parâmetro de ID do pedido
}) async {
  final Uint8List pdfBytes = await gerarReciboPDF58mm(
    mesa: mesa,
    itens: itens,
    total: total,
    observacoes: observacoes,
    restaurantNome: restaurantNome ?? 'MannaSoftware',
    garcom: garcom,
    order_id: order_id, // Passando o ID do pedido para a função de geração do PDF
  );
  
  // Verificar se estamos em ambiente web
  if (kIsWeb) {
    try {
      // Abordagem mais simples: abrir o PDF diretamente
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Abrir em uma nova janela/aba
      html.window.open(url, 'Recibo Mesa $mesa');
      
      // Mostrar uma mensagem para o usuário
      html.window.alert(
        'Recibo aberto em uma nova janela.\n\n' +
        'Dica: Para imprimir, use o menu do navegador ou pressione Ctrl+P (Cmd+P no Mac).\n' +
        'Configure para impressora de 58mm sem margens.'
      );
    } catch (e) {
      print('Erro ao abrir janela: $e');
      // Fallback: usar o pacote printing
      await Printing.layoutPdf(
        onLayout: (_) => Future.value(pdfBytes),
        name: 'Recibo Mesa $mesa',
      );
    }
  } else {
    // Para outras plataformas
    await Printing.sharePdf(bytes: pdfBytes, filename: 'recibo_mesa_$mesa.pdf');
  }
}
