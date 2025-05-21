import 'package:flutter/material.dart';

// 1. Modelo de Evento Simple
class Event {
  final String? id; // ID único del evento
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final String? description;
  final String? location;
  // Puedes añadir más campos como recurrencia, invitados, etc.

  Event({
    this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.color = Colors.blue, // Color por defecto
    this.description,
    this.location,
  });

  factory Event.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Event(
      id: documentId,
      title: data['title'] ?? '',
      startTime: DateTime.parse(data['startTime']),
      endTime: DateTime.parse(data['endTime']),
      color: Color(data['color'] ?? Colors.blue.toARGB32()),
      description: data['description'],
      location: data['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color.toARGB32(),
      'description': description,
      'location': location,
    };
  }

  // Helper para saber si un evento ocurre en un día específico
  bool occursOnDate(DateTime date) {
    final eventStartDate = DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
    );
    final eventEndDate = DateTime(endTime.year, endTime.month, endTime.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return !checkDate.isBefore(eventStartDate) &&
        !checkDate.isAfter(eventEndDate);
  }
}
