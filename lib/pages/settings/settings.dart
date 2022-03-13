import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/settings_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/constants.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          if (Platform.isIOS)
            CupertinoSliverNavigationBar(
              border: Border.all(color: Colors.transparent),
              largeTitle: const Text(
                'Settings',
              ),
              backgroundColor: theme.getTheme() == ThemeData.dark()
                  ? CupertinoColors.black.withOpacity(0.8)
                  : CupertinoColors.white.withOpacity(0.8),
            )
          else
            const SliverAppBar(
              backgroundColor: AppColors.kGreen,
              foregroundColor: AppColors.kWhite,
              title: Text(
                'Settings',
              ),
              pinned: true,
            ),
          CupertinoSliverRefreshControl(
            onRefresh: () {
              return Future.delayed(const Duration(seconds: 1))
                ..then((_) {
                  if (mounted) {}
                });
            },
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  title: Text(
                    'Allow NSFW-Boards',
                    style: TextStyle(
                      color: theme.getTheme() == ThemeData.dark()
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  trailing: CupertinoSwitch(
                    onChanged: (value) => {
                      settings.setNSFW(value),
                    },
                    value: settings.getNSFW(),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
