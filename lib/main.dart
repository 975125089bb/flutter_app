import 'package:flutter/material.dart';
//TODO: Step 2 - Import the rFlutter_Alert package here.
import 'characters_data.dart';
import 'character.dart';
import 'character_swiper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Character Swiper',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CharacterSwiper(),
    );
  }
}
