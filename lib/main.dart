import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/img/logotip.png'),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        body: Builder(
          builder: (context) {
            final size = MediaQuery.of(context).size;
            final width = size.width;
            final height = size.height;

            return Align(
              child: Container(
                width: width * 0.95,
                height: height * 0.85,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Expanded(
                        child: ListView(
                          children: [
                            _buildImageItem('assets/img/vsevedushiy_chitatel.jpg', 'Точка зрения всеведущего читателя'),
                            _buildImageItem('assets/img/solo_up_leveling.jpg', 'Поднятие уровня в одиночку'),
                            _buildImageItem('assets/img/pick_me_up.jpg', 'Выбери меня'),
                          ],
                        )
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
Widget _buildImageItem(String imagePath, String caption) {
  return Container(
    margin: EdgeInsets.only(bottom: 15),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Image.asset(
          imagePath,
          width: 150,
          height: 200,
          fit: BoxFit.cover,
        ),
        SizedBox(width: 15),
        Text(
          caption,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}