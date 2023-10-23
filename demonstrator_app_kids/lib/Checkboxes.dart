import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckboxModel extends ChangeNotifier {
  bool _isChecked1 = false;
  bool _isChecked2 = false;

  bool get isChecked1 => _isChecked1;
  bool get isChecked2 => _isChecked2;

  void setChecked1(bool value) {
    _isChecked1 = value;
    _isChecked2 = !value;
    notifyListeners();
  }

  void setChecked2(bool value) {
    _isChecked2 = value;
    _isChecked1 = !value;
    notifyListeners();
  }
}

class CheckboxBox extends StatefulWidget {
  const CheckboxBox({super.key});

  @override
  State<CheckboxBox> createState() => _CheckboxBoxState();
}

class _CheckboxBoxState extends State<CheckboxBox> {
  @override
  Widget build(BuildContext context) {
    final checkBoxModel = Provider.of<CheckboxModel>(context);

    return ColoredBox(
      color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text(
            "Modell",
            textScaleFactor: 2,
          ),
          Column(
            children: [
              const Text(
                "Neuronales Netzwerk 1",
                textScaleFactor: 1.5,
              ),
              Checkbox(
                value: checkBoxModel._isChecked1,
                onChanged: (newBool) {
                  setState(() {
                    checkBoxModel.setChecked1(newBool!);
                    checkBoxModel.setChecked2(false);
                  });
                },
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                "Neuronales Netzwerk 2",
                textScaleFactor: 1.5,
              ),
              Checkbox(
                value: checkBoxModel.isChecked2,
                onChanged: (newBool) {
                  setState(() {
                    checkBoxModel.setChecked2(newBool!);
                    checkBoxModel.setChecked1(false);
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}