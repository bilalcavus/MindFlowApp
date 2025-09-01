import 'package:flutter/material.dart';

class SnackMessages {
  void showErrorSnack(String message, BuildContext context){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}