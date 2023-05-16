import 'package:flutter/material.dart';

class QuizOption extends StatelessWidget {
  final int index;
  final List<int> selectedAnswers;
  final String answer;
  final List<dynamic> correctAnswer;
  final bool showAnswer;

  const QuizOption({
    Key? key,
    required this.index,
    required this.selectedAnswers,
    required this.answer,
    required this.correctAnswer,
    required this.showAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screen = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        border: Border.all(
          color:
          (showAnswer)?
             (correctAnswer.contains(answer)?
              Colors.green : theme.primaryColor)          
          :          
          ((this.selectedAnswers.contains(index))
              ? theme.primaryColor
              : Colors.white),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: screen.width * 0.75,
            child: Text(
              answer,
              maxLines: 5,
              style: TextStyle(
                color: (this.selectedAnswers.contains(index))
                    ? Colors.white
                    : theme.primaryColor,
                fontSize: 14.0,
              ),
            ),
          ),          
          if(showAnswer)
            if(correctAnswer.contains(answer))
              Icon(Icons.check_circle_outline, color: Colors.green),          
          if(!showAnswer)
          Icon((this.selectedAnswers.contains(index))
                ? Icons.check_circle_outline
                : Icons.panorama_fish_eye,
            color:(this.selectedAnswers.contains(index))
                ? Colors.white
                : theme.primaryColor,
          )
        ],
      ),
    );
  }
}
