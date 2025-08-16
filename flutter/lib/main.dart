import 'package:flutter/material.dart';
import 'package:scanit/ui/core/themes/theme.dart';
import 'package:scanit/ui/main/widgets/main_screen.dart';
import 'package:scanit/utils/util.dart';

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
