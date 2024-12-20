import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late Contact _editedContact;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _userEdited = false;
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());
      _nameController.text = _editedContact.name!;
      _emailController.text = _editedContact.email!;
      _phoneController.text = _editedContact.phone!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        bool value = await _confirmExit(context);
        if (value) {
          navigator.pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Salvar contato
            _validateAndSaveContact();
          },
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          child: Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _editedContact.img != null
                            ? FileImage(File(_editedContact.img!))
                            : AssetImage("images/person.png"),
                      ),
                    ),
                  ),
                  onTap: () async {
                    final ImageSource? fonte = await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => AlertDialog(
                        title: Text("Selecione uma opção"),
                        content: Text("Escolha uma fonte para a imagem"),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, ImageSource.camera),
                            style: TextButton.styleFrom(
                                overlayColor: Color(0x80000000)),
                            child: Text("Câmera",
                                style: TextStyle(color: Color(0xFF000000))),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, ImageSource.gallery),
                            style: TextButton.styleFrom(
                                overlayColor: Color(0x80000000)),
                            child: Text("Galeria",
                                style: TextStyle(color: Color(0xFFFFC107))),
                          ),
                        ],
                      ),
                    );

                    if (fonte != null) {
                      try {
                        final XFile? file =
                            await ImagePicker().pickImage(source: fonte);
                        if (file != null) {
                          setState(() {
                            _editedContact.img = file.path;
                          });
                        }
                      } catch (e) {
                        print('Erro: $e');
                      }
                    }
                  }),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "Nome",
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                onChanged: (text) {
                  _userEdited;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "Phone",
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateAndSaveContact() async {
    if (_isValidName()) {
      await _saveContact();
    } else {
      _showError('Nome é obrigatório!');
      FocusScope.of(context).requestFocus(_nameFocus);
    }
  }

  bool _isValidName() {
    return _editedContact.name?.isNotEmpty ?? false;
  }

  Future<void> _saveContact() async {
    Navigator.pop(context, _editedContact);
  }

  void _showError(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<bool> _confirmExit(BuildContext context) async {
    if (_userEdited) {
      final confirmacao = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Sair"),
                content: Text("Deseja Descartar as alterações?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        overlayColor: Color(0xFFFF3737),
                      ),
                      child: Text(
                        "Não",
                        style: TextStyle(color: Color(0xFFFF3737)),
                      )),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style:
                          TextButton.styleFrom(overlayColor: Color(0xFF2196F3)),
                      child: Text(
                        "Sim",
                        style: TextStyle(color: Color(0xFF4682B4)),
                      )),
                ],
              ));
      return confirmacao ?? false;
    }
    return true;
  }
}
