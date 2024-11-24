class TwysheResourceQA {
  final String id;
  final String question;
  final String answer;


  const TwysheResourceQA({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory TwysheResourceQA.fromJson(Map<String, dynamic> json) {
    return TwysheResourceQA(
      id: (json['id'] ?? '') as String,
      question: (json['question'] ?? '') as String,
      answer: (json['answer'] ?? '') as String,
    );
  }
}
