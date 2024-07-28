// main.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/api/api_client.dart';
import 'package:pencil_flutter/api/api_service.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/repository/data_repository.dart';
import 'package:pencil_flutter/dev/dev.dart';
import 'package:pencil_flutter/ui/home_screen.dart';
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

class PencilApp extends StatelessWidget {
  final DataRepository dataRepository;

  const PencilApp({super.key, required this.dataRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) =>
                  DataProvider(dataRepository: dataRepository)),
        ],
        child: const MaterialApp(
          title: 'Pencil',
          home: Scaffold(
            body: SafeArea(
              child: isDevWidget ? DevWidget() : HomeScreen(),
            ),
          ),
        ));
  }
}
