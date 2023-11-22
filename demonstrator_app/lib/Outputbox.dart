import 'package:demonstrator_app/Checkboxes.dart';
import 'package:demonstrator_app/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OutputBox extends StatelessWidget {
  const OutputBox({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final checkBoxModel = Provider.of<CheckboxModel>(context);
    final isChecked1 = checkBoxModel.isChecked1;
    final isChecked2 = checkBoxModel.isChecked2;
    final Future<String> future = context.watch<FutureNotifier>().future;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$name",
          textScaleFactor: 2,
        ),
        Text("Checkbox1 is ${isChecked1 ? 'checked' : 'not checked'}"),
        Text("Checkbox2 is ${isChecked2 ? 'checked' : 'not checked'}"),
        SizedBox(
          height: 100,
          //child: Image.network('http://127.0.0.1:5000/last_model_result.png'))
          child: FutureBuilder<String>(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  child = Container(
                    width: 300,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'ERROR',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                  print('Error ${snapshot.error} occured');
                } else {
                  if (snapshot.data == "keinWert") {
                    child = const Text("Kein Wert bis jetzt");
                  } else {
                    child = Image.network(
                        'http://127.0.0.1:5000/last_model_result.png');
                  }
                }
              } else {
                child = const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                );
              }
              return child;
            },
          ),
        ),
      ],
    );
  }
}
