import 'dart:io';
import 'package:agendacontatos/helpers/maindb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  Contact _editedContact;
  Contact _defaultContact;
  bool _userEdited = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  void _resetFields()
  {
    setState(() {
      _formkey = GlobalKey<FormState>();
      _editedContact = Contact.fromMap(_defaultContact.toMap());
      _userEdited = false;

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;

      FocusScope.of(context).requestFocus(_nameFocus);
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.contact != null)
      _editedContact = Contact.fromMap(widget.contact.toMap());
    else
      _editedContact = Contact();

    _defaultContact = Contact.fromMap(_editedContact.toMap());
    _nameController.text = _editedContact.name;
    _emailController.text = _editedContact.email;
    _phoneController.text = _editedContact.phone;
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Deseja realmente sair?"),
            content: Text("As alterações serão descartadas."),
            actions: <Widget>[
              FlatButton(child: Text("Cancelar"), onPressed: () {
                Navigator.pop(context);
              },),
              FlatButton(child: Text("Sair"), onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },),
            ],
          );
        }
      );
      return Future.value(false);
    }
    else
      return Future.value(true);
  }

  void _selectImage()
  {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(5.0),
                    color: Colors.white,
                    child: Icon(Icons.camera, size: 80.0, color: Colors.black),
                  ),
                  onTap: () {
                    ImagePicker.pickImage(source: ImageSource.camera).then((value) {
                      if (value == null) return;
                      else
                        setState(() {
                          _editedContact.img = value.path;
                          _userEdited = true;
                        });
                      Navigator.pop(context);
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(5.0),
                    color: Colors.white,
                    child: Icon(Icons.image, size: 80.0, color: Colors.black),
                  ),
                  onTap: () {
                    ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
                      if (value == null) return;
                      else
                        setState(() {
                          _editedContact.img = value.path;
                          _userEdited = true;
                        });
                      Navigator.pop(context);
                    });
                  },
                )
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? "Novo contato"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.refresh),
              onPressed: () {
                _resetFields();
              },)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_formkey.currentState.validate())
              Navigator.pop(context, _editedContact);
            else
              FocusScope.of(context).requestFocus(_nameFocus);
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: _formkey,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editedContact.img != null ?
                            FileImage(File(_editedContact.img)) :
                            AssetImage("images/contato.png"),
                            fit: BoxFit.cover
                        )
                    ),
                  ),
                  onTap: () {
                    _selectImage();
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Nome"
                  ),
                  onChanged: (text){
                    setState(() {
                      _userEdited = true;
                      _editedContact.name = text;
                    });
                  },
                  controller: _nameController,
                  validator: (value) {
                    if (value.isEmpty)
                      return "Insira o nome do contato";
                  },
                  focusNode: _nameFocus,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Email"
                  ),
                  onChanged: (text){
                      _userEdited = true;
                      _editedContact.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) {
                    if (value.isEmpty && _phoneController.text.isEmpty)
                      return "Email ou telefone obrigatório";
                  }
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "Fone"
                  ),
                  onChanged: (text){
                    _userEdited = true;
                    _editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  validator: (value) {
                    if (value.isEmpty && _emailController.text.isEmpty)
                      return "Email ou telefone obrigatório";
                  }
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
