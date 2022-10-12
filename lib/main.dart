import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List _toDoList = [];

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> task = Map();
      task["title"] = _toDoController.text;
      task["ok"] = false;
      _toDoList.add(task);
      _saveData();
      _toDoController.text = "";
    });
  }

  void _changeStatus(bool? value, int index) {
    setState(() {
      _toDoList[index]["ok"] = value;
      _saveData();
    });
  }

  void _removeToDo(int index) {
    setState(() {
      final title = _toDoList[index]["title"];
      _toDoList.removeAt(index);
      _saveData();

      final snack = SnackBar(
        content: Text("Tarefa \"$title\" removida!"),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).showSnackBar(snack);
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de tarefas")),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(17, 1, 7, 1),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                      labelText: "Nova tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent)),
                  controller: _toDoController,
                ),
              ),
              ElevatedButton(onPressed: _addToDo, child: const Text("ADD"))
            ],
          ),
        ),
        Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: _toDoList.length,
                itemBuilder: _buildItem))
      ]),
    );
  }

  Widget _buildItem(context, index) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment(0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      child: CheckboxListTile(
          title: Text(_toDoList[index]["title"]),
          value: _toDoList[index]["ok"],
          secondary: CircleAvatar(
              child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error)),
          onChanged: (value) => _changeStatus(value, index)),
      onDismissed: (direction) => _removeToDo(index),
    );
  }
}
