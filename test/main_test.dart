@Timeout(Duration(seconds: 1000))

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() async {
  test("wewe", () async {
// Function to get the total duration of the video using FFprobe
    Future<int?> getVideoDuration(String inputFile) async {
      var result = await Process.run('ffprobe', [
        '-v',
        'error',
        '-show_entries',
        'format=duration',
        '-of',
        'default=noprint_wrappers=1:nokey=1',
        inputFile
      ]);

      if (result.exitCode == 0) {
        double? duration = double.tryParse(result.stdout.trim());
        return duration?.round();
      } else {
        print('Error getting video duration: ${result.stderr}');
        return null;
      }
    }

    String inputFile = 'DEMO_GOT_CLIP.mp4';
    String outputFile = 'output.mp4';

    // Get the total duration of the input video
    int? totalDuration = await getVideoDuration(inputFile);

    if (totalDuration == null) {
      print('Failed to get video duration.');
      return;
    }

    print('Total Duration: $totalDuration seconds');

    // FFmpeg command and arguments
    var ffmpegArgs = ['-i', inputFile, '-progress', 'pipe:1', outputFile];

    // Start the FFmpeg process
    var process = await Process.start('ffmpeg', ffmpegArgs);

    // Listen to the standard error stream (stderr) for progress information
    var errors =
        process.stderr.transform(utf8.decoder).transform(const LineSplitter());

    // Listen to the error stream and parse the output
    errors.listen((line) {
      // Parse the progress information
      if (line.startsWith('out_time=')) {
        var timeMatch =
            RegExp(r'out_time=(\d+):(\d+):(\d+)\.(\d+)').firstMatch(line);
        if (timeMatch != null) {
          int hours = int.parse(timeMatch.group(1)!);
          int minutes = int.parse(timeMatch.group(2)!);
          int seconds = int.parse(timeMatch.group(3)!);
          int currentTime = hours * 3600 + minutes * 60 + seconds;

          // Calculate the progress percentage
          double percentage = (currentTime / totalDuration) * 100;
          print('Progress: ${percentage.toStringAsFixed(2)}%');
        }
      }

      // Handle other stderr lines
      print('FFmpeg output: $line');
    });

    // Wait for the process to complete
    await process.exitCode;
  });
}
