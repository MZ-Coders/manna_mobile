import 'package:flutter/material.dart';
import 'package:dribbble_challenge/l10n/app_localizations.dart';
import 'package:dribbble_challenge/src/common/menu_data_service.dart';

class EventsModal extends StatefulWidget {
  const EventsModal({Key? key}) : super(key: key);

  @override
  State<EventsModal> createState() => _EventsModalState();
}

class _EventsModalState extends State<EventsModal> {
  List<Map<String, dynamic>> eventsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      // Verificar se o MenuDataService já tem os dados carregados
      if (MenuDataService().isInitialized) {
        // Usar os dados já em cache
        setState(() {
          eventsList = List<Map<String, dynamic>>.from(MenuDataService().events);
          isLoading = false;
        });
        
        print("Eventos carregados do cache: ${eventsList.length}");
        if (eventsList.isNotEmpty) {
          print("Primeiro evento: ${eventsList[0]}");
        }
      } else {
        // Inicializar o serviço se ainda não estiver inicializado
        final success = await MenuDataService().initialize();
        
        if (success) {
          setState(() {
            eventsList = List<Map<String, dynamic>>.from(MenuDataService().events);
            isLoading = false;
          });
          
          print("Eventos carregados da API: ${eventsList.length}");
          if (eventsList.isNotEmpty) {
            print("Primeiro evento: ${eventsList[0]}");
          }
        } else {
          setState(() {
            isLoading = false;
          });
          print("Falha ao carregar eventos");
        }
      }
    } catch (e) {
      print('Erro ao buscar eventos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Header fixo com linha decorativa
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Barra de arrasto
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Título e subtítulo
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    children: [
                      // Text(
                      //   AppLocalizations.of(context).events,
                      //   style: const TextStyle(
                      //     color: Color(0xFF1F2937),
                      //     fontSize: 28,
                      //     fontWeight: FontWeight.bold,
                      //     letterSpacing: -0.5,
                      //   ),
                      // ),
                      const SizedBox(height: 4),
                      Text(
                        'Confira os próximos eventos e promoções',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Linha decorativa
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFC6011).withOpacity(0.3),
                        const Color(0xFFFC6011),
                        const Color(0xFFFC6011).withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Conteúdo scrollable
          Expanded(
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : eventsList.isEmpty
                    ? _buildEmptyState()
                    : _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone com círculo decorativo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFC6011).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_outlined,
                size: 64,
                color: const Color(0xFFFC6011).withOpacity(0.6),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Título
            Text(
              AppLocalizations.of(context).noEventsAvailable,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Descrição
            Text(
              AppLocalizations.of(context).checkBackLater,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Botão de fechar opcional
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Fechar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFC6011),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    PageController pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );
    
    return Column(
      children: [
        // Carrossel horizontal de eventos com efeito de escala
        Expanded(
          child: PageView.builder(
            controller: pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: eventsList.length,
            itemBuilder: (context, index) {
              var event = eventsList[index];
              return AnimatedBuilder(
                animation: pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (pageController.position.haveDimensions) {
                    value = pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                  }
                  
                  return Center(
                    child: SizedBox(
                      height: Curves.easeInOut.transform(value) * 420,
                      child: Transform.scale(
                        scale: Curves.easeInOut.transform(value),
                        child: Opacity(
                          opacity: value < 0.8 ? 0.6 : 1.0,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildEventCard(event, index),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        
        // Indicador de pontos
        if (eventsList.length > 1)
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                eventsList.length,
                (index) => AnimatedBuilder(
                  animation: pageController,
                  builder: (context, child) {
                    double page = 0.0;
                    if (pageController.hasClients && pageController.position.haveDimensions) {
                      page = pageController.page ?? 0.0;
                    }
                    
                    double selectedness = (1.0 - (page - index).abs()).clamp(0.0, 1.0);
                    double zoom = 1.0 + (selectedness * 0.5);
                    
                    return Container(
                      width: 8.0 * zoom,
                      height: 8.0 * zoom,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFC6011).withOpacity(0.3 + (selectedness * 0.7)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, int index) {
    // Usar os mesmos campos da offer_view.dart
    final eventType = event['type'] ?? 'ANNOUNCEMENT';
    final title = event['name'] ?? '';
    final description = event['description'] ?? '';
    final eventDate = event['event_date'] ?? '';

    // Formatação da data do evento
    String formattedDate = "";
    String dayMonth = "";
    if (eventDate.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(eventDate);
        formattedDate = "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
        dayMonth = "${parsedDate.day}\n${_getMonthName(parsedDate.month)}";
      } catch (e) {
        formattedDate = eventDate;
        dayMonth = "00\nJAN";
      }
    }

    // Cor do tipo de evento com variações baseadas no índice
    List<List<Color>> gradientSets = [
      [Colors.blue.shade400, Colors.blue.shade600],
      [Colors.purple.shade400, Colors.purple.shade600],
      [Colors.orange.shade400, Colors.orange.shade600],
      [Colors.green.shade400, Colors.green.shade600],
      [Colors.red.shade400, Colors.red.shade600],
      [Colors.teal.shade400, Colors.teal.shade600],
    ];
    
    Color typeColor = Colors.blue;
    List<Color> gradientColors = gradientSets[index % gradientSets.length];
    IconData iconData;
    String badgeText;

    // Usar os mesmos tipos da offer_view.dart
    switch (eventType.toUpperCase()) {
      case 'PROMOTION':
        typeColor = Colors.orange;
        gradientColors = [Colors.orange.shade400, Colors.orange.shade600];
        iconData = Icons.local_offer;
        badgeText = 'PROMOÇÃO';
        break;
      case 'ANNOUNCEMENT':
        typeColor = Colors.green;
        gradientColors = [Colors.green.shade400, Colors.green.shade600];
        iconData = Icons.campaign;
        badgeText = 'ANÚNCIO';
        break;
      default:
        typeColor = gradientColors[0];
        iconData = Icons.event;
        badgeText = 'EVENTO';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: typeColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // ...existing code...
          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com tipo e data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tipo do evento
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            iconData,
                            color: Colors.white,
                            size: 18,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Data em formato compacto com design melhorado
                    if (dayMonth.isNotEmpty)
                      Container(
                        width: 60,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.97),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayMonth.split('\n')[0],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                                shadows: [
                                  Shadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              dayMonth.split('\n')[1],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: typeColor.withOpacity(0.8),
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                // Título do evento
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.18,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Descrição
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.97),
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // Data formatada na parte inferior com ícone melhorado
                if (formattedDate.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: Colors.white.withOpacity(0.95),
                          size: 17,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.97),
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
                    'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
    return months[month - 1];
  }
}
