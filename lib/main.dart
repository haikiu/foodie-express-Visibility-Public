
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'views/home/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const FoodieExpressApp(),
    ),
  );
}

class FoodieExpressApp extends StatelessWidget {
  const FoodieExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foodie Express',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
