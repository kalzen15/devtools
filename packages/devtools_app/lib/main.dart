// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/analytics/analytics_controller.dart';
import 'src/app.dart';
import 'src/config_specific/framework_initialize/framework_initialize.dart';
import 'src/config_specific/ide_theme/ide_theme.dart';
import 'src/debugger/syntax_highlighter.dart';
import 'src/extension_points/extensions_base.dart';
import 'src/extension_points/extensions_external.dart';
import 'src/provider/riverpod_error_logger_observer.dart';
import 'src/shared/app_error_handling.dart';
import 'src/shared/globals.dart';
import 'src/shared/preferences.dart';

void main() async {
  // Initialize the framework before we do anything else, otherwise the
  // StorageController won't be initialized and preferences won't be loaded.
  await initializeFramework();

  final preferences = PreferencesController();
  // Wait for preferences to load before rendering the app to avoid a flash of
  // content with the incorrect theme.
  await preferences.init();

  // Load the Dart syntax highlighting grammar.
  await SyntaxHighlighter.initialize();

  // Set the extension points global.
  setGlobal(DevToolsExtensionPoints, ExternalDevToolsExtensionPoints());
  setGlobal(IdeTheme, getIdeTheme());

  setupErrorHandling(() async {
    // Run the app.
    runApp(
      ProviderScope(
        observers: const [ErrorLoggerObserver()],
        child: DevToolsApp(defaultScreens, await analyticsController),
      ),
    );
  });
}
