import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController textController = TextEditingController();
  TextEditingController textUpdateController = TextEditingController();
  var id = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter a task"
                      ),
                      controller: textController,
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        var id = DateTime.now().toString();
                        FirebaseFirestore.instance
                            .collection('user')
                            .doc(id)
                            .set({"name": textController.text, "id": id});
                        textController.clear();
                      },
                      child: Text("Done"))
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('user').snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData){
                    return CircularProgressIndicator();
                  }
                  else if(snapshot.hasData&&snapshot.data!.docs.isEmpty){
                    return Text("No Tasks");
                  }
                  else {
                    return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data!.docs[index]['name']),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Edit task"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                controller:
                                                    textUpdateController,
                                                decoration: InputDecoration(
                                                  labelText: 'Task',
                                                  prefixIcon: const Icon(
                                                      Icons.task),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              ElevatedButton.icon(
                                                  onPressed: () {
                                                    FirebaseFirestore.instance
                                                        .collection('user')
                                                        .doc(snapshot.data!
                                                            .docs[index]['id'])
                                                        .update({
                                                      "name":
                                                          textUpdateController
                                                              .text
                                                    });
                                                    textUpdateController
                                                        .clear();
                                                    Navigator.pop(context);
                                                  },
                                                  icon: const Icon(Icons.done),
                                                  label: const Text("submit")),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('user')
                                        .doc(snapshot.data!.docs[index]['id'])
                                        .delete();
                                  },
                                  icon: Icon(Icons.delete)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  }
                })
          ],
        ),
      ),
    );
  }
}
