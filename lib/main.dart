import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasky/Utilities.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: DateFormat.EEEE().format(DateTime.now()) + ', ' + DateFormat.yMMMd().format(DateTime.now())),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//Builds a column of tasks for a weekday
Widget weekColumnMaker(String weekDay, double hei){

  //Returns a stylized card with given label and height (in units)
  Widget Function(String,[double, bool]) cardFunc = (String label, [double unitHeight = 1, bool isTitle = false]){
    return Container(
      height: unitHeight * hei,
      child: Card(
        color: isTitle ? Colors.white : Colors.yellow,
        child: ClipPath(
          child: Container(
            child: Center(
              child: Text(
                label,
                style: TextStyle(fontSize: 20),
              ),
            ),
            // height: 100,
            decoration: BoxDecoration(
                border: isTitle ?
                Border(bottom:BorderSide(color: Colors.blueAccent, width: 5) ,top: BorderSide(color: Colors.blueAccent, width: 5))
                    : null
            ),
          )
          ,
          clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3))),
        ),

      ),
    );
  };

  //Returns empty space with given height (in units)
  Widget Function([double]) emptySpace = ([double unitHeight = 1]){
    return Container(
      height: unitHeight * hei,
      child: Text("hi, I'm this tall in units:"+unitHeight.toString()),
    );
  };

  List<Subject> x = [Subject("Compilation Theory", 0, 6), Subject("Other Ex", 7, 9),Subject("hallo", 17, 21)];

  List<Subject> processedList = processSubjectList(x);

  List<Widget> items = [cardFunc(weekDay,2,true)];

  processedList.forEach((element) {
    if(element.isEmpty){
      items.add(emptySpace(element.duration().toDouble()));
    } else {
      items.add(cardFunc(element.label,element.duration().toDouble()));
    }
  });

  return Column(children: items);
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    double testHeight = (MediaQuery.of(context).size.height-56)/23;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: Drawer(

      ),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Row(
          children: [
            Expanded(child: weekColumnMaker("Sunday",testHeight)),
            VerticalDivider(),
            Expanded(child: weekColumnMaker("Sunday",testHeight)),
            VerticalDivider(),
            Expanded(child: weekColumnMaker("Sunday",testHeight)),
            VerticalDivider(),
            Expanded(child: weekColumnMaker("Sunday",testHeight)),
            VerticalDivider(),
            Expanded(child: weekColumnMaker("Sunday",testHeight))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
