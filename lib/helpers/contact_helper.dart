import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactHelper {
  static final ContactHelper _instance = ContactHelper._();

  factory ContactHelper() => _instance;

  ContactHelper._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'contactsnew.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE contactTable (
            idColumn INTEGER PRIMARY KEY,
            nameColumn TEXT,
            emailColumn TEXT,
            phoneColumn TEXT,
            imgColumn TEXT
          )
        ''');
      },
    );
  }

  Future<Contact> saveContact(Contact contact) async {
    try {
      final dbContact = await db;
      contact.id = await dbContact.insert('contactTable', contact.toMap());
      return contact;
    } catch (e) {
      // Lidar com erros
      rethrow;
    }
  }

  Future<Contact?> getContact(int id) async {
    try {
      final dbContact = await db;
      final maps = await dbContact.query(
        'contactTable',
        columns: [
          'idColumn',
          'nameColumn',
          'emailColumn',
          'phoneColumn',
          'imgColumn'
        ],
        where: 'idColumn = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Contact.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      // Lidar com erros
      rethrow;
    }
  }

  Future<bool> deleteContact(int? id) async {
    try {
      if (id == null) {
        throw Exception('ID do contato é nulo');
      }
      final dbContact = await db;
      final rowsAffected = await dbContact.delete(
        'contactTable',
        where: 'idColumn = ?',
        whereArgs: [id],
      );
      return rowsAffected > 0;
    } catch (e) {
      print('Erro ao excluir contato: $e');
      rethrow;
    }
  }

  Future<int> updateContact(Contact contact) async {
    try {
      final dbContact = await db;
      return await dbContact.update(
        'contactTable',
        contact.toMap(),
        where: 'idColumn = ?',
        whereArgs: [(contact.id)],
      );
    } catch (e) {
      // Lidar com erros
      rethrow;
    }
  }

  Future<List<Contact>> getAllContacts() async {
    try {
      final dbContact = await db;
      final listMap = await dbContact.rawQuery('SELECT * FROM contactTable');
      return listMap.map((map) => Contact.fromMap(map)).toList();
    } catch (e) {
      // Lidar com erros
      rethrow;
    }
  }

  Future<int> getNumber() async {
    try {
      final dbContact = await db;
      final count =
          await dbContact.rawQuery('SELECT COUNT(*) FROM contactTable');
      return Sqflite.firstIntValue(count) ?? 0;
    } catch (e) {
      // Lidar com erros
      rethrow;
    }
  }

  Future<void> close() async {
    final dbContact = await db;
    await dbContact.close();
  }
}

class Contact {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  Contact({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.img,
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['idColumn'],
      name: map['nameColumn'],
      email: map['emailColumn'],
      phone: map['phoneColumn'],
      img: map['imgColumn'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idColumn': id,
      'nameColumn': name,
      'emailColumn': email,
      'phoneColumn': phone,
      'imgColumn': img,
    };
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)';
  }
}
