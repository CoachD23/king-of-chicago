import 'package:equatable/equatable.dart';

class DialogueLine extends Equatable {
  final String speaker;
  final String line;

  const DialogueLine({
    required this.speaker,
    required this.line,
  });

  @override
  List<Object?> get props => [speaker, line];
}

class Choice extends Equatable {
  final String id;
  final String line;
  final Map<String, int> veils;
  final Map<String, int>? heat;
  final Map<String, int>? requires;
  final Map<String, int>? npcDeltas;
  final String next;
  final bool hidden;

  const Choice({
    required this.id,
    required this.line,
    required this.veils,
    this.heat,
    this.requires,
    this.npcDeltas,
    required this.next,
    this.hidden = false,
  });

  @override
  List<Object?> get props => [
        id,
        line,
        veils,
        heat,
        requires,
        npcDeltas,
        next,
        hidden,
      ];
}

class Scene extends Equatable {
  final String id;
  final String location;
  final List<String> characters;
  final String mood;
  final List<DialogueLine> dialogue;
  final List<Choice> choices;
  final String? type;

  const Scene({
    required this.id,
    required this.location,
    required this.characters,
    required this.mood,
    required this.dialogue,
    required this.choices,
    this.type,
  });

  @override
  List<Object?> get props => [
        id,
        location,
        characters,
        mood,
        dialogue,
        choices,
        type,
      ];
}
