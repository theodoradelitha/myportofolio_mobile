import 'package:material_ui/material_ui.dart';

/// Shows the values that were just saved from a form in an [AlertDialog].
///
/// The returned Future completes when the dialog closes, either through OK
/// or by tapping outside it, so the caller can `await` it before resetting
/// its form.
Future<void> showSummaryDialog(
  BuildContext context, {
  required String title,
  required List<SummaryRow> rows,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      // Long descriptions scroll inside the dialog instead of overflowing.
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: rows,
        ),
      ),
      actions: [
        TextButton(
          // Pop with the dialog's own context so only the dialog closes and
          // the form page underneath stays open.
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// One "Label: value" line in a summary dialog.
class SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const SummaryRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
