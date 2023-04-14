import 'package:flutter/cupertino.dart';

class CupertinoSettingsIcon extends StatelessWidget {
  const CupertinoSettingsIcon({
    Key? key,
    required this.icon,
    required this.color,
  }) : super(key: key);

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: color,
          ),
          width: 28,
          height: 28,
        ),
        Icon(icon, color: CupertinoColors.white, size: 21),
      ],
    );
  }
}
