import 'package:flutter/material.dart';

import 'ui/pages/home_page.dart';

void main() {
  runApp(const TiemRuaXeApp());
}

class TiemRuaXeApp extends StatelessWidget {
  const TiemRuaXeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tiệm Rửa Xe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
