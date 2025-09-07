// Arquivo de exemplo para demonstrar como a lógica de URL funciona
import 'package:flutter/foundation.dart';
import 'globs.dart';

void demonstrateUrlLogic() {
  if (kIsWeb) {
    print('=== Demonstração da Lógica de URL ===');
    print('URL atual do navegador: ${Uri.base.toString()}');
    print('Host detectado: ${Uri.base.host}');
    print('mainUrl determinada: ${SVKey.mainUrl}');
    print('baseUrl resultante: ${SVKey.baseUrl}');
    print('=====================================');
  } else {
    print('Esta função só funciona na web');
  }
}
