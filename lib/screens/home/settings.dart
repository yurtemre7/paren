import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:paren/l10n/app_localizations_extension.dart';
import 'package:paren/providers/extensions.dart';
import 'package:paren/providers/paren.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

@Preview()
Widget HomePreview() {
  Get.put(Paren()).initSettings();
  return Settings();
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [buildAppInfo(context), buildFeedback(context), Divider()],
      ),
    );
  }

  Widget buildFeedback(BuildContext context) {
    var l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(l10n.shareTheApp),
            subtitle: Text(l10n.shareAppSubtitle),
            trailing: FaIcon(
              FontAwesomeIcons.shareFromSquare,
              color: context.theme.colorScheme.primary,
            ),
            onTap: () {
              SharePlus.instance.share(ShareParams(text: l10n.shareAppText));
            },
          ),
          ListTile(
            title: Text(l10n.contactFeedback),
            subtitle: Text(l10n.contactFeedbackSubtitle),
          ),
          ListTile(
            title: Text(l10n.licenses),
            subtitle: Text(l10n.licensesSubtitle),
            // trailing: Icon(Icons.open_in_new),
            trailing: FaIcon(
              FontAwesomeIcons.copyright,
              color: context.theme.colorScheme.primary,
            ),
            onTap: () async {
              await Navigator.of(context).push(
                StupidSimpleSheetRoute(
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
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                ActionChip.elevated(
                  label: Text(l10n.github),
                  onPressed: () {
                    launchUrl(Uri.parse('https://github.com/yurtemre7/paren'));
                  },
                ),
                4.w,
                ActionChip.elevated(
                  label: Text(l10n.email),
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

  Widget buildAppInfo(BuildContext context) {
    var l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        trailing: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset('assets/icon/icon.png'),
        ),
        title: Text(l10n.appInfo),
        subtitle: Text(l10n.thankYouForBeingHere),
        onLongPress: () {
          Get.dialog(
            AlertDialog(
              title: Text(l10n.deleteAppData),
              content: Text(l10n.deleteAppDataContent),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(l10n.abort),
                ),
                OutlinedButton(
                  onPressed: () async {
                    Paren paren = Get.find();
                    await paren.reset();
                    await paren.fetchCurrencyDataOnline();
                    Get.back();
                    Get.back();
                  },
                  child: Text(l10n.delete),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
