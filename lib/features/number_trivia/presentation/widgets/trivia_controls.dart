import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/number_trivia_cubit.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({super.key});

  @override
  State<StatefulWidget> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  late String inputStr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            inputStr = value;
          },
          onSubmitted: (_) => _getConcreteTrivia(inputStr),
        ),
        SizedBox(height: 10.0),
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white),
                  foregroundColor: WidgetStatePropertyAll(Colors.blue),
                ),
                child: Text('Search'),
                onPressed: () {
                  _getConcreteTrivia(inputStr);
                },
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                child: Text('Get Random Trivia'),
                onPressed: () {
                  _getRandomTrivia();
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  void _getConcreteTrivia(String inputStr) {
    controller.clear();
    context.read<NumberTriviaCubit>().getTriviaForConcreteNumber(inputStr);
  }

  void _getRandomTrivia() {
    controller.clear();
    context.read<NumberTriviaCubit>().getTriviaForRandomNumber();
  }
}
