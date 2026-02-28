import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('===========================================================');
  print('      FYP AUTOMATED SYSTEM LOGIC TEST REPORT               ');
  print('===========================================================');
  print('Running Test Suite: Functional Requirements & Models       ');
  print('-----------------------------------------------------------');

  // Instead of relying on bash redirection which breaks encoding in PowerShell,
  // we run the process directly from Dart and read stdout bytes directly.
  final process = await Process.start(
    'flutter',
    ['test', '--machine'],
    runInShell: true,
  );

  final testCases = <int, Map<String, dynamic>>{};
  int passedCount = 0;
  int failedCount = 0;
  int tcNumber = 1;

  // We accumulate lines by bytes and decode via utf8 to preserve all chars
  process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    if (line.trim().isEmpty) return;

    try {
      if (line.startsWith('[{')) {
        line = line.substring(line.indexOf('{'));
        if (line.endsWith(']')) line = line.substring(0, line.length - 1);
      }

      final event = jsonDecode(line);

      if (event['type'] == 'testStart') {
        final test = event['test'];
        final id = test['id'] as int;
        final name = test['name'] as String;

        if (!name.startsWith('loading ') &&
            name != 'setUpAll' &&
            name != 'tearDownAll') {
          testCases[id] = {
            'name': name,
            'status': 'RUNNING',
          };
        }
      } else if (event['type'] == 'testDone') {
        final testID = event['testID'] as int;
        if (testCases.containsKey(testID)) {
          final result = event['result'] as String;
          final skipped = event['skipped'] as bool;

          if (skipped) {
            testCases[testID]!['status'] = 'SKIPPED';
          } else if (result == 'success' || result == 'failure') {
            final isSuccess = result == 'success';
            testCases[testID]!['status'] = isSuccess ? 'PASSED' : 'FAILED';
            if (isSuccess) {
              passedCount++;
            } else {
              failedCount++;
            }

            String displayName = testCases[testID]!['name'];
            if (displayName.contains('FoodItemModel')) {
              displayName = '[FoodItem] ' +
                  displayName.replaceAll('FoodItemModel Tests ', '');
            } else if (displayName.contains('MealModel')) {
              displayName =
                  '[Meal] ' + displayName.replaceAll('MealModel Tests ', '');
            } else if (displayName.contains('[') && displayName.contains(']')) {
              displayName = displayName.substring(displayName.indexOf('['));
            } else {
              displayName = '[Logic] ' + displayName;
            }

            final tcPrefix = 'TC-${tcNumber.toString().padLeft(2, '0')}';
            if (isSuccess) {
              print('\x1B[32m✅ $tcPrefix $displayName: PASSED\x1B[0m');
            } else {
              print('\x1B[31m❌ $tcPrefix $displayName: FAILED\x1B[0m');
            }
            tcNumber++;
          }
        }
      }
    } catch (e) {
      // Ignore parse errors from non-json matches
    }
  });

  // Ignore stderr to keep output clean, unless you want debug info
  process.stderr.listen((data) {});

  await process.exitCode;

  print('-----------------------------------------------------------');
  print('Total Passed: $passedCount');
  print('Total Failed: $failedCount');
  print('===========================================================');
}
