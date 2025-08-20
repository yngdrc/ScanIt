import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanit/data/repositories/barcode/barcode_repository_local.dart';
import 'package:scanit/ui/colors.dart';
import 'package:scanit/ui/main/widgets/main_screen.dart';
import 'package:scanit/ui/scan_history/viewmodels/scan_history_view_model.dart';
import 'package:scanit/ui/scanner/viewmodels/scanner_view_model.dart';
import 'package:scanit/utils/theme_utils.dart';

import 'data/services/database_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: DatabaseServiceImpl()),
        Provider<BarcodeRepositoryLocal>(
          create: (context) =>
              BarcodeRepositoryLocal(databaseService: context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ScannerViewModel(barcodeRepository: context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ScanHistoryViewModel(barcodeRepository: context.read()),
        ),
      ],
      child: MaterialApp(
        title: 'ScanIt',
        theme: ThemeData(
          useMaterial3: true,
          useSystemColors: true,
          textTheme: textTheme,
          scaffoldBackgroundColor: ScanItColors.surface
        ),
        home: const MainScreen(),
      ),
    );
  }
}
