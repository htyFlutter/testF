import 'package:flutter/material.dart';
import 'package:test/screens/home_screen.dart';

void main() {
  runApp(const Hayatoapp());
}

class Hayatoapp extends StatelessWidget {
  const Hayatoapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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

  static const List<Widget> _pageItems = <Widget>[
    HomeScreen(),
    Text('2', style: TextStyle(fontSize: 50.0)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ボタンバー')),
      body: Center(child: _pageItems.elementAt(_selectindex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: '学校'),
          BottomNavigationBarItem(icon: Icon(Icons.atm), label: '夫'),
        ],
        currentIndex: _selectindex,
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectindex = index;
    });
  }
}
