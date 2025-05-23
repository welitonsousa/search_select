import 'dart:async';

import 'package:flutter/material.dart';
import 'package:search_select/debounce.dart';

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

  /// The controller for the menu.
  final Color? labelBackgroundColor;

  /// The controller for the menu.
  final MenuController? menuController;

  /// A function to validate the selected items.
  final String? Function(List<T>)? validator;

  final T? selectedItem;

  /// Invoked when a single item is selected.
  /// This is used when `allowMultiple` is false.
  final Function(T?)? onSingleChange;

  /// element to be displayed when the list is empty
  final String? emptyLabel;

  /// show empty label
  /// when the list is empty
  final bool showEmptyLabel;

  /// The placeholder text to be displayed in the search field.
  final String? searchHint;

  /// A function to be called when the search field is used.
  /// Use this function to search for items asynchronously.
  /// return your new list of items
  final Future<List<T>?> Function(String q)? searchAsync;

  /// The duration to debounce the search input.
  final Duration searchAsyncDebounceDuration;

  /// A widget to be displayed while searching.
  final Widget? searchLoadingWidget;

  /// if searchAsync is null | applyLocalSearch is true
  /// if searchAsync is not null | applyLocalSearch is false
  /// use this parameter to change this behavior
  final bool applyLocalSearch;

  const SearchSelect({
    super.key,
    required this.items,
    this.selectedItems = const [],
    this.label = 'Select',
    this.onChange,
    this.itemBuilder,
    this.autoFocus = true,
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
    this.labelBackgroundColor,
    this.menuController,
    this.validator,
    this.selectedItem,
    this.onSingleChange,
    this.emptyLabel,
    this.searchHint,
    this.showEmptyLabel = true,
    this.searchAsync,
    this.searchLoadingWidget,
    this.searchAsyncDebounceDuration = const Duration(milliseconds: 500),
    bool? applyLocalSearch,
  }) : applyLocalSearch = applyLocalSearch ?? searchAsync == null;

  @override
  State<SearchSelect<T>> createState() => _SearchSelectState<T>();
}

class _SearchSelectState<T> extends State<SearchSelect<T>> {
  late final MenuController menuController;
  final searchController = TextEditingController();
  final scrollController = ScrollController();
  final selects = <T>[];
  final searchFocusNode = FocusNode();
  late final Debounce debounce =
      Debounce(duration: widget.searchAsyncDebounceDuration);
  bool loading = false;

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    searchFocusNode.removeListener(searchFocusListener);
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    menuController = widget.menuController ?? MenuController();

    selects.clear();
    if (widget.selectedItem != null) {
      selects.add(widget.selectedItem as T);
    }
    selects.addAll(widget.selectedItems);
    searchFocusNode.addListener(searchFocusListener);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant SearchSelect<T> oldWidget) {
    selects.clear();
    if (widget.selectedItem != null) {
      selects.add(widget.selectedItem as T);
    }
    selects.addAll(widget.selectedItems);
    setState(() {});
    super.didUpdateWidget(oldWidget);
  }

  void searchFocusListener() {
    setState(() {});
    Timer.periodic(Duration(milliseconds: 10), (t) {
      setState(() {});
      if (!searchFocusNode.hasFocus) t.cancel();
      if (t.tick > 60) {
        t.cancel();
      }
    });
  }

  void runGetAsyncItems(String q) {
    if (widget.searchAsync == null) return;
    if (loading) return;
    loading = true;
    debounce(() async {
      final res = await widget.searchAsync!(q);
      widget.items.clear();
      if (res != null) {
        widget.items.addAll(res);
      }
      loading = false;
      setState(() {});
    });
  }

  List<T> get filteredItems {
    if (!widget.applyLocalSearch) return widget.items;
    final search = searchController.text.toLowerCase();
    final res = widget.items
        .where((element) => element.toString().toLowerCase().contains(search))
        .toList();
    if (widget.maxBuildItemsIList == null) return res;
    final isCutOff = res.length > widget.maxBuildItemsIList!;

    if (!isCutOff) return res;
    return res.sublist(0, widget.maxBuildItemsIList!);
  }

  void tapItem(T item, FormFieldState? state) {
    if (widget.maxSelections == selects.length) {
      widget.onClickWhenFullItemsSelected?.call();
    } else {
      if (!widget.allowMultiple) {
        menuController.close();
        selects.clear();
      }

      final isSelected = selects.contains(item);
      if (isSelected) selects.remove(item);
      if (!isSelected) selects.add(item);

      if (widget.maxSelections == selects.length) menuController.close();
    }
    widget.onChange?.call(selects);
    selectSingleItem();
    state?.validate();
    setState(() {});
  }

  void selectSingleItem() {
    if (widget.onSingleChange != null && !widget.allowMultiple) {
      widget.onSingleChange!(selects.isNotEmpty ? selects.first : null);
    }
  }

  bool get isDialog {
    return ModalRoute.of(context) is DialogRoute;
  }

  Color getBackgroundColor(BuildContext c) {
    if (widget.labelBackgroundColor != null) {
      return widget.labelBackgroundColor!;
    }
    if (isDialog) return getEffectiveDialogColor(c);

    return Theme.of(c).scaffoldBackgroundColor;
  }

  Color getEffectiveDialogColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final useM3 = theme.useMaterial3;
    // Obtém a cor base do Dialog
    Color baseColor = theme.colorScheme.surface; // Para Material 3
    if (!theme.useMaterial3) {
      baseColor = theme.dialogBackgroundColor; // Para Material 2
    }

    if (useM3 && isDarkMode) {
      return theme.colorScheme.surfaceContainerHigh;
    } else if (useM3 && !isDarkMode) {
      return ElevationOverlay.applySurfaceTint(
          baseColor, theme.colorScheme.surfaceTint, 4.0);
    }

    return baseColor;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<T>>(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (v) {
          if (widget.validator == null) return null;
          return widget.validator!(selects);
        },
        builder: (state) {
          return LayoutBuilder(
            builder: (context, constrains) => MenuAnchor(
              controller: menuController,
              style: MenuStyle(
                elevation: WidgetStateProperty.all(100),
                maximumSize: WidgetStateProperty.all(Size(
                  constrains.maxWidth,
                  widget.maxHeight ??
                      (MediaQuery.of(context).size.height * 0.4),
                )),
              ),
              onClose: () {
                searchController.clear();
                widget.onChange?.call(selects);
              },
              menuChildren: [
                TextField(
                  autocorrect: false,
                  focusNode: searchFocusNode,
                  autofocus: widget.autoFocus,
                  controller: searchController,
                  onChanged: (value) {
                    runGetAsyncItems(value);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: widget.searchHint ?? 'Pesquisar',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                if (loading)
                  Container(
                    constraints: BoxConstraints(
                      minWidth: widget.useMaxWidthSpace
                          ? MediaQuery.of(context).size.width
                          : 0,
                    ),
                    child: widget.searchLoadingWidget ??
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                  )
                else
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
                          children: [
                            ...filteredItems.map((item) {
                              final checked = selects.contains(item);
                              return GestureDetector(
                                onTap: () => tapItem(item, state),
                                child: Column(
                                  children: [
                                    if (widget.itemBuilder != null)
                                      widget.itemBuilder!.call(item, checked)
                                    else if (!widget.allowMultiple)
                                      ListTile(
                                        title: Text(item.toString()),
                                        selected: checked,
                                        onTap: () => tapItem(item, state),
                                      )
                                    else
                                      ListTile(
                                        title: Text(item.toString()),
                                        onTap: () => tapItem(item, state),
                                        selected: checked,
                                        leading: checked
                                            ? Icon(Icons.check_box)
                                            : Icon(
                                                Icons.check_box_outline_blank),
                                      ),
                                  ],
                                ),
                              );
                            }),
                            if (filteredItems.isEmpty && widget.showEmptyLabel)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    widget.emptyLabel ??
                                        'Nenhum item encontrado',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ),
                              ),
                            if (filteredItems.isNotEmpty) SizedBox(height: 60),
                          ],
                        ),
                      )),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (menuController.isOpen) {
                        menuController.close();
                      } else {
                        menuController.open();
                      }
                    },
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        selects.join(', '),
                                        style: widget.labelStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  if (widget.itemsStyleType ==
                                      ItemsStyleType.text)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(selects.join(', '),
                                          style: widget.labelStyle),
                                    ),
                                  if (widget.itemsStyleType ==
                                      ItemsStyleType.chip)
                                    Wrap(
                                      runSpacing: 5,
                                      spacing: 5,
                                      children: [
                                        ...selects.map((e) {
                                          if (widget.selectedItemBuilder !=
                                              null) {
                                            return widget.selectedItemBuilder!
                                                .call(e);
                                          }
                                          return RawChip(
                                            onDeleted: widget.showDeleteButton
                                                ? () {
                                                    selects.remove(e);
                                                    widget.onChange
                                                        ?.call(selects);
                                                    selectSingleItem();
                                                    state.validate();
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
                                color: getBackgroundColor(context),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  widget.label,
                                  style: widget.labelStyle?.copyWith(
                                        fontSize: widget.labelStyle?.fontSize ??
                                            15 - (selects.isNotEmpty ? 3 : 0),
                                      ) ??
                                      TextStyle(
                                        fontSize:
                                            15 - (selects.isNotEmpty ? 3 : 0),
                                      ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (state.hasError)
                    Text(state.errorText ?? 'asd',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        )),
                ],
              ),
            ),
          );
        });
  }
}
