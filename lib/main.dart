import 'package:flutter/material.dart';

import 'features/number_trivia/presentation/pages/pagina_teste.dart';
// import 'features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'injection_container.dart' as injection;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await injection.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(
        primaryColor: Colors.blueAccent.shade700,
      ),
      home: PaginaTeste(),
    );
  }
}
