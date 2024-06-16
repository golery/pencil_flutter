// main.dart

import 'package:flutter/material.dart';
import 'package:pencil_flutter/api/api_client.dart';
import 'package:pencil_flutter/api/api_service.dart';
import 'package:pencil_flutter/providers/tree_model_provider.dart';
import 'package:pencil_flutter/repository/data_repository.dart';
import 'package:pencil_flutter/dev/dev.dart';
import 'package:pencil_flutter/ui/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  // debugPaintSizeEnabled = true;

  final ApiClient apiClient = ApiClient(baseUrl: "https://pencil.golery.com");
  final ApiService apiService = ApiService(apiClient: apiClient);
  final DataRepository dataRepository = DataRepository(apiService: apiService);

  runApp(MyApp(dataRepository: dataRepository));
}

const IS_WIDGET_DEV = false;

class MyApp extends StatelessWidget {
  final DataRepository dataRepository;

  const MyApp({super.key, required this.dataRepository});

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
              child: IS_WIDGET_DEV ? DevWidget() : HomeScreen(),
            ),
          ),
        ));
  }
}
