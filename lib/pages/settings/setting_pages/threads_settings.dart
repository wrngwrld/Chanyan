import 'package:ce_settings/ce_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/settings_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/pages/settings/setting_pages/threads_settings_pages/grid_view_setting.dart';
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
                    icon: CupertinoIcons.exclamationmark_triangle,
                    color: CupertinoColors.systemRed,
                  ),
                  text: 'Thread View',
                  lastItem: true,
                  trailing: Text(
                    settings.getBoardView().name == 'gridView'
                        ? 'Grid View'
                        : 'List View',
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
