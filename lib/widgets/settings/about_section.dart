import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  final VoidCallback onAboutTap;

  const AboutSection({super.key, required this.onAboutTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(
          leading: Icon(Icons.info),
          title: Text('Version'),
          subtitle: Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('About SUB-GUARD'),
          subtitle: const Text('Subscription tracking and reminder app'),
          onTap: onAboutTap,
        ),
      ],
    );
  }
}
