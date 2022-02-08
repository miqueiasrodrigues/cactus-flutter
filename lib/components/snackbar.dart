import 'package:flutter/material.dart';

class Snackbar {
  Future<void> snackbar(
      String _text, BuildContext _context, bool _error) async {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 2000),
        content: Text(_text),
        backgroundColor: (_error != true) ? Colors.green[600] : Colors.red[700],
      ),
    );
  }

  Future<void> snackbarFloat(
      String _text, BuildContext _context, bool _error) async {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 300,
        duration: Duration(milliseconds: 2000),
        content: Text(_text),
        backgroundColor: (_error != true) ? Colors.green[600] : Colors.red[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    );
  }
}
