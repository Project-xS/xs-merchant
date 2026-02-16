import 'package:flutter/material.dart';

/// Shared button style used across menu and order verification dialogs.
/// Returns a styled [ButtonStyle] for action buttons with hover effects.
ButtonStyle getActionButtonStyle(
  BuildContext context,
  bool isPrimary, {
  bool isYellow = false,
}) {
  final theme = Theme.of(context);
  Color bgColor;
  if (isYellow) {
    bgColor = Colors.yellowAccent;
  } else if (isPrimary) {
    bgColor = theme.colorScheme.primary;
  } else {
    bgColor = theme.colorScheme.error;
  }

  return ElevatedButton.styleFrom(
    backgroundColor: bgColor,
    foregroundColor: Colors.black,
    elevation: 4,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
    shape: const StadiumBorder(),
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.hovered)) {
        return bgColor.withAlpha(40);
      }
      return null;
    }),
    backgroundColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.hovered)) {
        return Colors.black;
      }
      return bgColor;
    }),
    foregroundColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.hovered)) {
        return bgColor;
      }
      return Colors.black;
    }),
  );
}
