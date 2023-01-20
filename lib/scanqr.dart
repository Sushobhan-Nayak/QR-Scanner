// ignore_for_file: implementation_imports, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

String? apires;
Map? mapres;
String? valid;
String? entry;

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  Widget _buildPopupDialog1(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.green,
      title: const Text('User Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("FOUND",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 25)),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Close',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildPopupDialog2(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.red,
      title: const Text('User Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("NOT FOUND",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 25)),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget _buildPopupDialog3(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey,
      title: const Text('ERROR'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Connection Error.",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 25)),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Close',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  String qrcodeRES = "Not Yet Scanned !";
  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<void> barcodeScan() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      qrcodeRES = barcodeScanRes;
      apic();
      if (valid == "true" && entry == "false") {
        showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog1(context));
      } else if (valid == "false") {
        showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog2(context));
      }
      else if (valid == "true" && entry=="false" ) {
        showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog2(context));
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialog3(context));
      }
    });
  }

  Future apic() async {
    http.Response response;
    response = await http.get(Uri.parse("localhost:3000/validate/$qrcodeRES"));
    if (response.statusCode == 200) {
      setState(() {
        try {
          mapres = json.decode(response.body);
          valid = mapres!["valid"].toString();
          entry = mapres!["entry"].toString();
        } catch (e) {
          showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog3(context));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "SCAN QR CODE",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: SizedBox(
                height: 400,
                width: 400,
                child: Image.asset(
                  'images/new.png',
                )),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      "RESULT",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Text(
                      qrcodeRES,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: ElevatedButton(
                      onPressed: () => barcodeScan(),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.orange),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(color: Colors.black)))),
                      child: Text(
                        "Open Scanner",
                        style: TextStyle(fontSize: 30, color: Colors.black),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}