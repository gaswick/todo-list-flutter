import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:todo_app/db_todo.dart';
import 'toDo.dart';

// TODO: Today Tomorrow, Filter, Search

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Things to Do'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  bool isChecked = false;
  ToDo toDo = new ToDo.empty();
  List<ToDo> toDos = [];
  List<ToDo> searchToDo = [];
  DateTime now = DateTime.now();
  List<String> dates = [];

  @override
  void initState() {
    super.initState();

    refreshToDos();
  }

  Future refreshToDos() async {
    this.toDos = await ToDoDatabase.instance.readAllToDo();
    setState(() => {});
  }

  // void checkDate() {
  //   for (toDo in this.toDos) {
  //     if (now.toString().substring(0, 10) == toDo.date) {
  //       dates.add('TODAY');
  //     }
  //     else{
  //       dates.add('${toDo.date}');
  //     }
  //   }
  //   setState(() {
  //
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: addAgenda, icon: Icon(Icons.search)),
          IconButton(onPressed: addAgenda, icon: Icon(Icons.filter_list_sharp))
        ],
      ),
      body: ListView.builder(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        itemCount: toDos.length,
        itemBuilder: (context, index) {
          return Card(
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 98,
                      child: Column(
                        children: <Widget>[
                          Row(children: [
                            Checkbox(
                              checkColor: Colors.white,
                              fillColor: MaterialStateProperty.resolveWith(getColor),
                              value: toDos[index].isFinalised, //value dari toDo
                              onChanged: (bool? value) {
                                setState(() {
                                  toDos[index].isFinalised = value;
                                  print(toDos[index].color);
                                  updateToDo(toDos[index]);
                                });
                              },
                            ),
                            Text('${toDos[index].title}',
                              style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 20,
                              ),

                            )
                          ]),
                          Row(
                            children: [
                              Padding(padding: EdgeInsets.fromLTRB(16,0,0,0),
                                child : Text('${toDos[index].desc}',
                                style: TextStyle(fontSize: 16 ),)
                              )

                            ],
                          ),
                          Row(
                            children: [
                              Padding(padding: EdgeInsets.fromLTRB(16,0,0,0),
                                  child : Text('${toDos[index].date} ${toDos[index].time}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: toDos[index].color, //Isi pake color class
                        height: 100,
                      ),
                    ),
                  ],
                ),
              ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addAgenda,
        tooltip: 'Add',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void addAgenda() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTask(toDos: toDos,)),

    ).then(onGoBack);
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {
      refreshToDos();
    });
  }

  Future updateToDo(ToDo toDo) async {

    await ToDoDatabase.instance.update(toDo);
  }

  // void search(String searchText){
  //   searchToDo.clear();
  // }
}

class AddTask extends StatefulWidget {
  AddTask({Key? key, required this.toDos }) : super(key: key);
  List<ToDo> toDos;

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  ToDo tempToDo = new ToDo.empty();
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String pickedDate = 'Pick the date';
  String pickedTime = 'Pick the time';
  Item? pickedColor;
  DateTime now = DateTime.now();

  List<Item> availableColors = <Item>[
    const Item('Green', Color(0xff4caf50)),
    const Item('Red', Color(0xfff44336)),
    const Item('Blue', Color(0xff2196f3)),
    const Item('Yellow', Color(0xffffeb3b)),
    const Item('Purple', Color(0xff9c27b0)),
    ];

  @override
  void dispose(){
    titleController.dispose();
    dateController.dispose();
    timeController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Task'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: DropdownButton<Item>(
                  hint: Text('Pick Color'),
                  value: pickedColor,
                  onChanged: (value) {
                    setState(() {
                        pickedColor = value;
                        tempToDo.color = pickedColor!.color;
                    });
                  },
                  items: availableColors.map((Item user) {
                    return  DropdownMenuItem<Item>(
                      value: user,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 200,
                          child: Container(
                            color: user.color,
                            width: 400,
                            height: 100,

                          ),),

                        ],
                      ),
                    );
                  }).toList(),

                ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child : TextFormField(
                    validator: (title) {
                      if (title == null || title.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (val){
                      setState(() {
                        tempToDo.setTitle = val;
                      });
                    },
                    controller: titleController,
                    decoration: InputDecoration(
                        hintText: 'Title'
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: TextButton(
                        onPressed: () {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(2018, 3, 5),
                              maxTime: DateTime(2099, 12, 31), onChanged: (date) {
                                print('change $date');
                                setState(() {
                                  String temp;
                                  temp = date.toString();
                                  pickedDate = temp.substring(0, 10);
                                  // if(pickedDate == now.toString().substring(0, 10)){
                                  //   pickedDate = 'TODAY';
                                  // }
                                  tempToDo.setDate = pickedDate;
                                });
                              }, onConfirm: (date) {
                                print('confirm $date');
                              }, currentTime: DateTime.now(), locale: LocaleType.id);
                        },
                        child: Text(
                          'Date : $pickedDate',
                          style: TextStyle(color: Colors.blue),
                        )
                    ),
                ),
                Expanded(
                  child: TextButton(
                      onPressed: () {
                        DatePicker.showTimePicker(context,
                            showTitleActions: true,
                            onChanged: (time) {
                              print('change $time');
                              setState(() {
                                String temp;
                                temp = time.toString();
                                pickedTime = temp.substring(11,16);
                                tempToDo.setTime = pickedTime;
                              });
                            }, onConfirm: (time) {
                              print('confirm $time');
                            }, currentTime: DateTime.now(), locale: LocaleType.id);
                      },
                      child: Text(
                        'Time : $pickedTime',
                        style: TextStyle(color: Colors.blue),
                      ),

                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                      validator: (desc) {
                        if (desc == null || desc.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      controller: descController,
                      decoration: InputDecoration(
                          hintText: 'Description'
                      ),
                      onChanged: (val){
                        setState(() {
                          tempToDo.setDesc = val;
                        });
                      },
                    )
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 75,
                  child: Container(),
                ),
                Expanded(
                  flex: 25,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate() && tempToDo.date != null && tempToDo.time != null) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.

                          print(tempToDo.desc);
                          print(tempToDo.title);
                          print(tempToDo.date);
                          print(tempToDo.time);
                          print(tempToDo.color);
                          addToDo(tempToDo);
                          widget.toDos.add(tempToDo);
                          print(widget.toDos);
                          print(widget.toDos.length);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Submit'),
                    ),
                )
              ],
            )

          ],
        ),


      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //
      //     Navigator.pop(context);
      //     setState(() {
      //
      //     });
      //     //Add save to List Object
      //   },
      //   backgroundColor: Colors.orange,
      //   tooltip: 'Add',
      //   child: Icon(Icons.check),
      // ),
    );
  }
  Future addToDo(ToDo toDo) async {
    await ToDoDatabase.instance.create(toDo);
  }
  Future delToDo(int id) async{
    await ToDoDatabase.instance.delete(id);
  }
}

class Item {
  const Item(this.name,this.color);
  final String name;
  final Color color;
  Color get getColor{
    return color;
  }
}



