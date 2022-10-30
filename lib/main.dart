import 'package:crud/slqhelper.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, Object?>> data = [];
  List<Map<String, Object?>> findOne = [];
  final judulC = TextEditingController();
  final deskripsiC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final cariDataC = TextEditingController();
  List<Map<String, Object?>> tempData = [];
  bool isMatch = false;
  bool dataNotFound = false;

  refreshData() async {
    data = await SqlHelper.getData();
    setState(() {});
  }

  addData() async {
    SqlHelper.insertData(judulC.text, deskripsiC.text);
    refreshData();
  }

  getDataById(id) async {
    refreshData();
    final data = await SqlHelper.getById(id);
    if (data.length != 0) {
      findOne = data;
      setState(() {});
    }
  }

  openBottomShetUpdate(String judul, String description) {
    judulC.text = judul;
    deskripsiC.text = description;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: judulC,
                        validator: (value) {
                          if (value.toString().isEmpty) {
                            return "judul tidak boleh kosong";
                          }
                        },
                        decoration: InputDecoration(labelText: "Judul"),
                      ),
                      TextFormField(
                        controller: deskripsiC,
                        validator: (value) {
                          if (value.toString().isEmpty) {
                            return "judul tidak boleh kosong";
                          }
                        },
                        decoration: InputDecoration(labelText: "Deskripsi"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            refreshData();
                            SqlHelper.updateData(
                                judulC.text, deskripsiC.text, findOne[0]['id']);
                            judulC.clear();
                            deskripsiC.clear();
                            getDataById(findOne[0]['id']);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("save")),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    refreshData();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catatan"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: cariDataC,
              decoration: InputDecoration(
                  labelText: 'cari catatan by judul',
                  suffixIcon:
                      IconButton(onPressed: () {}, icon: Icon(Icons.search))),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                    onPressed: () async {
                      tempData = await SqlHelper.searchData(cariDataC.text);
                      isMatch = true;
                      print(tempData.length);
                      if (tempData.length == 0) {
                        setState(() {
                          dataNotFound = true;
                        });
                      } else {
                        dataNotFound = false;
                      }

                      setState(() {});
                    },
                    child: Text('cari data')),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      isMatch = false;
                    });
                    refreshData();
                  },
                  icon: Icon(Icons.refresh_outlined))
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isMatch
                  ? dataNotFound
                      ? Center(child: Text('data tidak ada refresh'))
                      : ListView.separated(
                          itemBuilder: (context, index) => Container(
                                // ignore: sort_child_properties_last
                                child: ListTile(
                                  title: Text(
                                    tempData[index]['judul'].toString(),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  subtitle: Text(
                                      tempData[index]['deskripsi'].toString()),
                                  trailing: SizedBox(
                                    width: 100,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              final indexValue =
                                                  tempData[index]['id'];
                                              refreshData();
                                              getDataById(indexValue);
                                              openBottomShetUpdate(
                                                  findOne[0]['judul']
                                                      .toString(),
                                                  findOne[0]['deskripsi']
                                                      .toString());
                                            },
                                            icon: Icon(Icons.edit)),
                                        IconButton(
                                            onPressed: () {
                                              try {
                                                final indexValue =
                                                    tempData[index]['id'];
                                                SqlHelper.deleteById(
                                                    indexValue);
                                                refreshData();
                                              } catch (e) {
                                                print(e);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text("${e}")));
                                              }
                                            },
                                            icon: Icon(Icons.delete))
                                      ],
                                    ),
                                  ),
                                ),
                                height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.deepPurple[50],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2))),
                              ),
                          separatorBuilder: (context, index) => const SizedBox(
                                height: 20,
                              ),
                          itemCount: tempData.length)
                  : ListView.separated(
                      itemBuilder: (context, index) => Container(
                            // ignore: sort_child_properties_last
                            child: ListTile(
                              title: Text(
                                data[index]['judul'].toString(),
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic),
                              ),
                              subtitle:
                                  Text(data[index]['deskripsi'].toString()),
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          final indexValue = data[index]['id'];
                                          refreshData();
                                          getDataById(indexValue);
                                          openBottomShetUpdate(
                                              findOne[0]['judul'].toString(),
                                              findOne[0]['deskripsi']
                                                  .toString());
                                        },
                                        icon: Icon(Icons.edit)),
                                    IconButton(
                                        onPressed: () {
                                          try {
                                            final indexValue =
                                                data[index]['id'];
                                            SqlHelper.deleteById(indexValue);
                                            refreshData();
                                          } catch (e) {
                                            print(e);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text("${e}")));
                                          }
                                        },
                                        icon: Icon(Icons.delete))
                                  ],
                                ),
                              ),
                            ),
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple[50],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2))),
                          ),
                      separatorBuilder: (context, index) => const SizedBox(
                            height: 20,
                          ),
                      itemCount: data.length),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.note_add),
        onPressed: () {
          judulC.clear();
          deskripsiC.clear();
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: judulC,
                              validator: (value) {
                                if (value.toString().isEmpty) {
                                  return "judul tidak boleh kosong";
                                }
                              },
                              decoration: InputDecoration(labelText: "Judul"),
                            ),
                            TextFormField(
                              controller: deskripsiC,
                              validator: (value) {
                                if (value.toString().isEmpty) {
                                  return "judul tidak boleh kosong";
                                }
                              },
                              decoration:
                                  InputDecoration(labelText: "Deskripsi"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  addData();
                                  refreshData();
                                  judulC.clear();
                                  deskripsiC.clear();
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text("save")),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
