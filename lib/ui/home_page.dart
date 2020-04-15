import 'dart:io';
import 'package:agendacontatos/helpers/maindb.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_page.dart';

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

enum OrderOptions { OrderAZ, OrderZA }

class _homePageState extends State<homePage> {

  ContactHelper helper = ContactHelper();
  List<Contact> Contacts = List();

  void _ShowContactPage({Contact contact}) async {
    final reContact = await Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage(contact: contact,)));
    if (reContact != null)
    {
      if (contact != null)
        await helper.updateContact(reContact);
      else
        await helper.saveContact(reContact);

      await _getAllContacts();
    }
  }

  @override
  void initState() {
    super.initState();
    _getAllContacts();
    _orderList(OrderOptions.OrderAZ);
  }

  void _getAllContacts() async {
    List<Contact> lst = await helper.getAllContact();
    setState(() {
      Contacts  = lst;
    });
  }

  void _ShowOptions(BuildContext context, int index){
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          onClosing: (){},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child:
                      Text(
                        "Ligar",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: (){
                        launch("tel:${Contacts[index].phone}");
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child:
                      Text(
                        "Editar",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        _ShowContactPage(contact: Contacts[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child:
                      Text(
                        "Excluir",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: (){
                        showDialog(
                        context: context,
                        builder: (context)
                        {
                          return AlertDialog(
                            title: Text("Deseja realmente excluir?"),
                            content: Text(
                                "A exclusão não poderá ser desfeita."),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Cancelar"), onPressed: () {
                                Navigator.pop(context);
                              },),
                              FlatButton(child: Text("Excluir"), onPressed: () {
                                helper.deleteContact(Contacts[index].id);
                                setState(() {
                                  Contacts.removeAt(index);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                });
                              },),
                            ],
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: Contacts[index].img != null ?
                        FileImage(File(Contacts[index].img)) :
                        AssetImage("images/contato.png"),
                      fit: BoxFit.cover
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(Contacts[index].name ?? "", style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(Contacts[index].email ?? "", style: TextStyle(fontSize: 18.0)),
                    Text(Contacts[index].phone ?? "", style: TextStyle(fontSize: 20.0))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        _ShowOptions(context, index);
      },
    );
  }

  void _orderList(OrderOptions result){
    setState(() {
      switch (result)
      {
        case OrderOptions.OrderAZ:
          Contacts.sort((a,b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          break;
        case OrderOptions.OrderZA:
          Contacts.sort((a,b) {
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar A-Z"),
                value: OrderOptions.OrderAZ,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar Z-A"),
                value: OrderOptions.OrderZA,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){ _ShowContactPage();},
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: Contacts.length,
        itemBuilder: (context, index){ return _contactCard(context, index); }
      ),
    );
  }
}
