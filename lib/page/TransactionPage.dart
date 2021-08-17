import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yellow_class/boxes.dart';
import '../model/transaction.dart';
import '../widget/TransactionDialog.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../res/custom_colors.dart';

class TransactionPage extends StatefulWidget {
  TransactionPage({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late User _user;
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie List',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        leading: Container(
          // width: 50,
          child: CircleAvatar(
            child: Image.network(
              _user.photoURL!,
              //fit: BoxFit.contain,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<Transaction>>(
        valueListenable: Boxes.getTransactions().listenable(),
        builder: (context, box, _) {
          final transactions = box.values.toList().cast<Transaction>();

          return buildContent(transactions);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.black,
        child: Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => TransactionDialog(
            onClickedDone: addTransaction,
          ),
        ),
      ),
    );
  }

  Widget buildContent(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  "assets/bg.png",
                ),
              ),
            ),
          ),
          SizedBox(
            height: 250,
          ),
          Container(
            padding: EdgeInsets.all(100),
            child: Text(
              'No Movies yet!',
              style: TextStyle(
                  backgroundColor: Colors.black54,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      );
    }
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                "assets/bg.png",
              ),
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: transactions.length,
                itemBuilder: (BuildContext context, int index) {
                  final transaction = transactions[index];

                  return buildTransaction(context, transaction);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget buildTransaction(
  BuildContext context,
  Transaction transaction,
) {
  return Card(
    color: Colors.black12,
    child: Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.file(
                    File(transaction.path),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Movie Name : ' + transaction.name,
                  maxLines: 2,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ),
              Center(
                child: Text(
                  'Directed By : ' + transaction.director,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              )
            ],
          ),
          children: [
            buildButtons(context, transaction),
          ],
        ),
      ],
    ),
  );
}

Widget buildButtons(BuildContext context, Transaction transactions) => Row(
      children: [
        Expanded(
          child: TextButton.icon(
            label: Text(
              'Edit',
              style: TextStyle(color: Colors.white),
            ),
            icon: Icon(
              Icons.edit,
              color: Colors.greenAccent,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransactionDialog(
                  transaction: transactions,
                  onClickedDone: (name, director, path) =>
                      editTransaction(transactions, name, director, path),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: TextButton.icon(
            label: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () => deleteTransaction(transactions),
          ),
        )
      ],
    );
Future addTransaction(String name, String director, String path) async {
  final transactions = Transaction()
    ..name = name
    ..director = director
    ..path = path;

  final box = Boxes.getTransactions();
  box.add(transactions);
}

void editTransaction(
  Transaction transactions,
  String name,
  String director,
  String path,
) {
  transactions.name = name;
  transactions.director = director;
  transactions.path = path;

  transactions.save();
}

void deleteTransaction(Transaction transactions) {
  transactions.delete();
}
