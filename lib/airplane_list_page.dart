import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:final_project/AirplaneDB.dart';
import 'package:flutter/material.dart';
import 'Airplane.dart';
import 'AirplaneDAO.dart';

///creates the AirplineListPage
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
    final database = await $FloorAirplaneDatabase.databaseBuilder('Airplane_Database.db').build();
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
        title: const Text('Airplane List'),
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('This is the Airplane List Page'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: TextField(
                  controller: input,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter an Airplane",
                  ),
                ),
              ),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () {
                  EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
                  prefs.setString('input', input.value.text);
                  List<String> values = input.text.split('_');
                  try {
                    String name = values[0];
                    int passengers = int.parse(values[1]);
                    double speed = double.parse(values[2]);
                    double distance = double.parse(values[3]);

                    add(name, passengers, speed, distance);
                  }
                  catch (e) {
                    invalidInputSnackBar();
                  }
                },
              ),
            ],
          ),
          Expanded(child: display()),
          ElevatedButton(
            child: const Icon(Icons.description),
            onPressed: () {
              showDialog<String>(
                  context: context,
                  builder: (BuildContext context) =>
                      AlertDialog(
                        content: const Column(
                            mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(alignment:Alignment.centerLeft, child:Text('Enter information into the database through the format "[plane-name]_[passenger-maximum]_[maximum-speed]_[maximum-distance]" ex. (boeing 737_200_0.78_7.084).')),
                            Align(alignment:Alignment.centerLeft, child:Text('Where [plane-name] is valid string, [passenger-maximum] is a valid integer, and [maximum-speed] & [maximum-distance] are both valid doubles. Do not enter the [ or ].')),
                            Align(alignment:Alignment.centerLeft, child:Text('Speed is measured in Mach levels, and distance is represented in 1000km. Ex. (boeing 737_200_0.78_7.084) 0.78 = mach 0.78, 7.084 = 7084km.')),
                          ]
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('close'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
              );
            },
          ),
        ],
      ),
      ),
    );
  }
  ///snackbar to warn user of invalid input
  void invalidInputSnackBar() {
    var snackBar = SnackBar( content: const Text('Invalid Input! Check Instructions.'), action:SnackBarAction(label: 'hide', onPressed: () { ScaffoldMessenger.of(context).hideCurrentSnackBar(); } ));
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
          Expanded(flex: 1,child: listAirplanes()),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                Text(temp.name),
            ],
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

    if(selected != null) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Airplane Details', style: TextStyle(fontSize: 30.0)),
                  Text('Name: ${selected!.name}', style: const TextStyle(fontSize: 20.0)),
                  Text('Passengers: ${selected!.passengers}', style: const TextStyle(fontSize: 20.0)),
                  Text('Speed: ${selected!.speed}', style: const TextStyle(fontSize: 20.0)),
                  Text('Distance: ${selected!.distance}', style: const TextStyle(fontSize: 20.0)),
                ]
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) =>
                        AlertDialog(
                          content: const Text('Are you sure you want to delete this plane?'),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('Yes'),
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
                              child: const Text('No'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        )
                );
              },
            ),
            ElevatedButton(
              child: const Text('Clear'),
              onPressed: () {
                setState(() {
                  selected = null;
                });
              },
            ),
          ]
      );
    }
    else {
      return Container();
    }
  }
}
