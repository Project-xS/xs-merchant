import 'package:flutter/material.dart';

class Menupage extends StatefulWidget {
  const Menupage({super.key});

  @override
  State<Menupage> createState() => _MenupageState();
}

class _MenupageState extends State<Menupage> {
  Image icon = Image(image: AssetImage("assets/logo.png"), width: 300.00, height: 200.00);

  Map<int, String> items = {
    1: 'Chicken rice',
    2: 'Veg Fried Rice',
    3: 'Chilli Chicken',
    4: 'Rice',
    5: 'Rasam',
    6: 'Sambar',
    7: 'V Parotta',
    8: 'N Parotta',
    9: 'Noodles',
  };

  Set<int> onmenuid = {1, 2, 6, 8};
  Set<int> offmenuid = {3, 4, 5, 7, 9};

  void toggleItem(int itemId) {
    setState(() {
      if (onmenuid.contains(itemId)) {
        onmenuid.remove(itemId);
        offmenuid.add(itemId);
      } else {
        offmenuid.remove(itemId);
        onmenuid.add(itemId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildGridSection("On Menu", onmenuid, Colors.green),
            buildGridSection("Not On Menu", offmenuid, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget buildGridSection(String title, Set<int> menuSet, Color bgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menuSet.length,
          itemBuilder: (BuildContext context, int index) {
            int itemId = menuSet.elementAt(index);
            return GestureDetector(
              onTap: () => toggleItem(itemId),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    Text(
                      items[itemId] ?? "Unknown Item",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
