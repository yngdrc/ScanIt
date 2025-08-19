import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scanit/data/repositories/barcode/barcode_repository_local.dart';
import 'package:scanit/ui/core/themes/theme.dart';
import 'package:scanit/ui/main/widgets/main_screen.dart';
import 'package:scanit/utils/theme_utils.dart';

import 'data/services/database_service.dart';

void setupGetIt() {
  GetIt.instance.registerSingleton<DatabaseService>(DatabaseServiceImpl());
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupGetIt();
  runApp(const ScanItApp());
}

class ScanItApp extends StatelessWidget {
  const ScanItApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(
      context,
      "Roboto Flex",
      "Roboto Flex",
    );

    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'ScanIt',
      theme: theme.light(),
      darkTheme: theme.dark(),
      highContrastTheme: theme.lightHighContrast(),
      highContrastDarkTheme: theme.darkHighContrast(),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}
