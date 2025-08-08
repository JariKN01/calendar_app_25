import 'package:calendar_app/src/model/user.dart';
import 'package:flutter/material.dart';

class Team {
  final int id;
  late String name;
  late String? description;
  final int? ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  late Map<String, dynamic>? metadata;
  final List<User> members;

  // Map with icons to convert from string to icon
  static const Map<String, IconData> iconMap = {
    // Group is first because it's the default icon
    'group': Icons.group,
    'work': Icons.work,
    'family': Icons.family_restroom,
    'sports': Icons.sports_soccer,
    'church': Icons.church,
    'volunteer': Icons.volunteer_activism,
    'school': Icons.school,
    'music': Icons.music_note,
    'gaming': Icons.videogame_asset,
    'travel': Icons.flight,
    'gym': Icons.fitness_center,
    'calendar': Icons.calendar_month,
  };

  Team({
    required this.id,
    required this.name,
    this.description,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    required this.members,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    try {
      return Team(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        ownerId: json['ownerId'] as int?,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
        metadata: json['metadata'] as Map<String, dynamic>?,
        members: (json['members'] as List<dynamic>?)?.map((member) => User.fromJson(member)).toList() ?? [],
      );
    } catch (e) {
      // Include the original JSON map in the exception message
      throw FormatException("Failed to load team from JSON: $json. Error: $e");
    }
  }

  // Gets the icon, if it exists. Else show default group icon
  // Size is default 48 but can be changed if needed
  Widget getIcon({double size = 48}) {
    // Default Icon
    Widget? icon = Icon(iconMap.values.first, size: size);

    // If the icon is set store the string in this var
    final String? metadataIcon = metadata?['icon'] ?? metadata?['Icon'];

    // Checks if the metadata icon is set
    if (metadataIcon != null) {
      // Check if the metadata icon is a url, if so display it
      if (Uri.parse(metadataIcon).isAbsolute) {
        icon = Image.network(
          metadataIcon,
          width: size,
          height: size,
          // If the url isn't a valid url, show the broken image icon
          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: size),
        );
      }
      // Check if the icon comes from the icon map, assign the icon
      if (iconMap.containsKey(metadataIcon)) {
        icon = Icon(
          iconMap[metadataIcon],
          size: size,
        );
      }
    }

    return icon;
  }
}