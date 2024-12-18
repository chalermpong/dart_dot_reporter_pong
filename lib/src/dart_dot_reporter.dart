import 'dart:io';

import 'package:dart_dot_reporter_pong/src/dot_reporter.dart';
import 'package:dart_dot_reporter_pong/src/parser.dart';


void run({
  required String path,
  bool FAIL_SKIPPED = false,
  bool SHOW_SUCCESS = false,
  bool HIDE_SKIPPED = false,
  bool SHOW_ID = false,
  bool SHOW_MESSAGE = false,
  bool NO_COLOR = false,
}) async {
  final parser = Parser();

  await parser.parseFile(path);

  DotReporter(
    parser: parser,
    showSuccess: SHOW_SUCCESS,
    hideSkipped: HIDE_SKIPPED,
    failSkipped: FAIL_SKIPPED,
    showId: SHOW_ID,
    showMessage: SHOW_MESSAGE,
    noColor: NO_COLOR,
    out: stdout,
  ).printReport();
}
