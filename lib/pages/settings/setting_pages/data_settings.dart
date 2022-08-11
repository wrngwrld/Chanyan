import 'dart:io';
import 'package:ce_settings/ce_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chan/blocs/settings_model.dart';
import 'package:flutter_chan/blocs/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class DataSettings extends StatefulWidget {
  const DataSettings({Key key}) : super(key: key);

  @override
  State<DataSettings> createState() => DataSettingsState();
}

class DataSettingsState extends State<DataSettings> {
  double _cacheSize = 0.0;

  Future<void> getCacheSize() async {
    Directory directory;

    try {
      directory = await getTemporaryDirectory();

      final List<FileSystemEntity> entities = await directory.list().toList();
      for (final entity in entities) {
        if (entity is File) {
          setState(() {
            _cacheSize += getFileSize(entity);
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  double getFileSize(File file) {
    final int sizeInBytes = file.lengthSync();
    final double sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb;
  }

  Future<void> deleteCache() async {
    Directory directory;

    try {
      directory = await getTemporaryDirectory();

      final List<FileSystemEntity> entities = await directory.list().toList();
      for (final entity in entities) {
        if (entity is File) {
          print(entity.path);
          await entity.delete();
        }
      }

      setState(() {
        _cacheSize = 0;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    getCacheSize();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

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
        leading: MediaQuery(
          data: MediaQueryData(
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          child: Transform.translate(
            offset: const Offset(-16, 0),
            child: CupertinoNavigationBarBackButton(
              previousPageTitle: 'Settings',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        border: Border.all(color: Colors.transparent),
        previousPageTitle: 'Settings',
        middle: MediaQuery(
          data: MediaQueryData(
            textScaleFactor: MediaQuery.textScaleFactorOf(context),
          ),
          child: Text(
            'Data',
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
                  text: 'Cache Size',
                  trailing: Text('${_cacheSize.toStringAsFixed(2)} MB'),
                  showChevron: false,
                ),
                CESettingsItem(
                  text: 'Delete Cache',
                  lastItem: true,
                  showChevron: true,
                  onTap: () => deleteCache(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
