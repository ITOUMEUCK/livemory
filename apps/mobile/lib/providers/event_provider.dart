import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();

  List<Event> _events = [];
  Event? _currentEvent;
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  Event? get currentEvent => _currentEvent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _eventService.getMyEvents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEvent(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentEvent = await _eventService.getEventById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Event?> createEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newEvent = await _eventService.createEvent(event);
      _events.add(newEvent);
      _currentEvent = newEvent;
      _isLoading = false;
      notifyListeners();
      return newEvent;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Event?> updateEvent(String id, Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEvent = await _eventService.updateEvent(id, event);
      final index = _events.indexWhere((e) => e.id == id);
      if (index != -1) {
        _events[index] = updatedEvent;
      }
      if (_currentEvent?.id == id) {
        _currentEvent = updatedEvent;
      }
      _isLoading = false;
      notifyListeners();
      return updatedEvent;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteEvent(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.deleteEvent(id);
      _events.removeWhere((e) => e.id == id);
      if (_currentEvent?.id == id) {
        _currentEvent = null;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<EventStep?> addStep(String eventId, EventStep step) async {
    try {
      final newStep = await _eventService.addStep(eventId, step);
      if (_currentEvent?.id == eventId) {
        _currentEvent = _currentEvent!.copyWith(
          steps: [..._currentEvent!.steps, newStep],
        );
        notifyListeners();
      }
      return newStep;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteStep(String eventId, String stepId) async {
    try {
      await _eventService.deleteStep(eventId, stepId);
      if (_currentEvent?.id == eventId) {
        _currentEvent = _currentEvent!.copyWith(
          steps: _currentEvent!.steps.where((s) => s.id != stepId).toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setCurrentEvent(Event? event) {
    _currentEvent = event;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
