import 'package:ce_settings/ce_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/settings_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:flutter_chan/pages/settings/setting_pages/threads_settings_pages/grid_view_setting.dart';
import 'package:flutter_chan/pages/settings/setting_pages/threads_settings_pages/sort_board_settings.dart';
import 'package:provider/provider.dart';

class ThreadsSettings extends StatefulWidget {
  const ThreadsSettings({Key key}) : super(key: key);

  @override
  State<ThreadsSettings> createState() => ThreadsSettingsState();
}

class ThreadsSettingsState extends State<ThreadsSettings> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor:
          theme.getTheme() == ThemeData.light() ? Colors.white : Colors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        previousPageTitle: 'Settings',
        middle: Text(
          'Threads',
          style: TextStyle(
            color: theme.getTheme() == ThemeData.dark()
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
      child: SafeArea(
        child: CESettingsContainer(
          groups: [
            CESettingsGroup(
              items: [
                CESettingsItem(
                  leading: const CESettingsIcon(
                    icon: CupertinoIcons.viewfinder,
                    color: CupertinoColors.systemTeal,
                  ),
                  text: 'Thread View',
                  trailing: Text(
                    getBoardViewName(settings.getBoardView()),
                    style: const TextStyle(color: CupertinoColors.inactiveGray),
                  ),
                  onTap: () => {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const GridViewSettings(),
                      ),
                    ),
                  },
                ),
                CESettingsItem(
                  leading: const CESettingsIcon(
                    icon: CupertinoIcons.sort_down,
                    color: CupertinoColors.systemOrange,
                  ),
                  text: 'Default board sort',
                  lastItem: true,
                  trailing: Text(
                    getSortByName(settings.getBoardSort()),
                    style: const TextStyle(color: CupertinoColors.inactiveGray),
                  ),
                  onTap: () => {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const SortBoardSettings(),
                      ),
                    ),
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getBoardViewName(View view) {
    switch (view) {
      case View.gridView:
        return 'Grid View';
        break;
      case View.listView:
        return 'List View';
        break;
      default:
        return '';
    }
  }

  String getSortByName(Sort sort) {
    switch (sort) {
      case Sort.byImagesCount:
        return 'Images Count';
        break;
      case Sort.byBumpOrder:
        return 'Bump Order';
        break;
      case Sort.byReplyCount:
        return 'Reply Count';
        break;
      case Sort.byNewest:
        return 'Newest';
        break;
      case Sort.byOldest:
        return 'Oldest';
        break;
      default:
        return '';
    }
  }
}
