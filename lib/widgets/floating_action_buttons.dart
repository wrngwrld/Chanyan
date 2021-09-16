import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chan/constants.dart';

class FloatingActionButtons extends StatelessWidget {
  const FloatingActionButtons({
    this.scrollController,
  });

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          child: Icon(
            Icons.expand_less,
            size: 35,
          ),
          backgroundColor: Platform.isIOS ? AppColors.kWhite : AppColors.kGreen,
          foregroundColor: Platform.isIOS ? Colors.grey : AppColors.kWhite,
          onPressed: () {
            scrollController.animateTo(
              scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
            );
          },
          heroTag: null,
        ),
        SizedBox(
          height: 40,
        ),
        FloatingActionButton(
          child: Icon(Icons.expand_more, size: 35),
          backgroundColor: Platform.isIOS ? AppColors.kWhite : AppColors.kGreen,
          foregroundColor: Platform.isIOS ? Colors.grey : AppColors.kWhite,
          onPressed: () => {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
            )
          },
          heroTag: null,
        )
      ],
    );
  }
}
