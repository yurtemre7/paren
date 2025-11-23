import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Paren paren = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [buildAppInfo(), buildFeedback(), Divider()]),
    );
  }

  Widget buildFeedback() {
    return Container(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          ListTile(
            title: const Text('Share the App'),
            subtitle: const Text(
              'With your help the app can help more people on their vacations! I appreciate your effort.',
            ),
            trailing: IconButton(
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text:
                        'With Par円 you can convert money in your travels faster than ever!\nDownload here: https://apps.apple.com/us/app/paren/id6578395712',
                  ),
                );
              },
              icon: const Icon(Icons.share_outlined),
              color: context.theme.colorScheme.primary,
            ),
          ),
          const ListTile(
            title: Text('Contact / Feedback'),
            subtitle: Text(
              'Feel free to reach out to me, as I take any request seriously and see it as an opportunity to improve my app.',
            ),
          ),
          ListTile(
            title: Text('Licenses'),
            subtitle: Text(
              'This app uses the following open source libraries.',
            ),
            trailing: Icon(Icons.open_in_new),
            onTap: () async {
              await Navigator.of(context).push(
                StupidSimpleCupertinoSheetRoute(
                  child: LicensePage(
                    applicationName: 'Par円',
                    applicationIcon: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset('assets/icon/icon.png', height: 64),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.only(right: 8),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                ActionChip.elevated(
                  label: const Text('GitHub'),
                  onPressed: () {
                    launchUrl(Uri.parse('https://github.com/yurtemre7/paren'));
                  },
                ),
                4.w,
                ActionChip.elevated(
                  label: const Text('E-Mail'),
                  onPressed: () {
                    launchUrl(Uri.parse('mailto:yurtemre7@icloud.com'));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAppInfo() {
    return ListTile(
      trailing: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset('assets/icon/icon.png'),
      ),
      title: const Text('App Info'),
      subtitle: const Text('Thank you for being here.'),
      onLongPress: () {
        Get.dialog(
          AlertDialog(
            title: const Text('Delete App Data'),
            content: const Text(
              'Are you sure, you want to delete all the app data?\n\nThis contains the data of the offline currency values, your default currency selection and the autofocus status.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Abort'),
              ),
              OutlinedButton(
                onPressed: () async {
                  await paren.reset();
                  await paren.fetchCurrencyDataOnline();
                  Get.back();
                  Get.back();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }
}
