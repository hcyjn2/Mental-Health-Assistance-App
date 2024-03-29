import 'package:flutter/material.dart';
import 'package:main_menu/Screens/MoodTracker/MoodTrackerCalendarBrains.dart';
import 'package:main_menu/components/MenuFunctions/SwipeablePageWidget.dart';
import 'package:main_menu/components/mood_tracker/mood_record_detail.dart';
import 'package:main_menu/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import 'AnimatedButton.dart';
import 'MainMenuDrawer.dart';

class MainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        builder: Builder(builder: (context) => MenuBody()),
        autoPlay: false,
        autoPlayDelay: Duration(seconds: 3),
        autoPlayLockEnable: false,
      ),
    );
  }
}

class MenuBody extends StatefulWidget {
  @override
  _MenuBodyState createState() => _MenuBodyState();
}

class _MenuBodyState extends State<MenuBody> {
  //For First time user guide
  GlobalKey _sideBarKey = GlobalKey();
  GlobalKey _localClinicKey = GlobalKey();
  GlobalKey _diagnosisKey = GlobalKey();
  GlobalKey _moodKey = GlobalKey();
  GlobalKey _journalKey = GlobalKey();
  GlobalKey _swipeKey = GlobalKey();

  void testChosen(BuildContext context) {
    Navigator.pushNamed(context, '/mainmenu/test');
  }

  void handleSwipe(BuildContext context) {
    Navigator.pushNamed(context, '/mainmenu/helpScreen');
  }

  void moodTrackerChosen(BuildContext context) {
    Navigator.pushNamed(context, '/mainmenu/moodtracker');
  }

  void moodTrackerCalendarViewChosen(BuildContext context) {
    MoodTrackerCalenderBrains brains = MoodTrackerCalenderBrains();
    Navigator.pushNamed(
      context,
      '/calendar',
      arguments: brains,
    );
  }

  void mentalSpecialistMapChosen(BuildContext context) {
    Navigator.pushNamed(context, '/mainmenu/mentalspecialistmap');
  }

  Future loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<MoodRecordDetail> decodedData =
        MoodRecordDetail.decode(prefs.get('key'));

    if (decodedData == null) return null;

    return decodedData;
  }

  Future<bool> isTodayRecorded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('counter');

    if (counter == null) return false;

    var moodRecordDetailList = await loadData();

    final String curDate = DateTime.now().toString().substring(0, 10);

    for (var moodRecordDetail in moodRecordDetailList) {
      String recordDate = moodRecordDetail.dateTime.toString().substring(0, 10);

      if (recordDate == curDate) return true;
    }

    return false;
  }

  Future<bool> isMoodCalendarEmpty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('counter');

    if (counter == null)
      return true;
    else
      return false;
  }

  Future<Widget> buildOverwriteAlert() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'You have already checked-in today.\n\nDo you want to Overwrite it?',
              style: kThickFont.copyWith(fontSize: 19),
              textAlign: TextAlign.center,
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  elevation: 5.0,
                  color: Colors.redAccent[100],
                  child: Text('NO', style: kThickFont.copyWith(fontSize: 14)),
                  onPressed: () async {
                    setState(() {
                      //NO Action
                      Navigator.pop(context);
                    });
                  },
                ),
                SizedBox(
                  width: 30,
                ),
                MaterialButton(
                  elevation: 5.0,
                  color: Colors.lightGreenAccent[100],
                  child: Text('YES', style: kThickFont.copyWith(fontSize: 14)),
                  onPressed: () async {
                    setState(() {
                      //YES Action
                      moodTrackerChosen(context);
                    });
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<Widget> buildEmptyCalendarAlert() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'The calendar is Empty. \n\nTry to record something...\n',
              style: kThickFont.copyWith(fontSize: 19),
              textAlign: TextAlign.center,
            ),
            content: MaterialButton(
              elevation: 5.0,
              color: Colors.grey[400],
              child: Text('OKAY', style: kThickFont.copyWith(fontSize: 14)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          );
        });
  }

  Future<bool> isFirstGuide() async {
    //Storing local data for first showcase boolean
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool showCaseVisibilityStatus = preferences.getBool("isFirstShowcase");

    if (showCaseVisibilityStatus == null) {
      preferences.setBool("isFirstShowcase", false);
      return true;
    }
    return false;
  }

  Future<Widget> buildUserGuideWelcome() {
    //A dialog for first time user guide
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Welcome! \n\nThis is a brief tutorial to show you around.\n',
              style: kThickFont.copyWith(fontSize: 19),
              textAlign: TextAlign.center,
            ),
            content: MaterialButton(
              elevation: 5.0,
              color: Colors.grey[400],
              child: Text('Get Started'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          );
        });
  }

  bool choice = false;
  createDeclarationAlert(BuildContext context) {
    // set up the buttons
    Widget cancelButton = MaterialButton(
      elevation: 5.0,
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('BACK', style: kThickFont.copyWith(fontSize: 14)),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget continueButton = MaterialButton(
      elevation: 5.0,
      color: Colors.lightGreenAccent[100],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('PROCEED', style: kThickFont.copyWith(fontSize: 14)),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        choice = true;
        testChosen(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Disclaimer:"),
      content: Text(
        "The following tests are meant for personal use to identify symptoms of stress or anxiety. They are not meant to be used as diagnostic tools. Please visit a professional if you need help.",
        textAlign: TextAlign.justify,
        style: kThickFont.copyWith(fontSize: 19),
      ),
      actions: [
        cancelButton,
        SizedBox(
          width: 15,
        ),
        continueButton,
        SizedBox(
          width: 40,
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    //Check if this is a first time user
    isFirstGuide().then((status) {
      if (status) {
        buildUserGuideWelcome().then((status) {
          //Start the guide
          ShowCaseWidget.of(context).startShowCase([
            _sideBarKey,
            _localClinicKey,
            _diagnosisKey,
            _moodKey,
            _journalKey,
            _swipeKey
          ]);
        });
      }
    });

    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/Images/menubackground.jpg'),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: Showcase(
                  key: _sideBarKey,
                  description: 'Tap here to access setting,logout and etc.',
                  child: Icon(Icons.menu)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          centerTitle: true,
          title: Showcase(
            key: _swipeKey,
            description:
                'Then, we have a feature that will soothe the tension. \nSwipe Left to access this. \n\n Finally, Swipe Right from any page \n to go back to the main menu.',
            showArrow: false,
            child: Text(
              "E-Health Adviser App",
              style: kThickFont.copyWith(fontSize: 18, color: Colors.black),
            ),
          ),
          backgroundColor: Color(0xFF99d8e8),
        ),
        drawer: MainMenuDrawer(),
        body: SwipeablePageWidget(
          onSwipeCallback: () {
            handleSwipe(context);
          },
          direction: SwipeDirection.toLeft,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Showcase(
                    key: _localClinicKey,
                    description: 'Tap to see nearby clinics',
                    child: AnimatedButton(
                      primaryColor: Color.fromRGBO(132, 180, 200, 1),
                      assetImage: Image.asset(
                        'assets/Images/clinics.png',
                        width: 62,
                      ),
                      buttonText: Text('Local Clinics',
                          style: kThickFont.copyWith(fontSize: 20)),
                      onTap: () {
                        mentalSpecialistMapChosen(context);
                      },
                    ),
                  ),
                  Showcase(
                    key: _diagnosisKey,
                    description: 'Tap here to take a diagnosis',
                    child: AnimatedButton(
                      primaryColor: Color.fromRGBO(178, 220, 214, 1),
                      assetImage: Image.asset(
                        'assets/Images/test.png',
                        width: 62,
                      ),
                      buttonText: Text('Evaluation',
                          style: kThickFont.copyWith(fontSize: 20)),
                      onTap: () {
                        if (choice == false) {
                          createDeclarationAlert(context);
                        } else if (choice == true) {
                          testChosen(context);
                        }
                      },
                    ),
                  ),
                  Showcase(
                    key: _moodKey,
                    description:
                        'Tap here to fill in how you are feeling today',
                    child: AnimatedButton(
                      primaryColor: Color.fromRGBO(244, 220, 214, 1),
                      assetImage: Image.asset(
                        'assets/Images/moodrecord.png',
                        width: 62,
                      ),
                      buttonText: Text('Record Mood',
                          style: kThickFont.copyWith(fontSize: 20)),
                      onTap: () async {
                        if (await isTodayRecorded())
                          buildOverwriteAlert();
                        else
                          moodTrackerChosen(context);
                      },
                    ),
                  ),
                  Showcase(
                    key: _journalKey,
                    description: 'Tap here to see your journal entry',
                    child: AnimatedButton(
                      primaryColor: Color.fromRGBO(223, 199, 193, 1),
                      assetImage: Image.asset(
                        'assets/Images/calendar.png',
                        width: 62,
                      ),
                      buttonText: Text('Mood Journal',
                          style: kThickFont.copyWith(fontSize: 20)),
                      onTap: () async {
                        if (await isMoodCalendarEmpty())
                          buildEmptyCalendarAlert();
                        else
                          moodTrackerCalendarViewChosen(context);
                      },
                    ),
                  ), //Mood Select
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
