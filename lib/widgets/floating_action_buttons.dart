import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:provider/provider.dart';

class FloatingActionButtons extends StatelessWidget {
  const FloatingActionButtons({
    Key key,
    this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final ThemeChanger theme = Provider.of<ThemeChanger>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          child: const Icon(Icons.expand_less, size: 35),
          elevation: 0,
          backgroundColor: theme.getTheme() == ThemeData.dark()
              ? Platform.isIOS
                  ? CupertinoColors.black.withOpacity(0.85)
                  : AppColors.kGreen
              : Platform.isIOS
                  ? CupertinoColors.white.withOpacity(0.85)
                  : AppColors.kGreen,
          foregroundColor:
              Platform.isIOS ? CupertinoColors.activeBlue : AppColors.kWhite,
          onPressed: () {
            scrollController.animateTo(
              scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
            );
          },
          heroTag: null,
        ),
        const SizedBox(
          height: 40,
        ),
        FloatingActionButton(
          child: const Icon(Icons.expand_more, size: 35),
          elevation: 0,
          backgroundColor: theme.getTheme() == ThemeData.dark()
              ? Platform.isIOS
                  ? CupertinoColors.black.withOpacity(0.85)
                  : AppColors.kGreen
              : Platform.isIOS
                  ? CupertinoColors.white.withOpacity(0.85)
                  : AppColors.kGreen,
          foregroundColor:
              Platform.isIOS ? CupertinoColors.activeBlue : AppColors.kWhite,
          onPressed: () => {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
            )
          },
          heroTag: null,
        )
      ],
    );
  }
}
