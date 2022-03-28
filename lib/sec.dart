import 'package:flutter/material.dart';


class SecPage extends StatelessWidget {
  // final String? payload;
  // const SecPage({
  //   Key? key,
  //   required this.payload,
  // }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Sec Page'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Text(
          /*payload ?? */' \n Heyyy! Notify Data',
          style: TextStyle(
            fontSize: 20,
            color: Colors.lightBlueAccent,
          ),
        ),
      ),
    );
  }

}
