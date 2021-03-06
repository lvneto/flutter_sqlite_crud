import 'package:flutter/material.dart';
import 'package:sqlite_crud/models/contact.dart';
import 'package:sqlite_crud/utils/database_helper.dart';

const darkBlueColor = Color(0xff486579);
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQlite CRUD',
      theme: ThemeData(
        primaryColor: darkBlueColor,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Cadastrar país, estado e cidade.'),
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

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;

  Contact _contact = Contact();
  List<Contact> _contacts = [];
  DatabaseHelper _dbHelper;

  final _formkey = GlobalKey<FormState>();
  final _ctrlPais = TextEditingController();
  final _ctrlEstado = TextEditingController();
  final _ctrlCidade = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _refreshContactList();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(
            child: Text(widget.title, style: TextStyle(color: darkBlueColor))),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_form(), _list()],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _form() => Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Form(
        key: _formkey,
        child: Column(children: <Widget>[
          TextFormField(
            controller: _ctrlPais,
            decoration: InputDecoration(labelText: 'País'),
            onSaved: (val) => setState(() => _contact.pais = val),
            validator: (val) => (val.length == 0 ? 'Preencha o campo' : null),
          ),
          TextFormField(
            controller: _ctrlEstado,
            decoration: InputDecoration(labelText: 'Estado'),
            onSaved: (val) => setState(() => _contact.estado = val),
            validator: (val) =>
                (val.length == 0 ? 'Insira o nome do estado' : null),
          ),
          TextFormField(
            controller: _ctrlCidade,
            decoration: InputDecoration(labelText: 'Cidade'),
            onSaved: (val) => setState(() => _contact.cidade = val),
            validator: (val) =>
                (val.length == 0 ? 'Insira o nome da cidade' : null),
          ),
          Container(
              margin: EdgeInsets.all(10.0),
              child: RaisedButton(
                onPressed: () => _onSubmit(),
                child: Text('Gravar'),
                color: darkBlueColor,
                textColor: Colors.white,
              ))
        ]),
      ));

  _refreshContactList() async {
    List<Contact> x = await _dbHelper.fetchContacts();
    setState(() {
      _contacts = x;
    });
  }

  _onSubmit() async {
    var form = _formkey.currentState;
    if (form.validate()) {
      form.save();
      if (_contact.id == null)
        await _dbHelper.insertContact(_contact);
      else
        await _dbHelper.updateContact(_contact);

      _refreshContactList();
      _resetForm();
    }
  }

  _resetForm() {
    setState(() {
      _formkey.currentState.reset();
      _ctrlPais.clear();
      _ctrlEstado.clear();
      _ctrlCidade.clear();
      _contact.id = null;
    });
  }

  _list() => Expanded(
        child: Card(
          margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    isThreeLine: true,
                    leading: Icon(Icons.account_circle,
                        color: darkBlueColor, size: 40.0),
                    title: Text(
                      _contacts[index].pais.toUpperCase(),
                      style: TextStyle(
                        color: darkBlueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      children: <Widget>[
                        Text(
                          ('ESTADO  '),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: darkBlueColor,
                          ),
                        ),
                        Text(
                          _contacts[index].estado.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          ('  CIDADE  '),
                          style: TextStyle(color: darkBlueColor),
                        ),
                        Text(
                          _contacts[index].cidade.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                    trailing: IconButton(
                        icon: Icon(Icons.delete_sweep, color: darkBlueColor),
                        onPressed: () async {
                          await _dbHelper.deleteContact(_contacts[index].id);
                          _resetForm();
                          _refreshContactList();
                        }),
                    onTap: () {
                      setState(() {
                        _contact = _contacts[index];
                        _ctrlPais.text = _contacts[index].pais;
                        _ctrlEstado.text = _contacts[index].estado;
                        _ctrlCidade.text = _contacts[index].cidade;
                      });
                    },
                  ),
                  Divider(
                    height: 5.0,
                  )
                ],
              );
            },
            itemCount: _contacts.length,
          ),
        ),
      );
}
