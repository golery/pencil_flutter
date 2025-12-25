// main.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/api/api_client.dart';
import 'package:pencil_flutter/api/api_service.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/repository/data_repository.dart';
import 'package:pencil_flutter/dev/dev.dart';
import 'package:pencil_flutter/ui/home_screen.dart';
import 'package:pencil_flutter/ui/share_content_screen.dart';
import 'package:pencil_flutter/services/share_handler.dart';
import 'package:provider/provider.dart';

// Show dev widget as a playground rather than app
const isDevWidget = false;

void main() {
  // debugPaintSizeEnabled = true;

  final ApiClient apiClient = ApiClient();
  final ApiService apiService = ApiService(apiClient: apiClient);
  final DataRepository dataRepository = DataRepository(apiService: apiService);

  runApp(PencilApp(dataRepository: dataRepository));
}

class PencilApp extends StatefulWidget {
  final DataRepository dataRepository;

  const PencilApp({super.key, required this.dataRepository});

  @override
  State<PencilApp> createState() => _PencilAppState();
}

class _PencilAppState extends State<PencilApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  String? _pendingSharedUrl;
  String? _pendingSharedImageUri;

  @override
  void initState() {
    super.initState();
    _initializeShareHandler();
  }

  void _initializeShareHandler() {
    final shareHandler = ShareHandler.instance;
    shareHandler.initialize();

    // Set up callback for shared text/URL
    shareHandler.setOnShareText((String text) {
      _handleSharedContent(sharedUrl: text);
    });

    // Set up callback for shared image
    shareHandler.setOnShareImage((String imageUri) {
      _handleSharedContent(sharedImageUri: imageUri);
    });
  }

  void _handleSharedContent({String? sharedUrl, String? sharedImageUri}) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => ShareContentScreen(
            sharedUrl: sharedUrl,
            sharedImageUri: sharedImageUri,
          ),
        ),
      );
    } else {
      // Navigator not ready yet, store for later
      setState(() {
        _pendingSharedUrl = sharedUrl;
        _pendingSharedImageUri = sharedImageUri;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) =>
                  DataProvider(dataRepository: widget.dataRepository)),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Pencil',
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF75A47F)),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFDFEFD3)),
          ),
          home: Builder(
            builder: (context) {
              // Check for pending shared content after first frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_pendingSharedUrl != null || _pendingSharedImageUri != null) {
                  _handleSharedContent(
                    sharedUrl: _pendingSharedUrl,
                    sharedImageUri: _pendingSharedImageUri,
                  );
                  setState(() {
                    _pendingSharedUrl = null;
                    _pendingSharedImageUri = null;
                  });
                }
              });

              return const Scaffold(
                body: SafeArea(
                  child: isDevWidget ? DevWidget() : HomeScreen(),
                ),
              );
            },
          ),
        ));
  }
}
