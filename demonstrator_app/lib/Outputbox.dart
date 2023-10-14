import 'package:demonstrator_app/Checkboxes.dart';
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
          child: Container(
            color: Colors.blue,
          ),
        )
      ],
    );
  }
}