import 'dart:io';

import 'package:flutter/cupertino.dart';

void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final readmeFile = File('README.md');

  // Extract package version from pubspec.yaml
  final versionMatch = RegExp(r'^version:\s*(\S+)', multiLine: true)
      .firstMatch(pubspec);

  if (versionMatch == null) {
    throw Exception('Version not found in pubspec.yaml');
  }

  final version = versionMatch.group(1)!;

  // Replace placeholder in README.md
  final updated = readmeFile
      .readAsStringSync()
      .replaceAllMapped(
    RegExp(r'sz_core:\s*\^[\d.]+'),
        (_) => 'sz_core: ^$version',
  );

  readmeFile.writeAsStringSync(updated);

  debugPrint('README updated to sz_core: ^$version');
}