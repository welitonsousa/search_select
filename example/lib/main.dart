import 'package:search_select/search_select.dart';

void main() {
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
    showDeleteButton: false,
    selectedItems: [],
    onChange: (values) {
      // change your variable list here
    },
  );
}
