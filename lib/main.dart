

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './widgets/chart.dart';
import './models/transaction.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp
  ],);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expenses',
      theme: ThemeData(
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
                subtitle1: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                button: TextStyle(color: Colors.white),
              ),
          appBarTheme: AppBarTheme(

            textTheme: ThemeData.light().textTheme.copyWith(
                  subtitle1: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple).copyWith(secondary: Colors.amber)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // String titleInput;
  // String amountInput;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'New Shoes',
    //   amount: 69.99,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Weekly Groceries',
    //   amount: 16.53,
    //   date: DateTime.now(),
    // ),
  ];

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }
  bool _showChart=false;


  @override
  Widget build(BuildContext context) {
    final mb=MediaQuery.of(context);
    final bool isLandScape =mb.orientation==Orientation.landscape;
     PreferredSizeWidget appBar(){
       if(Platform.isIOS){
      return CupertinoNavigationBar(
        middle: Text(
          'Personal Expenses',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              child: Icon(CupertinoIcons.add),
              onTap: () => _startAddNewTransaction(context),
            ),
          ],
        ),
      );
     }
     else{
       return AppBar(
       title: Text(
       'Personal Expenses',
    ),
    actions: <Widget>[
    IconButton(
    icon: Icon(Icons.add),
    onPressed: () => _startAddNewTransaction(context),
    ),
    ],
    );
    }}

    final contentBody=SafeArea(child:SingleChildScrollView(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if(!isLandScape)
            Container(height:(mb.size.height -appBar().preferredSize.height-mb.padding.top)*0.3 ,
                child: Chart(_recentTransactions)),
          if(!isLandScape)
            Container(height: (mb.size.height -appBar().preferredSize.height-mb.padding.top)*0.7 ,child: TransactionList(_userTransactions, _deleteTransaction)),

          if(isLandScape)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Show Chart',style: Theme.of(context).textTheme.subtitle1,),
                Switch.adaptive(value: _showChart,
                    onChanged: (newVal){
                      setState(() {
                        _showChart=newVal;
                      });
                    }),
              ],
            ),
          if(isLandScape)_showChart?
          Container(height:(mb.size.height -appBar().preferredSize.height-mb.padding.top)*0.7 ,
              child: Chart(_recentTransactions))

              : Container(height: (mb.size.height -appBar().preferredSize.height-mb.padding.top)*0.7 ,child: TransactionList(_userTransactions, _deleteTransaction)),

        ],
      ),
    ));

    return Platform.isIOS?CupertinoPageScaffold(
        navigationBar: appBar() as  ObstructingPreferredSizeWidget,
        child: contentBody):
    Scaffold(
      appBar: appBar(),
      body: contentBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:Platform.isIOS?Container(): FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
