import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController taskController = TextEditingController();
  TextEditingController taskUpdateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Flexible(child: TextField(
                  controller: taskController,
                )),
                ElevatedButton(onPressed: (){
                  var id = DateTime.now().toString();
                  FirebaseFirestore.instance.collection('user').doc(id).set({
                    "id":id,
                    "name":taskController.text
                  });
                  taskController.clear();
                },
                    child: Text("done"))
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('user').snapshots(),
              builder: (context, snapshot) {
                if(!snapshot.hasData){
                  return Text("no tasks");
                }else {
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
                            IconButton(onPressed: (){
                              showDialog(context: context,
                                builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Edit task"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(child: TextField(
                                        controller: taskUpdateController,
                                      )),
                                      ElevatedButton(onPressed: (){
                                        FirebaseFirestore.instance.collection('user').doc(snapshot.data!.docs[index]['id']).update({
                                          "name":taskUpdateController.text
                                        });
                                        Navigator.pop(context);
                                      },
                                          child: Text("Update"))
                                    ],
                                  ),
                                );
                              },);
                            },
                                icon:Icon(Icons.edit)),
                            IconButton(onPressed: (){
                              FirebaseFirestore.instance.collection('user').doc(snapshot.data!.docs[index]['id']).delete();
                            },
                                icon:Icon(Icons.delete)),

                          ],
                        ),
                      ),
                    );
                },);
                }
              }
            ),
            ElevatedButton(onPressed: (){
              showDialog(context: context, builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Delete?"),
                  content: Text("Do you want to delete"),
                  actions: [
                    TextButton(
                        onPressed: (){
                      FirebaseFirestore.instance.collection('user').get().then((value) {
                        for(DocumentSnapshot doc in value.docs){
                          doc.reference.delete();
                        }
                      });
                      Navigator.pop(context);
                    },
                        child: Text("Yes")
                    ),
                    TextButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text("No"))
                  ],
                );
              });

            },
                child: Text("Delete All"))
          ],
        ),
      ),
    );
  }
}
