import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:final_project/Airplane/AirplaneDB.dart';
import 'package:flutter/material.dart';
import 'Airplane.dart';
import 'AirplaneDAO.dart';
import '../AppLocalizations.dart';

///creates the AirplaneListPage
class AirplaneListPage extends StatefulWidget {
  const AirplaneListPage({super.key});

  @override
  State<StatefulWidget> createState() => AirplaneListPageCreate();
}

///builds the page
class AirplaneListPageCreate extends State<AirplaneListPage> {
  ///selected airplane from the list that the user wants displayed
  Airplane? selected;

  ///list of Airplane objects, reflects what is stored in the database
  late List<Airplane> airplanes = [];

  ///controller for the textbox that tracks user input
  late TextEditingController input;

  ///data access object for airplane table
  late AirplaneDAO dao;

  ///english canadian locale
  var english = Locale('en', 'CA');

  ///french standard locale
  var french = Locale('fr', 'FR');

  ///locale for switching languages
  late var locale;

  ///translates string
  String translate(String s) {
    return AppLocalizations.of(context)?.translate(s) ?? 'error';
  }

  ///sets initial state of page
  ///
  /// initializes input controller, calls getPreviousInput() and createDB()
  @override
  void initState() {
    super.initState();
    input = TextEditingController();
    getPreviousInput();
    createDB();
  }

  ///gets previously inputted value from encryptedsharedservices
  void getPreviousInput() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
    var stored = await prefs.getString('input');
    setState(() {
      input.text = stored;
    });
  }

  ///creates database and initializes dao object
  Future<void> createDB() async {
    final database = await $FloorAirplaneDatabase
        .databaseBuilder('Airplane_Database.db')
        .build();
    dao = database.airplaneDAO;
    load();
  }

  ///updates list of airplanes, 'refreshes' page to see updated list in listbuilder
  Future<void> load() async {
    final temp = await dao.findAllAirplanes();
    setState(() {
      airplanes = temp;
    });
  }

  ///adds airplane to to table
  ///
  /// calls checkId to make sure correct id values
  Future<void> add(String n, int p, double s, double d) async {
    int id = await checkId();

    final temp = Airplane(id, n, p, s, d);

    await dao.insertAirplane(temp);
    input.clear;
    load();
  }

  ///deletes airplane based on inputted id
  Future<void> delete(int id) async {
    final temp = await dao.findAirplane(id).first;
    if (temp != null) {
      await dao.deleteAirplane(temp);
      load();
    }
  }

  ///returns new valid ID
  ///
  ///checks ID and returns that value +1, used to auto increment Ids
  Future<int> checkId() async {
    List<Airplane> planes = await dao.findAllAirplanes();

    int maxId = 0;

    for (Airplane temp in planes) {
      if (temp.id > maxId) {
        maxId = temp.id;
      }
    }

    return maxId + 1;
  }

  ///returns page widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('pageTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(translate('title'),
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: TextField(
                    controller: input,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: translate('textHeading'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  child: Text(translate('add')),
                  onPressed: () {
                    EncryptedSharedPreferences prefs =
                    EncryptedSharedPreferences();
                    prefs.setString('input', input.value.text);
                    List<String> values = input.text.split('_');
                    try {
                      String name = values[0];
                      int passengers = int.parse(values[1]);
                      double speed = double.parse(values[2]);
                      double distance = double.parse(values[3]);

                      add(name, passengers, speed, distance);
                    } catch (e) {
                      invalidInputSnackBar();
                    }
                  },
                ),
              ],
            ),
            Expanded(child: display()),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: const Icon(Icons.description),
              onPressed: () {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(translate('instructions')),
                            const SizedBox(height: 10),
                            Text(translate('instructions2')),
                            const SizedBox(height: 10),
                            Text(translate('instructions3')),
                          ]),
                      actions: <Widget>[
                        ElevatedButton(
                          child: Text(translate('close')),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }

  ///snackbar to warn user of invalid input
  void invalidInputSnackBar() {
    var snackBar = SnackBar(
      content: Text(translate('snackbar')),
      action: SnackBarAction(
        label: translate('Hide'),
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  ///returns widget that displays a list in the master-detail pattern
  Widget display() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(flex: 1, child: listAirplanes()),
          Expanded(flex: 2, child: listAirplaneDetails()),
        ],
      );
    } else {
      if (selected == null) {
        return listAirplanes();
      } else {
        return listAirplaneDetails();
      }
    }
  }

  ///listview builder of airplanes list
  Widget listAirplanes() {
    return ListView.builder(
      itemCount: airplanes.length,
      itemBuilder: (context, index) {
        final temp = airplanes[index];
        return GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(temp.name, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          onTap: () {
            setState(() {
              selected = temp;
            });
          },
        );
      },
    );
  }

  ///display of selected airplane values
  ///
  /// based on currently selected airplane, displays all values and allows for deletion
  Widget listAirplaneDetails() {
    if (selected != null) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(translate('details'), style: const TextStyle(fontSize: 30.0)),
          Text('${translate('name')}${selected!.name}',
              style: const TextStyle(fontSize: 20.0)),
          Text('${translate('passengers')}${selected!.passengers}',
              style: const TextStyle(fontSize: 20.0)),
          Text('${translate('speed')}${selected!.speed}',
              style: const TextStyle(fontSize: 20.0)),
          Text('${translate('distance')}${selected!.distance}',
              style: const TextStyle(fontSize: 20.0)),
        ]),
        ElevatedButton(
          child: Text(translate('delete')),
          onPressed: () {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: Text(translate('delMessage')),
                  actions: <Widget>[
                    ElevatedButton(
                      child: Text(translate('yes')),
                      onPressed: () {
                        setState(() {
                          delete(selected!.id);
                          setState(() {
                            selected = null;
                            load();
                          });
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton(
                      child: Text(translate('no')),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ));
          },
        ),
        ElevatedButton(
          child: Text(translate('clear')),
          onPressed: () {
            setState(() {
              selected = null;
            });
          },
        ),
      ]);
    } else {
      return Container();
    }
  }
}
