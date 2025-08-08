import 'package:calendar_app/src/controller/matches_controller.dart';
import 'package:calendar_app/src/controller/teams_controller.dart';
import 'package:calendar_app/src/model/team.dart';
import 'package:flutter/material.dart';

class MatchCreation extends StatefulWidget {
  const MatchCreation({super.key});

  @override
  State<MatchCreation> createState() => _MatchCreationState();
}

class _MatchCreationState extends State<MatchCreation> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  Team? _homeTeam;
  Team? _awayTeam;

  late TeamController _teamController;
  late MatchController _matchController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _teamController = TeamController();
    _matchController = MatchController();
  }

  @override
  void dispose() {
    _titleController.dispose();
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

  String _generateMatchTitle() {
    if (_homeTeam != null && _awayTeam != null) {
      return '${_homeTeam!.name} vs ${_awayTeam!.name}';
    }
    return '';
  }

  Future<void> _createMatch() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _startTime == null || _endDate == null || _endTime == null) {
      setState(() {
        _errorMessage = 'Selecteer start- en einddatum/tijd';
      });
      return;
    }

    if (_homeTeam == null || _awayTeam == null) {
      setState(() {
        _errorMessage = 'Selecteer beide teams';
      });
      return;
    }

    if (_homeTeam!.id == _awayTeam!.id) {
      setState(() {
        _errorMessage = 'Een team kan niet tegen zichzelf spelen';
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

      // Call the actual API to create the match
      final matchTitle = _titleController.text.isNotEmpty
        ? _titleController.text
        : _generateMatchTitle();

      final success = await _matchController.createMatch(
        title: matchTitle,
        description: _descriptionController.text,
        datetimeStart: startDateTime,
        datetimeEnd: endDateTime,
        teamId: _homeTeam!.id, // Use home team as the main team
        metadata: {
          'homeTeamId': _homeTeam!.id,
          'awayTeamId': _awayTeam!.id,
          'matchType': 'team_vs_team',
        },
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wedstrijd "$matchTitle" succesvol aangemaakt!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fout bij aanmaken wedstrijd: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(24),
        constraints: BoxConstraints(maxWidth: 500, maxHeight: 700),
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
                        'Wedstrijd Aanmaken',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(Icons.sports_soccer, size: 28, color: colorScheme.primary),
                  ],
                ),
                SizedBox(height: 20),

                // Form content
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team selection
                      Text(
                        'Teams',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Home team selection
                      FutureBuilder<List<Team>>(
                        future: Future.value(_teamController.userTeams),
                        builder: (context, snapshot) {
                          final teams = snapshot.data ?? [];
                          if (teams.isEmpty) {
                            return Text('Geen teams beschikbaar');
                          }

                          return DropdownButtonFormField<Team>(
                            value: _homeTeam,
                            decoration: InputDecoration(
                              labelText: 'Thuis Team',
                              prefixIcon: Icon(Icons.home),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: colorScheme.surface,
                            ),
                            items: teams.map((team) {
                              return DropdownMenuItem<Team>(
                                value: team,
                                child: Text(team.name),
                              );
                            }).toList(),
                            onChanged: (Team? newValue) {
                              setState(() {
                                _homeTeam = newValue;
                                // Auto-generate title when teams change
                                if (_titleController.text.isEmpty) {
                                  _titleController.text = _generateMatchTitle();
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecteer thuis team';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 16),

                      // VS indicator
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'VS',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Away team selection
                      FutureBuilder<List<Team>>(
                        future: Future.value(_teamController.userTeams),
                        builder: (context, snapshot) {
                          final teams = snapshot.data ?? [];
                          if (teams.isEmpty) {
                            return Text('Geen teams beschikbaar');
                          }

                          return DropdownButtonFormField<Team>(
                            value: _awayTeam,
                            decoration: InputDecoration(
                              labelText: 'Uit Team',
                              prefixIcon: Icon(Icons.flight_takeoff),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: colorScheme.surface,
                            ),
                            items: teams.map((team) {
                              return DropdownMenuItem<Team>(
                                value: team,
                                child: Text(team.name),
                              );
                            }).toList(),
                            onChanged: (Team? newValue) {
                              setState(() {
                                _awayTeam = newValue;
                                // Auto-generate title when teams change
                                if (_titleController.text.isEmpty) {
                                  _titleController.text = _generateMatchTitle();
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecteer uit team';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 24),

                      // Match title field (optional, auto-generated)
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Wedstrijd Naam (optioneel)',
                          hintText: 'Wordt automatisch gegenereerd',
                          prefixIcon: Icon(Icons.sports),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Beschrijving',
                          hintText: 'Voer een beschrijving in',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Voer een beschrijving in';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),

                      // Date and time selection
                      Text(
                        'Wedstrijd Schema',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),

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
                      onPressed: _isLoading ? null : _createMatch,
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
                        : Text('Maak Wedstrijd Aan'),
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
