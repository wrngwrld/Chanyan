import 'package:ce_settings/ce_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/settings_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/enums/enums.dart';
import 'package:provider/provider.dart';

class SortBoardSettings extends StatefulWidget {
  const SortBoardSettings({Key key}) : super(key: key);

  @override
  State<SortBoardSettings> createState() => SortBoardSettingsState();
}

class SortBoardSettingsState extends State<SortBoardSettings> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    final settings = Provider.of<SettingsProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.getTheme() == ThemeData.dark()
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.getTheme() == ThemeData.light()
            ? CupertinoColors.systemGroupedBackground.withOpacity(0.7)
            : CupertinoColors.black.withOpacity(0.7),
        brightness: theme.getTheme() == ThemeData.dark()
            ? Brightness.dark
            : Brightness.light,
        border: Border.all(color: Colors.transparent),
        leading: MediaQuery(
          data: MediaQueryData(
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          child: Transform.translate(
            offset: const Offset(-16, 0),
            child: CupertinoNavigationBarBackButton(
              previousPageTitle: 'Threads',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        middle: MediaQuery(
          data: MediaQueryData(
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          child: Text(
            'Default board sort',
            style: TextStyle(
              color: theme.getTheme() == ThemeData.dark()
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: CESettingsContainer(
          groups: [
            CESettingsGroup(
              items: [
                CESettingsItem(
                  text: 'Images Count',
                  showChevron: false,
                  trailing: settings.getBoardSort().name == 'byImagesCount'
                      ? const Icon(
                          CupertinoIcons.check_mark,
                        )
                      : Container(),
                  onTap: () => {settings.setBoardSort(Sort.byImagesCount)},
                ),
                CESettingsItem(
                  text: 'Bump Order',
                  showChevron: false,
                  trailing: settings.getBoardSort().name == 'byBumpOrder'
                      ? const Icon(
                          CupertinoIcons.check_mark,
                        )
                      : Container(),
                  onTap: () => {settings.setBoardSort(Sort.byBumpOrder)},
                ),
                CESettingsItem(
                  text: 'Reply Count',
                  showChevron: false,
                  trailing: settings.getBoardSort().name == 'byReplyCount'
                      ? const Icon(
                          CupertinoIcons.check_mark,
                        )
                      : Container(),
                  onTap: () => {settings.setBoardSort(Sort.byReplyCount)},
                ),
                CESettingsItem(
                  text: 'Newest',
                  showChevron: false,
                  trailing: settings.getBoardSort().name == 'byNewest'
                      ? const Icon(
                          CupertinoIcons.check_mark,
                        )
                      : Container(),
                  onTap: () => {settings.setBoardSort(Sort.byNewest)},
                ),
                CESettingsItem(
                  text: 'Oldest',
                  lastItem: true,
                  showChevron: false,
                  trailing: settings.getBoardSort().name == 'byOldest'
                      ? const Icon(
                          CupertinoIcons.check_mark,
                        )
                      : Container(),
                  onTap: () => {settings.setBoardSort(Sort.byOldest)},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
