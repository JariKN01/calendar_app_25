import 'package:calendar_app/src/controller/events_controller.dart';
import 'package:calendar_app/src/controller/teams_controller.dart';
import 'package:calendar_app/src/model/event.dart';
import 'package:calendar_app/src/model/team.dart';
import 'package:flutter/material.dart';

class EventUpdate extends StatefulWidget{
  final Event event;
  final EventController controller;

  const EventUpdate({
    super.key, 
    required this.event,
    required this.controller,
  });

  @override
  State<EventUpdate> createState() => _EventUpdateState();
}

class _EventUpdateState extends State<EventUpdate> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  Team? _selectedTeam;

  late TeamController _teamController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _teamController = TeamController();

    // Initialize with existing event data
    _nameController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);

    _startDate = DateTime(
      widget.event.datetimeStart.year,
      widget.event.datetimeStart.month,
      widget.event.datetimeStart.day,
    );
    _startTime = TimeOfDay(
      hour: widget.event.datetimeStart.hour,
      minute: widget.event.datetimeStart.minute,
    );

    _endDate = DateTime(
      widget.event.datetimeEnd.year,
      widget.event.datetimeEnd.month,
      widget.event.datetimeEnd.day,
    );
    _endTime = TimeOfDay(
      hour: widget.event.datetimeEnd.hour,
      minute: widget.event.datetimeEnd.minute,
    );

    _selectedTeam = widget.event.team;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _startTime == null || _endDate == null || _endTime == null) {
      setState(() {
        _errorMessage = 'Selecteer start- en eindatum/tijd';
      });
      return;
    }

    if (_selectedTeam == null) {
      setState(() {
        _errorMessage = 'Selecteer een team';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      if (endDateTime.isBefore(startDateTime)) {
        setState(() {
          _errorMessage = 'Einddatum moet na startdatum zijn';
          _isLoading = false;
        });
        return;
      }

      // TODO: Implement updateEvent method in EventController
      // For now, just show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evenement "${_nameController.text}" bijgewerkt!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
      Navigator.pop(context); // Close both dialogs
    } catch (e) {
      setState(() {
        _errorMessage = 'Fout bij bijwerken evenement: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(24),
        constraints: BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button and title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 28),
                      tooltip: 'Sluiten',
                    ),
                    Expanded(
                      child: Text(
                        'Evenement Bewerken',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
                SizedBox(height: 20),

                // Form content
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Evenement Naam',
                          hintText: 'Voer de naam van het evenement in',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Voer een naam in';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Evenement Beschrijving',
                          hintText: 'Voer een beschrijving in',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Voer een beschrijving in';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Team selection (read-only for update)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.group, color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 12),
                            Text(
                              'Team: ${_selectedTeam?.name ?? 'Onbekend'}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Date and time selection
                      Text(
                        'Start Datum & Tijd',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectStartDate,
                              icon: Icon(Icons.calendar_today),
                              label: Text(_startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : 'Startdatum'),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectStartTime,
                              icon: Icon(Icons.access_time),
                              label: Text(_startTime != null
                                ? '${_startTime!.hour}:${_startTime!.minute.toString().padLeft(2, '0')}'
                                : 'Starttijd'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      Text(
                        'Eind Datum & Tijd',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectEndDate,
                              icon: Icon(Icons.calendar_today),
                              label: Text(_endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'Einddatum'),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectEndTime,
                              icon: Icon(Icons.access_time),
                              label: Text(_endTime != null
                                ? '${_endTime!.hour}:${_endTime!.minute.toString().padLeft(2, '0')}'
                                : 'Eindtijd'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text('Annuleren'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateEvent,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Bijwerken'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}