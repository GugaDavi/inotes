import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CopyButton extends StatefulWidget {
  const CopyButton({super.key, required this.text, this.size = 16});

  final String text;
  final double size;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size(widget.size + 8, widget.size + 8),
      onPressed: _copy,
      child: Icon(
        _copied ? CupertinoIcons.checkmark_circle : CupertinoIcons.doc_on_doc,
        size: widget.size,
        color: _copied
            ? CupertinoColors.systemGreen.resolveFrom(context)
            : CupertinoColors.secondaryLabel.resolveFrom(context),
      ),
    );
  }
}
