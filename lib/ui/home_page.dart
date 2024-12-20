import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ContactHelper _helper = ContactHelper();
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _helper.getAllContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contatos"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderaz,
                child: Text("Ordenar de A-Z"),
              ),
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderza,
                child: Text("Ordenar de Z-A"),
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _showContactPage,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: _buildContactList(),
    );
  }

  Widget _buildContactList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        return _contactCard(context, index);
      },
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    final contact = _contacts[index];
    return GestureDetector(
      onTap: () {
        _showOptions(context, index);
      },
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              _buildImage(contact),
              const SizedBox(width: 10),
              _buildContactInfo(contact),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(Contact contact) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: contact.img != null
              ? FileImage(File(contact.img!))
              : const AssetImage("images/person.png"),
        ),
      ),
    );
  }

  Widget _buildContactInfo(Contact contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          contact.name ?? "",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(contact.email ?? "", style: const TextStyle(fontSize: 18)),
        Text(contact.phone ?? "", style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  void _showContactPage({Contact? contact}) async {
    try {
      final newContact = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)),
      );

      if (newContact != null) {
        await _saveOrAtualizeContact(newContact, contact);
        _loadContacts();
      }
    } on SocketException {
      _showError('Erro de conexão');
    } on HttpException {
      _showError('Erro de servidor');
    } catch (e) {
      _showError('Erro inesperado');
    }
  }

  void _editContact(int index) {
    final Contact contatoSelecionado = _contacts[index];
    _showContactPage(contact: contatoSelecionado);
  }

  void _showError(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _saveOrAtualizeContact(
      Contact novoContato, Contact? contatoExistente) async {
    if (contatoExistente != null) {
      await _helper.updateContact(novoContato);
    } else {
      await _helper.saveContact(novoContato);
    }
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        child:
                            Text("Ligar", style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          launchUrl(Uri.parse("tel:${_contacts[index].phone}"));
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        child:
                            Text("Editar", style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.pop(context);
                          _editContact(index);
                        },
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        child: Text("Excluir",
                            style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          _helper.deleteContact(_contacts[index].id);
                          setState(() {
                            _contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        _contacts.sort((a, b) {
          var nomeA = a.name?.toLowerCase() ?? '';
          var nomeB = b.name?.toLowerCase() ?? '';
          return nomeA.compareTo(nomeB);
        });
        break;
      case OrderOptions.orderza:
        _contacts.sort((a, b) {
          var nomeA = a.name?.toLowerCase() ?? '';
          var nomeB = b.name?.toLowerCase() ?? '';
          return nomeB.compareTo(nomeA);
        });
        break;
    }
    setState(() {});
  }
}
