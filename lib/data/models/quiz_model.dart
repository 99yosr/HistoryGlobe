class QuizQuestion {
  final String question;
  final List<String> options;
  final String answer; // stores the actual text of the correct option

  QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final options = List<String>.from(json['options']);

    // Convert answer letter -> index
    final letter = (json['answer'] as String).toLowerCase();
    final index = letter.codeUnitAt(0) - 'a'.codeUnitAt(0);

    return QuizQuestion(
      question: json['question'],
      options: options,
      answer: options[index], // ✔ convert to actual option text!
    );
  }
}
