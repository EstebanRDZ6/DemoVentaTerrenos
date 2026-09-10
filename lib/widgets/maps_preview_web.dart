// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class GoogleMapsPreview extends StatelessWidget {
  const GoogleMapsPreview({super.key});

  static const String _viewType = 'sitios-propiedades-google-map';
  static bool _registered = false;

  static void _registerFactory() {
    if (_registered) {
      return;
    }

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final html.IFrameElement iframe = html.IFrameElement()
        ..src = 'https://maps.google.com/maps?q=-27.3703386,-55.9025746&z=17&output=embed'
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true
        ..referrerPolicy = 'no-referrer-when-downgrade';
      return iframe;
    });

    _registered = true;
  }

  @override
  Widget build(BuildContext context) {
    _registerFactory();
    return const HtmlElementView(viewType: _viewType);
  }
}
