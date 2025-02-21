import 'package:flutter/material.dart';

class SelectedItemWidget extends StatelessWidget {
  /// * `text` (required): The text to display inside the chip.
  final String text;

  /// * `showCloseButton`: A boolean value that determines whether to show the close button.
  ///   Defaults to `true`.
  final bool showCloseButton;

  /// * `onClose`: A callback function that is called when the close button is pressed.
  ///   If `showCloseButton` is `false`, this callback will not be called.
  final void Function()? onClose;

  /// This widget is typically used to represent a selected item in a list or a tag
  /// that can be removed by the user.
  const SelectedItemWidget({
    super.key,
    required this.text,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return RawChip(
      onDeleted: showCloseButton ? onClose?.call : null,
      deleteIcon: showCloseButton ? const Icon(Icons.close) : null,
      label: Text(text),
    );
  }
}
