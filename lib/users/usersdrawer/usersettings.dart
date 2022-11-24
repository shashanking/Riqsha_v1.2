import 'package:flutter/material.dart';
import 'package:last_mile_v2/classes/language.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:last_mile_v2/main.dart';

class UserSettings extends StatefulWidget {
  UserSettings({Key key}) : super(key: key);
  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'SETTINGS')),
      ),
      body: Container(
        child: Center(
          child: DropdownButton<Language>(
            iconSize: 30,
            hint: Text(getTranslated(context, 'change_language')),
            onChanged: (Language language) {
              _changeLanguage(language);
            },
            items: Language.languageList()
                .map<DropdownMenuItem<Language>>(
                  (e) => DropdownMenuItem<Language>(
                    value: e,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          e.flag,
                          style: TextStyle(fontSize: 30),
                        ),
                        Text(e.name)
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
