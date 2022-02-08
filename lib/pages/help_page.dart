import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Conectando-se'),
      ),
      body: IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Colors.white,
        globalHeader: Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
            ),
          ),
        ),

        pages: [
          PageViewModel(
            title: "Passo 1",
            body: "Selecione a cultura que deseja ativar.",
            image: Image.asset(
              'assets/images/1.png',
              width: 250,
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Passo 2",
            body:
                "Baixe o arquivo da cultura que está em \"código do arquivo\".",
            image: Image.asset(
              'assets/images/2.png',
              width: 250,
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Passo 3",
            body:
                "O arquivo estará dentro de uma pasta chamada \"Cactus\", em Downloads.",
            image: Image.asset(
              'assets/images/4.png',
              width: 250,
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Passo 4",
            body: "Renomeei o arquivo para \"conf.txt\", sem as aspas.",
            image: Image.asset(
              'assets/images/5.png',
              width: 250,
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Passo 5",
            body:
                "Com o arquivo renomeado, mova o arquivo para a raiz do cartão de memória.",
            image: Image.asset(
              'assets/images/7.png',
              width: 250,
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Passo 6",
            body:
                "Depois, com o protótipo desligado, insira o cartão de memória na entrada do módulo Micro Sd do protótipo.",
            image: Image.asset(
              'assets/images/9.png',
              width: 250,
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Passo 7",
            body:
                "Ligue o protótipo e espere alguns segundos para que a cultura ative.",
            image: Image.asset(
              'assets/images/8.png',
              width: 250,
            ),
            footer: Text(
              'O cartão de memória NÃO deve ser removido!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Pronto!",
            body: "Agora a sua cultura está totalmente integrada ao protótipo.",
            image: Image.asset(
              'assets/images/6.png',
              width: 250,
            ),
            decoration: pageDecoration,
          ),
        ],
        onDone: () => _onIntroEnd(context),
        //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: true,
        skipFlex: 0,
        nextFlex: 0,
        //rtl: true, // Display as right-to-left
        skip: const Text('Pular'),
        next: const Icon(Icons.arrow_forward),
        done:
            const Text('Fechar', style: TextStyle(fontWeight: FontWeight.w600)),
        curve: Curves.fastLinearToSlowEaseIn,
        color: Colors.black,

        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeColor: Colors.lightGreen,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        dotsContainerDecorator: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(),
        ),
      ),
    );
  }
}
