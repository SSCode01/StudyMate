import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool isWeb() => kIsWeb;

bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 700;
}
