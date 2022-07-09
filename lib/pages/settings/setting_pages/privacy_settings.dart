import 'package:ce_settings/ce_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/settings_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:provider/provider.dart';

class PrivacySettings extends StatefulWidget {
  const PrivacySettings({Key key}) : super(key: key);

  @override
  State<PrivacySettings> createState() => PrivacySettingsState();
}

class PrivacySettingsState extends State<PrivacySettings> {
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
          'Privacy',
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
                  text: 'Allow NSFW-Boards',
                  trailing: CupertinoSwitch(
                    onChanged: (value) => {
                      settings.setNSFW(value),
                    },
                    value: settings.getNSFW(),
                  ),
                  showChevron: false,
                  lastItem: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
