import 'package:flutter/material.dart';
import 'package:search_select/search_select.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Search Select Example')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SearchSelect<String>(
                itemsStyleType: ItemsStyleType.chip,
                items: [
                  "item 01",
                  "item 02",
                  "item 03",
                  "item 04",
                  "item 05",
                ],
                label: 'Multiple selection',
                allowMultiple: true,
                selectedItems: [],
                validator: (v) {
                  if (v.isEmpty) return 'Please select at least one item';
                  return null;
                },
                onChange: (values) {
                  // change your variable list here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
