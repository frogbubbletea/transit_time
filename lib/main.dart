import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:xml2json/xml2json.dart';
import 'package:dio/dio.dart';
import 'package:chaleno/chaleno.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

Dio dio = Dio();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int langCode = prefs.getInt('lang') ?? 0;
  timeago.setLocaleMessages('zh', timeago.ZhMessages());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int langCode = 0;

  Future<void> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    langCode = prefs.getInt('lang') ?? 0;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

  ColorScheme _generateColorScheme(ColorScheme? colorScheme, Brightness brightness) {
    if (colorScheme == null) {
      return ColorScheme.fromSwatch(
        primarySwatch: Colors.blue, 
        brightness: brightness,
      );
    } else {
      return ColorScheme.fromSeed(
        seedColor: colorScheme.primary,
        brightness: brightness,
      ).harmonized();
    }
  }

  void setLangCode(int value) {
    setState(() {
      langCode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'Transit Time',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),  // English
            Locale.fromSubtags(
              languageCode: 'zh', 
              scriptCode: 'Hant', 
              countryCode: 'HK'
            ),  // Chinese (Traditional)
          ],
          locale: const [null, Locale('en'), Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK')][langCode] ?? WidgetsBinding.instance.platformDispatcher.locale,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: _generateColorScheme(lightColorScheme, Brightness.light),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: _generateColorScheme(darkColorScheme, Brightness.dark),
          ),
          home: MyHomePage(),
        ),
      );
    });
  }
}

class MyAppState extends ChangeNotifier {

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  // Callback to set state from child pages
  callback(newValue) {
    setState(() {
      selectedIndex = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = NearbyPage();
        break;
      case 1:
        page = SavedPage();
        break;
      case 2:
        page = ExplorePage();
        break;
      case 3:
        page = NoticesPage();
        break;
      case 4:
        page = ToolsPage();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex.');
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: page,
              )
            ),
            NavigationBar(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.location_on),
                  label: AppLocalizations.of(context)!.nearby,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bookmark),
                  label: AppLocalizations.of(context)!.saved,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.explore),
                  label: AppLocalizations.of(context)!.explore,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.notifications),
                  label: AppLocalizations.of(context)!.notices,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.widgets),
                  label: AppLocalizations.of(context)!.tools,
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            )
          ]
        ),
      )
    );
  }
}

class NearbyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(
              Icons.location_on,
              size: 80.0,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            'Transit services nearby will be shown here!',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          )
        ],
      )
    );
  }
}

class SavedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(
              Icons.bookmark,
              size: 80.0,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            'Saved items will be shown here!',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          )
        ],
      )
    );
  }
}

class ExplorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(
              Icons.explore,
              size: 80.0,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            'All services will be shown here!',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          )
        ],
      )
    );
  }
}

class NoticesPage extends StatefulWidget {
  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {
  // Traffic notices URLs
  final tdUrl = 'https://www.td.gov.hk/en/special_news/trafficnews.xml';  // V2
  // final tdUrl = 'https://resource.data.one.gov.hk/td/en/specialtrafficnews.xml';  // V1
  final tdSourceUrl = 'https://data.gov.hk/tc-data/dataset/hk-td-tis_19-special-traffic-news-v2';
  final rthkUrl = 'https://programme.rthk.hk/channel/radio/trafficnews/index.php';

  // Downloaded traffic notice cards
  Future<List<Widget>>? noticeCards;

  @override
  void initState() {
    noticeCards = fetchNotices();
    super.initState();
  }

  // Fetch notices
  Future<List<Widget>> fetchNotices() async {
    List<Widget> noticeCards = [];

    // Fetch from TD
    Response response = await dio.get(tdUrl);

    // Get locale of notice content
    String tdNewsSource = '';
    String tdNewsLocale = '';
    if (context.mounted) {
      tdNewsSource = AppLocalizations.of(context)!.td;
      tdNewsLocale = AppLocalizations.of(context)!.tdNewsLocale;
    }

    if (response.statusCode == 200) {
      final Xml2Json transformer = Xml2Json();
      transformer.parse(response.data);
      final responseJson = transformer.toGData();
      final data = jsonDecode(responseJson);

      var notices = data['list']['message'];  // V2
      // final notices = data['body']['message'];  // V1
      if (notices is! List) {
        notices = [notices];
      }

      noticeCards = notices.map(
        (f) => NoticeCard(
          source: tdNewsSource,
          location: '${f['LOCATION_$tdNewsLocale']['\$t']} ${f['DIRECTION_$tdNewsLocale']['\$t'] != null ? '${AppLocalizations.of(context)!.to} ${f['DIRECTION_$tdNewsLocale']['\$t']}': ''}${f['NEAR_LANDMARK_$tdNewsLocale']['\$t'] != null ? ', ${AppLocalizations.of(context)!.near} ${f['NEAR_LANDMARK_$tdNewsLocale']['\$t']}' : ''}',
          heading: '${f['INCIDENT_HEADING_$tdNewsLocale']['\$t']}: ${f['INCIDENT_DETAIL_$tdNewsLocale']['\$t']}\n',
          date: f['ANNOUNCEMENT_DATE']['\$t'],
          content: f['CONTENT_$tdNewsLocale']['\$t'],
        )
      ).toList();

    } else {
      throw UnimplementedError('No widget for other response codes!');
    }
    
    // Fetch from RTHK Traffic News
    var parser = await Chaleno().load(rthkUrl);

    List<Result>? results = parser?.getElementsByClassName('inner');
    // print(results?[15].text);

    for (final Result r in results ?? []) {
      var rText = r.text ?? '';
      rText = utf8.decode(rText.runes.toList());

      // Text before first comma/colon usually contains notice location
      late final int? firstDelimiter;
      try {
        firstDelimiter = [rText.indexOf('，'), rText.indexOf('：'), rText.indexOf('。')].where((i) => i != -1).reduce(min);
      } catch (e) {
        firstDelimiter = rText.indexOf('\t\t\t');
      }
      final String location = rText.substring(0, firstDelimiter);

      // Extract time of notice
      final dateDelimiter = rText.indexOf('\t\t\t');
      final date = rText.substring(dateDelimiter + 3)
        .replaceAll('\n\t\t\t', '')
        .replaceAll('HKT ', '')
        .replaceFirst('\t', '');

      // Extract notice content
      final content = rText.substring(0, dateDelimiter).replaceFirst('\t', '');

      // Check if context is mounted
      String rthkSource = 'RTHK';
      if (context.mounted) {
        rthkSource = AppLocalizations.of(context)!.rthk;
      }

      noticeCards.add(
        NoticeCard(
          source: rthkSource,
          location: location,
          heading: '',
          date: date,
          content: content,
        )
      );
    }

    return noticeCards;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: noticeCards,
      builder: (context, data) {
        Widget child;

        if (data.hasData) {
          child = Scrollbar(
            child: ListView(
              padding: const EdgeInsets.all(12.0),
              children: List<Widget>.from(data.data! as List) + <Widget>[
                ListTile(
                  title: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.info_outline)
                    ),
                  ),
                  subtitle: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: '${AppLocalizations.of(context)!.newsSource}: ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.tdSource,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (await canLaunchUrl(Uri.parse(tdSourceUrl))) {
                                await launchUrl(Uri.parse(tdSourceUrl));
                              }
                            }
                        ),
                        TextSpan(
                          text: ', ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.rthk,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (await canLaunchUrl(Uri.parse(rthkUrl))) {
                                await launchUrl(Uri.parse(rthkUrl));
                              }
                            }
                        ),
                      ]
                    )
                  )
                ),
              ],
            ),
          );
        } else {
          child = Skeletonizer(
            enabled: true,
            child: ListView(
              padding: const EdgeInsets.all(12.0),
              children: [
                for (var i = 0; i < 5; i++)
                  const NoticeCard(
                    source: 'RTHK',
                    location: 'Lego City Road to Lego City River, near Lego City Prison',
                    heading: 'Road Incident: Traffic Accident',
                    date: '2024-08-14 20:00',
                    content: 'A man has fallen into the river in Lego City! Start the rescue helicopter! Hey! Build the helicopter and off to the rescue!',
                  )
              ],
            )
          );
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar.large(
                  title: Text(AppLocalizations.of(context)!.newsTitle),
                ),
              ];
            },
            body: Builder(
              builder: (context) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: child,
                );
              }
            ),
          ),
        );
      }
    );
  }
}

class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.source,
    required this.location,
    required this.heading,
    required this.date,
    required this.content,
  });

  final String source;
  final String location;
  final String heading;
  final String date;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(
                location,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text('$heading${timeago.format(DateTime.parse(date), locale: AppLocalizations.of(context)!.timeagoLocale)} • $source'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(content),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}

class ToolsPage extends StatefulWidget {
  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          children: [
            Material(
              child: ListTile(
                leading: const Icon(Icons.language),
                title: Text(
                  AppLocalizations.of(context)!.settingLang,
                ),
                subtitle: Text(AppLocalizations.of(context)!.lang),
                onTap: () => showLanguageSettingDialog(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
            ),
          ]
        )
      ),
    );
  }

  void showLanguageSettingDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    int langCode = prefs.getInt('lang') ?? 0;

    // Get user selection
    bool saveChoice = false;  // False if user presses Cancel, True if user presses OK
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.settingLang),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.defaultLang),
                      leading: Radio(
                        value: 0,
                        groupValue: langCode,
                        onChanged: (int? value) => setState(() => langCode = 0),
                      ),
                    ),
                    ListTile(
                      title: const Text('English'),
                      leading: Radio(
                        value: 1,
                        groupValue: langCode,
                        onChanged: (int? value) => setState(() => langCode = 1),
                      ),
                    ),
                    ListTile(
                      title: const Text('中文(香港)'),
                      leading: Radio(
                        value: 2,
                        groupValue: langCode,
                        onChanged: (int? value) => setState(() => langCode = 2),
                      ),
                    ),
                  ]
                );
              },
            ),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.settingCancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.settingOK),
                onPressed: () {
                  saveChoice = true;
                  Navigator.of(context).pop();
                },
              ),
            ]
          );
        }
      );
    }

    // Save selection to settings
    if (saveChoice) {
      await prefs.setInt('lang', langCode);
    }

    // Prompt user to reopen app\
    if (context.mounted && saveChoice) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.langRestart,
      );
    }
  }
}