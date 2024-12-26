import 'dart:io';

import 'model.dart';
import 'parser.dart';

class DotReporter {
  final Parser parser;

  int failedCount = 0;
  int skippedCount = 0;
  int successCount = 0;

  // TODO: move flags to some config model
  final bool showId;
  final bool showSuccess;
  final bool hideSkipped;
  final bool failSkipped;
  final bool showMessage;
  final bool noColor;
  final Stdout out;

  DotReporter({
    required this.parser,
    this.showId = false,
    this.showSuccess = false,
    this.hideSkipped = false,
    this.failSkipped = false,
    this.showMessage = false,
    this.noColor = false,
    required this.out,
  });

  void printReport() {
    // Mutates results, used to remove invalid parsed data
    parser.tests.removeWhere((k, v) => v.state == null);

    _countTestResults();
    final resultIconsLine = _renderSingleLineOfIcons();
    final result = '${_renderShortResultLines()}${_renderFileNames()}';
    final filenames = _renderFileNames();

    _render(resultIconsLine, result, filenames);

    if (skippedCount > 0 && failSkipped) {
      exitCode = 1;
    }
    if (failedCount > 0) {
      exitCode = 2;
    }
  }

  void _render(String resultIconsLine, String result, String filenames) {
    out.write(resultIconsLine);

    out.writeln();
    out.writeln();

    out.write(result);

    out.writeln();

    out.writeAll(
      [
        'Total: ${parser.tests.length}',
        _green('Success: $successCount'),
        _yellow('Skipped: $skippedCount'),
        _red('Failure: $failedCount'),
      ],
      '\n',
    );
    out.writeln();
  }

  String _renderShortResultLines() {
    return parser.tests.values.where(filterTest).map(_testToString).join('\n');
  }

  String _renderFileNames() {
    final Set<String> filenames = Set.from(parser.tests.values
        .where(filterTest)
        .map((i) => _formatColor(i.state, i.filename)));

    if (filenames.isEmpty) {
      return '';
    }

    return '\n\n${filenames.join('\n')}';
  }

  bool filterTest(TestModel i) {
    final hideSuccess = !showSuccess && i.state == State.Success;
    final _hideSkipped = hideSkipped && i.state == State.Skipped;
    if (_hideSkipped) {
      return false;
    }
    if (hideSuccess) {
      return false;
    }

    return true;
  }

  String _renderSingleLineOfIcons() =>
      parser.tests.values.map(_getIcon).join('');

  void _countTestResults() {
    for (var item in parser.tests.values) {
      switch (item.state) {
        case State.Failure:
          failedCount += 1;
          break;
        case State.Skipped:
          skippedCount += 1;
          break;
        case State.Success:
          successCount += 1;
          break;
        default:
      }
    }
  }

  String _getIcon(TestModel model) {
    switch (model.state) {
      case State.Failure:
        return _red('X');
      case State.Skipped:
        return _yellow('!');
      case State.Success:
        return _green('.');
      default:
        return '?';
    }
  }

  String _testToString(TestModel model) {
    var base = '${_getIcon(model)} ';
    base += _formatColor(model.state, model.info);

    if (model.state == State.Failure && showMessage) {
      if (model.error != null) {
        base += '\n${model.error!}';
      }
      if (model.message != null) {
        base += '\n${model.message!}';
      }
    }
    if (showId) {
      return '${model.id} $base';
    }
    return base;
  }

  String _formatColor(State? state, String text) {
    switch (state) {
      case State.Failure:
        return _red(text);
      case State.Skipped:
        return _yellow(text);
      case State.Success:
        return _green(text);
      default:
        return text;
    }
  }

  String _red(String text) {
    if (noColor) {
      return text;
    }
    return '\x1B[31m$text\x1B[0m';
  }

  String _green(String text) {
    if (noColor) {
      return text;
    }
    return '\x1B[32m$text\x1B[0m';
  }

  String _yellow(String text) {
    if (noColor) {
      return text;
    }
    return '\x1B[33m$text\x1B[0m';
  }
}
