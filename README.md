# Search Select / Mult-select
### Description

This package provides a multi-select widget that allows users to search and select multiple items from a list. It is highly customizable and supports various styles and configurations to fit different use cases. The widget is designed to be user-friendly and efficient, making it easy to integrate into your Flutter applications.


### Screenshots

<p align="center">
  <img src="https://raw.githubusercontent.com/welitonsousa/search_select/refs/heads/main/screenshots/menu.png" width="32%"/>
  <img src="https://raw.githubusercontent.com/welitonsousa/search_select/refs/heads/main/screenshots/open-multiple.png" width="32%"/>
  <img src="https://raw.githubusercontent.com/welitonsousa/search_select/refs/heads/main/screenshots/open-single.png" width="32%"/>
</p>

### Example
```dart
SearchSelect<String>(
  itemsStyleType: ItemsStyleType.chip,
  items: ["item 01", "item 02", "item 03"],
  label: 'Multiple selection',
  allowMultiple: true,
  showDeleteButton: true,
  selectedItems: [],
  onChange: (values) {
    // change your variable list here
  },
),
```

### All Params
 - `items` (REQUIRED) <br> 
 A list of items to be displayed in the selection.

  - `selectedItems`
  <br>A list of items that are currently selected.

  - `label`
  <br>The label to be displayed for the selection widget.

  - `searchText`
  <br>The placeholder text to be displayed in the search field.

  - `labelStyle`
  <br>The style to be applied to the label text.

  - `decoration`
  <br>The decoration to be applied to the container of the selection widget.

  - `containerMinHeight`
  <br>The minimum height of the container.

  - `itemsStyleType`
  <br>The style type for the items in the selection.

  - `autoFocus`
  <br>Whether the search field should automatically gain focus.

  - `useMaxWidthSpace`
  <br>Whether the selection widget should use the maximum width available.

  - `showDeleteButton`
  <br>Whether to show a delete button for each selected item.

  - `allowMultiple`
  <br>Whether multiple items can be selected.

  - `everShowLabel`
  <br>Whether the label should always be shown.

  - `maxSelections`
  <br>The maximum number of selections allowed.

  - `onChange`
  <br>A callback function to be called when the selection changes.

  - `itemBuilder`
  <br>A builder function to create the widget for each item in the selection.

  - `selectedItemBuilder`
  <br>A builder function to create the widget for each selected item.

  - `onClickWhenFullItemsSelected`
  <br>A callback function to be called when `maxSelections` is reached.

  - `maxBuildItemsIList` <br>
  use this to limit the number of items to be displayed in the list if the list is too long, it will be cut off. Use null to display all items


<br>
<br>

<p align="center">
  <img src="https://github.com/welitonsousa.png" width="60" height="60" style="border-radius: 100px;"/>
</p>

<p align="center">
   Feito com ❤️ by <a target="_blank" href="https://welitonsousa.shop"><b>Weliton Sousa</b></a>
</p>