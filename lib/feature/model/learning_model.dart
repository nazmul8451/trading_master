import 'package:flutter/material.dart';

class LessonModel {
  final String id;
  final String title;
  final String content;
  final String categoryId;
  final int estimatedMinutes;

  LessonModel({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.estimatedMinutes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'categoryId': categoryId,
    'estimatedMinutes': estimatedMinutes,
  };

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    categoryId: json['categoryId'],
    estimatedMinutes: json['estimatedMinutes'],
  );
}

class LearningCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<LessonModel> lessons;

  LearningCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.lessons,
  });
}
