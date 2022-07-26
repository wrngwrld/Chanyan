import 'package:ce_settings/ce_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/API/api.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:flutter_chan/pages/settings/setting_pages/privacy_settings.dart';
import 'package:flutter_chan/pages/settings/setting_pages/threads_settings.dart';
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

    return CupertinoPageScaffold(
      backgroundColor: theme.getTheme() == ThemeData.dark()
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            leading: MediaQuery(
              data: MediaQueryData(
                textScaleFactor: MediaQuery.textScaleFactorOf(context),
              ),
              child: Transform.translate(
                offset: const Offset(-16, 0),
                child: CupertinoNavigationBarBackButton(
                  previousPageTitle: 'Home',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            previousPageTitle: 'Home',
            border: Border.all(color: Colors.transparent),
            largeTitle: MediaQuery(
              data: MediaQueryData(
                textScaleFactor: MediaQuery.textScaleFactorOf(context),
              ),
              child: const Text(
                'Settings',
              ),
            ),
            backgroundColor: theme.getTheme() == ThemeData.dark()
                ? CupertinoColors.black
                : CupertinoColors.systemGroupedBackground,
          ),
          SliverToBoxAdapter(
            child: CESettingsContainer(
              groups: [
                CESettingsGroup(
                  items: [
                    CESettingsMultiline(
                      leading: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: Image.asset('assets/icons/icon.png'),
                          ),
                        ],
                      ),
                      mainText: 'Chanyan',
                      subText: 'View on GitHub',
                      mainTextFontSize: 22,
                      subTextFontSize: 16,
                      onTap: () => {
                        launchURL('https://github.com/wrngwrld/Chanyan'),
                      },
                    ),
                    CESettingsItem(
                      leading: const CESettingsIcon(
                        icon: CupertinoIcons.list_bullet,
                        color: CupertinoColors.systemPurple,
                      ),
                      text: 'Threads',
                      onTap: () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ThreadsSettings(),
                          ),
                        ),
                      },
                    ),
                    CESettingsItem(
                      leading: const CESettingsIcon(
                        icon: CupertinoIcons.hand_raised_fill,
                        color: CupertinoColors.activeGreen,
                      ),
                      text: 'Privacy',
                      lastItem: true,
                      onTap: () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PrivacySettings(),
                          ),
                        ),
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
