import 'package:flutter/material.dart';
import 'package:search_select/search_select.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search select example',
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchSelect<String>(
            items: [],
            label: '',
            selectedItems: [],
            // itemsStyleType: ItemsStyleType.text,
            // items: [
            //   "item 01",
            //   "item 02",
            //   "item 03",
            //   "item 04",
            //   "item 05",
            // ],
            // label: 'Multiple selection',
            // allowMultiple: false,
            // showDeleteButton: false,
            // selectedItems: [],
            // onChange: (values) {
            //   // change your variable list here
            // },
          ),
        ),
      ),
    );
  }
}
