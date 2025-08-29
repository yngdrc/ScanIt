import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanit/data/repositories/barcode/barcode_repository_local.dart';
import 'package:scanit/ui/colors.dart';
import 'package:scanit/ui/scan_history/viewmodels/scan_history_view_model.dart';
import 'package:scanit/ui/scan_history/widgets/scan_history_screen.dart';
import 'package:scanit/ui/scanner/viewmodels/scanner_view_model.dart';
import 'package:scanit/ui/scanner/widgets/scanner_screen.dart';
import 'package:scanit/utils/theme_utils.dart';

import 'data/services/database_service.dart';

Future<void> main() async {
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
          create: (context) {
            return BarcodeRepositoryLocal(databaseService: context.read());
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return ScannerViewModel();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return ScanHistoryViewModel(barcodeRepository: context.read());
          },
        ),
      ],
      builder: (context, _) {
        return MaterialApp(
          title: 'ScanIt',
          theme: ThemeData(
            useMaterial3: true,
            useSystemColors: true,
            textTheme: textTheme,
            scaffoldBackgroundColor: ScanItColors.surface,
          ),
          home: ScannerScreen(viewModel: context.watch()),
          routes: <String, WidgetBuilder>{
            '/scanHistory': (context) {
              return ScanHistoryScreen(viewModel: context.watch());
            },
          },
        );
      },
    );
  }
}
