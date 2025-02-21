import 'package:flutter/material.dart';

enum ItemsStyleType {
  text,
  textEllipsis,
  chip,
}

/// Example usage:
/// ```dart
/// SearchSelect<MyTypeModel>(
///   label: 'Click Me',
///   items: [],
///   selectedItems: [],
///   onChange: () {
///     print('Button pressed');
///   },
/// )
/// ```
class SearchSelect<T> extends StatefulWidget {
  /// A list of items to be displayed in the selection.
  final List<T> items;

  /// A list of items that are currently selected.
  final List<T> selectedItems;

  /// The label to be displayed for the selection widget.
  final String label;

  /// The placeholder text to be displayed in the search field.
  final String? searchText;

  /// The style to be applied to the label text.
  final TextStyle? labelStyle;

  /// The decoration to be applied to the container of the selection widget.
  final BoxDecoration? decoration;

  /// The minimum height of the container.
  final double containerMinHeight;

  /// The style type for the items in the selection.
  final ItemsStyleType itemsStyleType;

  /// Whether the search field should automatically gain focus.
  final bool autoFocus;

  /// Whether the selection widget should use the maximum width available.
  final bool useMaxWidthSpace;

  /// Whether to show a delete button for each selected item.
  final bool showDeleteButton;

  /// Whether multiple items can be selected.
  final bool allowMultiple;

  /// Whether the label should always be shown.
  final bool everShowLabel;

  /// The maximum number of selections allowed.
  final int? maxSelections;

  /// A callback function to be called when the selection changes.
  final void Function(List<T>)? onChange;

  /// A builder function to create the widget for each item in the selection.
  final Widget Function(T item, bool checked)? itemBuilder;

  /// A builder function to create the widget for each selected item.
  final Widget Function(T item)? selectedItemBuilder;

  /// Callback function to be called when `maxSelections` is reached.
  final void Function()? onClickWhenFullItemsSelected;

  /// use this to limit the number of items to be displayed
  /// in the list if the list is too long,
  /// it will be cut off. Use null to display all items
  final int? maxBuildItemsIList;

  /// The maximum height size of the selection menu.
  final double? maxHeight;

  const SearchSelect({
    super.key,
    required this.items,
    this.selectedItems = const [],
    this.label = 'Select',
    this.searchText,
    this.onChange,
    this.itemBuilder,
    this.autoFocus = false,
    this.decoration,
    this.useMaxWidthSpace = true,
    this.labelStyle,
    this.selectedItemBuilder,
    this.showDeleteButton = true,
    this.everShowLabel = true,
    this.allowMultiple = true,
    this.containerMinHeight = 50,
    this.maxSelections,
    this.onClickWhenFullItemsSelected,
    this.maxBuildItemsIList,
    this.maxHeight,
    this.itemsStyleType = ItemsStyleType.chip,
  });

  @override
  State<SearchSelect<T>> createState() => _SearchSelectState<T>();
}

class _SearchSelectState<T> extends State<SearchSelect<T>> {
  final menuController = MenuController();
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  final selects = <T>[];

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    selects.clear();
    selects.addAll(widget.selectedItems);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SearchSelect<T> oldWidget) {
    selects.clear();
    selects.addAll(widget.selectedItems);
    setState(() {});
    super.didUpdateWidget(oldWidget);
  }

  List<T> get filteredItems {
    final search = searchController.text.toLowerCase();
    final res = widget.items
        .where((element) => element.toString().toLowerCase().contains(search))
        .toList();
    if (widget.maxBuildItemsIList == null) return res;
    final isCutOff = res.length > widget.maxBuildItemsIList!;

    if (!isCutOff) return res;
    return res.sublist(0, widget.maxBuildItemsIList!);
  }

  void tapItem(T item) {
    if (widget.maxSelections == selects.length) {
      return widget.onClickWhenFullItemsSelected?.call();
    }

    if (!widget.allowMultiple) {
      menuController.close();
      selects.clear();
    }

    final isSelected = selects.contains(item);
    if (isSelected) selects.remove(item);
    if (!isSelected) selects.add(item);

    if (widget.maxSelections == selects.length) menuController.close();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) => MenuAnchor(
        controller: menuController,
        style: MenuStyle(
          elevation: WidgetStateProperty.all(100),
          maximumSize: WidgetStateProperty.all(Size(
            constrains.maxWidth,
            widget.maxHeight ?? (MediaQuery.of(context).size.height * 0.4),
          )),
        ),
        onClose: () {
          searchController.clear();
          widget.onChange?.call(selects);
        },
        menuChildren: [
          TextField(
            autocorrect: false,
            autofocus: widget.autoFocus,
            controller: searchController,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: widget.searchText,
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
                minWidth: widget.useMaxWidthSpace
                    ? MediaQuery.of(context).size.width
                    : 0,
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: filteredItems.map((item) {
                    final checked = selects.contains(item);
                    return GestureDetector(
                      child: Column(
                        children: [
                          if (widget.itemBuilder != null)
                            widget.itemBuilder!.call(item, checked)
                          else if (!widget.allowMultiple)
                            ListTile(
                              title: Text(item.toString()),
                              selected: checked,
                              onTap: () => tapItem(item),
                            )
                          else
                            ListTile(
                              title: Text(item.toString()),
                              onTap: () => tapItem(item),
                              selected: checked,
                              leading: checked
                                  ? Icon(Icons.check_box)
                                  : Icon(Icons.check_box_outline_blank),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )),
        ],
        child: GestureDetector(
          onTap: menuController.open,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                    constraints: BoxConstraints(
                      minHeight: widget.containerMinHeight,
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                    decoration: widget.decoration ??
                        BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                    padding: EdgeInsets.only(
                      left: 4,
                      right: 4,
                      top: widget.everShowLabel ? 10 : 4,
                      bottom: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.itemsStyleType ==
                            ItemsStyleType.textEllipsis)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              selects.join(', '),
                              style: widget.labelStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (widget.itemsStyleType == ItemsStyleType.text)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(selects.join(', '),
                                style: widget.labelStyle),
                          ),
                        if (widget.itemsStyleType == ItemsStyleType.chip)
                          Wrap(
                            runSpacing: 5,
                            spacing: 5,
                            children: [
                              ...selects.map((e) {
                                if (widget.selectedItemBuilder != null) {
                                  return widget.selectedItemBuilder!.call(e);
                                }
                                return RawChip(
                                  onDeleted: widget.showDeleteButton
                                      ? () {
                                          selects.remove(e);
                                          widget.onChange?.call(selects);
                                          setState(() {});
                                        }
                                      : null,
                                  deleteIcon: widget.showDeleteButton
                                      ? const Icon(Icons.close)
                                      : null,
                                  label: Text(e.toString()),
                                );
                              })
                            ],
                          ),
                      ],
                    )),
              ),
              if (widget.everShowLabel || selects.isEmpty)
                AnimatedPositioned(
                  duration: Duration(milliseconds: 100),
                  top: selects.isEmpty
                      ? (widget.containerMinHeight / 2) - 6
                      : -3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        widget.label,
                        style: widget.labelStyle?.copyWith(
                              fontSize: widget.labelStyle?.fontSize ??
                                  15 - (selects.isNotEmpty ? 3 : 0),
                            ) ??
                            TextStyle(
                              fontSize: 15 - (selects.isNotEmpty ? 3 : 0),
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
