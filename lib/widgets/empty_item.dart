import 'package:flutter/material.dart';

class EmptyItem extends StatelessWidget {
  /// The [title] parameter is required and specifies the text to be displayed.
  final String title;

  /// The [labelStyle] parameter is optional and allows customization of the text style.
  final TextStyle? labelStyle;

  /// The [isSmall] parameter is optional and defaults to false. When set to true,
  final bool isSmall;

  /// The [EmptyItem] widget is used to display a text item with a given title.
  /// The text style can be customized using the [labelStyle] parameter, and the
  /// size of the text can be adjusted using the [isSmall] parameter.
  const EmptyItem({
    super.key,
    required this.title,
    this.labelStyle,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: labelStyle?.copyWith(
            fontSize: labelStyle?.fontSize ?? 15 - (isSmall ? 3 : 0),
          ) ??
          TextStyle(fontSize: 15 - (isSmall ? 3 : 0)),
    );
  }
}
