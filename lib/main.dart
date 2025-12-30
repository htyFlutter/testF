import 'package:flutter/material.dart';
import 'package:test/screens/home_screen.dart';

void main() {
  runApp(HayatoApp());
}

class HayatoApp extends StatelessWidget {
  const HayatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectindex = 0;

  final List<Widget> _pageItems = [
    const HomeScreen(),
    const Center(child: Text('設定画面', style: TextStyle(fontSize: 24.0))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageItems[_selectindex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.train), label: '駅メモ'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
        currentIndex: _selectindex,
        onTap: _onItemTapped,
      ),
    );
  }
}
