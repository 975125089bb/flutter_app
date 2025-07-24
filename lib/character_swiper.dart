import 'package:flutter/material.dart';
import 'character.dart';
import 'characters_data.dart';

class CharacterSwiper extends StatefulWidget {
  const CharacterSwiper({super.key});

  @override
  State<CharacterSwiper> createState() => _CharacterSwiperState();
}

class _CharacterSwiperState extends State<CharacterSwiper> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _addCharacter() {
    setState(() {
      characters.add(
        Character(
          id: "id",
          name: "name",
          description: "description",
          imageUrl: "imageUrl",
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date app'),
        backgroundColor: Colors.green,
        // actions: <Widget>[
        //   Padding(
        //     padding: const EdgeInsets.all(3.0),
        //     child: Text(
        //       "Page" + {_curr + 1}.toString() + "/" + _list.length.toString(),
        //       textScaleFactor: 2,
        //     ),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // index

          // // Swipeable area
          // Expanded(
          //   child: PageView.builder(
          //     controller: _pageController,
          //     itemCount: characters.length,
          //     onPageChanged: (index) {
          //       setState(() => _currentIndex = index);
          //     },
          //     itemBuilder: (context, index) {
          //       final character = characters[index];
          //       return CharacterCard(character: character);
          //     },
          //   ),
          // ),

          // save bottom

          // Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              characters.length,
              (i) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == i ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  final Character character;

  const CharacterCard({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image.network(character.imageUrl, height: 200),
            // const SizedBox(height: 16),
            Text(
              character.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(character.description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
