import 'dart:async';

// Um simples notificador de eventos para comunicação entre widgets
// sem depender de um sistema completo de gerenciamento de estado
class OrderCountNotifier {
  // Singleton para garantir uma única instância
  static final OrderCountNotifier _instance = OrderCountNotifier._internal();
  
  // Construtor de fábrica que retorna a instância singleton
  factory OrderCountNotifier() {
    return _instance;
  }
  
  // Construtor interno privado
  OrderCountNotifier._internal();
  
  // StreamController para gerenciar os eventos
  final _controller = StreamController<void>.broadcast();
  
  // Stream para ouvir eventos
  Stream<void> get stream => _controller.stream;
  
  // Método para notificar todos os ouvintes
  void notify() {
    _controller.add(null);
  }
  
  // Método para fechar o controller quando não for mais necessário
  void dispose() {
    _controller.close();
  }
}
