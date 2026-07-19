import 'package:flutter/material.dart';

Future<T> runWithLoadingDialog<T>(
  BuildContext context,
  Future<T> Function() action, {
  String message = 'Loading...',
}) async {
  var dialogShown = true;
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _LoadingDialog(message: message),
  ).then((_) => dialogShown = false);

  try {
    return await action();
  } finally {
    if (dialogShown && navigator.mounted) {
      navigator.pop();
    }
  }
}

class _LoadingDialog extends StatelessWidget {
  final String message;

  const _LoadingDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(width: 18),
            Flexible(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
