
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

Future<Uint8List> gerarReciboPDF58mm({
  required String mesa,
  required List<Map<String, dynamic>> itens,
  required double total,
  String? observacoes,
  String restaurantNome = 'MannaSoftware',  // Nome do restaurante com valor padrão
  String? garcom,
  int? order_id, // ID do pedido retornado pela API
}) async {
  final PdfDocument document = PdfDocument();
  final page = document.pages.add();

  // 58mm = 164pt (largura para impressoras térmicas padrão)
  double largura = 164;
  double y = 0;

  // Configurar formatadores
  final formatoMoeda = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MT', decimalDigits: 2);
  final formatoData = DateFormat('dd/MM/yyyy HH:mm');
  final agora = DateTime.now();
  
  // Debug dos itens recebidos
  print('Gerando recibo para Mesa $mesa com ${itens.length} itens e total $total');

  // Logo ou Nome do restaurante no topo (cabeçalho)
  page.graphics.drawString(
    restaurantNome,
    PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
    brush: PdfSolidBrush(PdfColor(0, 0, 0)),
    bounds: Rect.fromLTWH(0, y, largura, 20),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  y += 16;

  // Linha separadora após nome do restaurante
  page.graphics.drawLine(
    PdfPen(PdfColor(0, 0, 0), dashStyle: PdfDashStyle.dash),
    Offset(0, y),
    Offset(largura, y),
  );
  y += 8;

  // Título do pedido
  page.graphics.drawString(
    'Pedido - Mesa $mesa',
    PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(0, y, largura, 20),
  );
  y += 22;

  // Data/hora do pedido
  page.graphics.drawString(
    formatoData.format(agora),
    PdfStandardFont(PdfFontFamily.helvetica, 9),
    bounds: Rect.fromLTWH(0, y, largura, 12),
  );
  y += 14;
  
  // Garçom (se disponível)
  // if (garcom != null && garcom.isNotEmpty) {
  //   page.graphics.drawString(
  //     'Garçom: $garcom',
  //     PdfStandardFont(PdfFontFamily.helvetica, 9),
  //     bounds: Rect.fromLTWH(0, y, largura, 12),
  //   );
  //   y += 14;
  // }

  // Linha separadora antes dos itens
  page.graphics.drawLine(
    PdfPen(PdfColor(0, 0, 0)),
    Offset(0, y),
    Offset(largura, y),
  );
  y += 10;

  // Cabeçalho dos itens
  page.graphics.drawString(
    'Item',
    PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(0, y, largura * 0.6, 12),
  );
  page.graphics.drawString(
    'Qtd x Preço',
    PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(largura * 0.6, y, largura * 0.4, 12),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );
  y += 12;

  // Itens do pedido
  print("Processando ${itens.length} itens para o PDF");
  for (var item in itens) {
    try {
      // Validar e registrar dados do item
      print("Item: ${item['nome']}, Qtd: ${item['qtd']}, Preço: ${item['preco']}");
      
      // Nome do item
      page.graphics.drawString(
        '${item['nome']}',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(0, y, largura, 14),
      );
      y += 14;
      
      // Quantidade e preço
      // Tratamento mais robusto para os valores
      double precoUnitario = 0.0;
      int quantidade = 1;
      
      try {
        if (item['preco'] is num) {
          precoUnitario = (item['preco'] as num).toDouble();
        } else if (item['preco'] is String) {
          precoUnitario = double.tryParse(item['preco'] as String) ?? 0.0;
        }
        
        if (item['qtd'] is num) {
          quantidade = (item['qtd'] as num).toInt();
        } else if (item['qtd'] is String) {
          quantidade = int.tryParse(item['qtd'] as String) ?? 1;
        }
      } catch (e) {
        print("Erro ao converter preço/quantidade: $e");
      }
      
      final subtotal = precoUnitario * quantidade;
      
      page.graphics.drawString(
        '$quantidade x ${formatoMoeda.format(precoUnitario)}',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        bounds: Rect.fromLTWH(0, y, largura * 0.7, 12),
      );
      
      page.graphics.drawString(
        '${formatoMoeda.format(subtotal)}',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        bounds: Rect.fromLTWH(largura * 0.5, y, largura * 0.5, 12),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
      
      y += 12;
    } catch (e) {
      print("Erro ao processar item do recibo: $e");
      // Adicionar um item de fallback para evitar que o recibo fique sem itens
      page.graphics.drawString(
        'Item com erro',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(0, y, largura, 14),
      );
      y += 14;
    }
  }

  // Linha separadora antes do total
  y += 6;
  page.graphics.drawLine(
    PdfPen(PdfColor(0, 0, 0)),
    Offset(0, y),
    Offset(largura, y),
  );
  y += 10;
  
  // Total
  page.graphics.drawString(
    'Total:',
    PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(0, y, largura * 0.5, 20),
  );
  
  page.graphics.drawString(
    formatoMoeda.format(total),
    PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(largura * 0.5, y, largura * 0.5, 20),
    format: PdfStringFormat(alignment: PdfTextAlignment.right),
  );
  y += 22;

  // Observações
  if (observacoes != null && observacoes.isNotEmpty) {
    page.graphics.drawString(
      'Obs:',
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, y, largura, 12),
    );
    y += 12;
    
    page.graphics.drawString(
      observacoes,
      PdfStandardFont(PdfFontFamily.helvetica, 9),
      bounds: Rect.fromLTWH(0, y, largura, 30),
    );
    y += 30;
  }
  
  // Linha separadora
  page.graphics.drawLine(
    PdfPen(PdfColor(0, 0, 0), dashStyle: PdfDashStyle.dash),
    Offset(0, y),
    Offset(largura, y),
  );
  y += 12;

  // Mensagem de agradecimento
  page.graphics.drawString(
    'Obrigado pela preferência!',
    PdfStandardFont(PdfFontFamily.helvetica, 9),
    bounds: Rect.fromLTWH(0, y, largura, 12),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  y += 16;
  
  // Nome do restaurante no rodapé
  page.graphics.drawString(
    restaurantNome,
    PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
    bounds: Rect.fromLTWH(0, y, largura, 14),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );
  
  // Código do pedido (ID do pedido retornado pela API)
  y += 20;
  final codigoPedido = order_id != null ? '#${order_id}' : '#';
  page.graphics.drawString(
    codigoPedido,
    PdfStandardFont(PdfFontFamily.helvetica, 8),
    bounds: Rect.fromLTWH(0, y, largura, 12),
    format: PdfStringFormat(alignment: PdfTextAlignment.center),
  );

  final bytes = await document.save();
  document.dispose();
  return Uint8List.fromList(bytes);
}
