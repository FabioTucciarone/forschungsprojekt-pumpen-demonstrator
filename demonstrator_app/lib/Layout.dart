import 'package:flutter/material.dart';
import 'MainScreen.dart';

class Introduction extends StatelessWidget {
  const Introduction({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IntroHomeScaffold(),
    );
  }
  
  
}

class IntroHomeScaffold extends StatelessWidget {
  const IntroHomeScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demonstrator App"),
        leading: const IconButton(icon: Icon(Icons.arrow_back), onPressed: null,),
      ),
      backgroundColor: const Color.fromARGB(255, 159, 151, 174),
      body: Column(  
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Hier kommt der Einführungstext hin",textScaleFactor: 4,),
          const SizedBox(height: 100,),
          ElevatedButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const MainSlide()
                ));
            },
            child: const Text("Los geht's")
          )
        ],
        ),
    );
  }
}

