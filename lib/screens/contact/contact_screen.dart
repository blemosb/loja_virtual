import 'package:flutter/material.dart';
import 'package:loja_virtual/common/custom_drawer/custom_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class ContactScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    Future<void> send() async {
      final Email email = Email(
        body: "Descreva aqui suas dúvidas ou solicitações. Favor não alterar o texto do TÍTULO pois tenho um filtro para recebê-los do jeito que ele está.",
        subject: "APP para seu Negócio",
        recipients: ['blemosb@gmail.com'],
       // cc: ['cc@example.com'],
        //bcc: ['bcc@example.com'],
       // attachmentPaths: attachments,
        isHTML: false,
      );

      String platformResponse;

      try {
        await FlutterEmailSender.send(email);
        platformResponse = 'success';
      } catch (error) {
        platformResponse = error.toString();
      }

    }

    Future <void> _makingPhoneCall() async {
      const url = 'tel:21988890607';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        Flushbar(
          title: "Erro",
          message: "Este dispositivo não pode fazer chamadas",
          flushbarPosition: FlushbarPosition.BOTTOM,
          flushbarStyle: FlushbarStyle.GROUNDED,
          isDismissible: true,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          icon: Icon(Icons.error_outline_rounded, color: Colors.white,),
        ).show(context);

      }
    }

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text('Contato'),
        centerTitle: true,
      ),
      body: Column(
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              'Peça seu APP Agora',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: Colors.white
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
            child: Text(
              'Customize para sua necessidade',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image(image: AssetImage('images/money.png'))
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget> [
                Container(
                    height: 60.0,
                    child: GestureDetector(
                      onTap: _makingPhoneCall,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(60.0),
                          child: Image(image: AssetImage('images/tel.png'))
                      ),
                    ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Container(
                    height: 60.0,
                    child:ClipRRect(
                        borderRadius: BorderRadius.circular(60.0),
                        child: GestureDetector(
                          onTap: send,
                            child: Image(image: AssetImage('images/email.png')))
                    ),

                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
