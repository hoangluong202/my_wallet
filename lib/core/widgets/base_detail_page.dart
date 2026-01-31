import 'package:flutter/material.dart';

class BaseDetailPage extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Widget? footer;
  final Color backgroundColor;
  final bool resizeToAvoidBottomInset;

  const BaseDetailPage({
    super.key,
    required this.header,
    required this.body,
    required this.footer,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            header,
            Expanded(child: body),
            footer ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
