import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/portfolio_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MoskowStockApp());
}

class MoskowStockApp extends StatelessWidget {
  const MoskowStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<PortfolioService>(
      create: (_) {
        final svc = PortfolioService();
        svc.initialize();
        return svc;
      },
      child: MaterialApp(
        title: 'Московская биржа - Портфельный конструктор',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          typography: Typography.material2021(platform: TargetPlatform.windows),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          typography: Typography.material2021(platform: TargetPlatform.windows),
        ),
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
