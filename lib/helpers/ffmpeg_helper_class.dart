import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../ffmpeg_helper.dart';

class FFMpegHelper {
  static final FFMpegHelper _singleton = FFMpegHelper._internal();
  factory FFMpegHelper() => _singleton;
  FFMpegHelper._internal();
  static FFMpegHelper get instance => _singleton;

  //
  final String _windowsFfmpegUrl =
      "https://github.com/defensive-wizard/ffmpeg-builds/releases/download/7.0/ffmpeg-win64-gpl.zip";

  final String _macosFfmpegUrl =
      "https://github.com/defensive-wizard/ffmpeg-builds/releases/download/7.0/ffmpeg-macos-gpl.zip";
  String? _tempFolderPath;
  String? _ffmpegBinDirectory;
  String? _ffmpegInstallationPath;

  Future<void> initialize() async {
    if (Platform.isWindows || Platform.isMacOS) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appName = packageInfo.appName;
      Directory tempDir = await getTemporaryDirectory();
      _tempFolderPath = path.join(tempDir.path, "ffmpeg");
      Directory ffmpegInstallDir = await getApplicationDocumentsDirectory();
      _ffmpegInstallationPath =
          path.join(ffmpegInstallDir.path, appName, "ffmpeg");
      _ffmpegBinDirectory = path.join(_ffmpegInstallationPath!, "bin");
    }
  }

  Future<bool> isFFMpegPresent() async {
    if (Platform.isWindows) {
      if ((_ffmpegBinDirectory == null) || (_tempFolderPath == null)) {
        await initialize();
      }
      File ffmpeg = File(path.join(_ffmpegBinDirectory!, "ffmpeg.exe"));
      File ffprobe = File(path.join(_ffmpegBinDirectory!, "ffprobe.exe"));
      if ((await ffmpeg.exists()) && (await ffprobe.exists())) {
        return true;
      } else {
        return false;
      }
    } else if (Platform.isLinux) {
      try {
        Process process = await Process.start(
          'ffmpeg',
          ['--help'],
        );
        return await process.exitCode == ReturnCode.success;
      } catch (e) {
        return false;
      }
    } else if (Platform.isMacOS) {
      if ((_ffmpegBinDirectory == null) || (_tempFolderPath == null)) {
        await initialize();
      }
      File ffmpeg = File(path.join(_ffmpegBinDirectory!, "ffmpeg"));
      File ffprobe = File(path.join(_ffmpegBinDirectory!, "ffprobe"));
      if ((await ffmpeg.exists()) && (await ffprobe.exists())) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<void> extractZipFileIsolate(Map data) async {
    try {
      String? zipFilePath = data['zipFile'];
      String? targetPath = data['targetPath'];
      if ((zipFilePath != null) && (targetPath != null)) {
        await extractFileToDisk(zipFilePath, targetPath);
      }
    } catch (e) {
      return;
    }
  }

  Future<FFMpegHelperSession> runAsync(
    FFMpegCommand command, {
    Function(Statistics statistics)? statisticsCallback,
    Function(File? outputFile)? onComplete,
  }) async {
    return _runAsync(
      command,
      statisticsCallback: statisticsCallback,
      onComplete: onComplete,
    );
  }

  Future<FFMpegHelperSession> _runAsync(
    FFMpegCommand command, {
    Function(Statistics statistics)? statisticsCallback,
    Function(File? outputFile)? onComplete,
  }) async {
    Process process = await _startProcess(
      command,
      statisticsCallback: statisticsCallback,
    );

    process.exitCode.then((value) {
      if (value == ReturnCode.success) {
        onComplete?.call(File(command.outputFilepath));
      } else {
        onComplete?.call(null);
      }
    });

    return FFMpegHelperSession(
      windowSession: process,
      cancelSession: () async {
        process.kill();
      },
    );
  }

  Future<Process> _startProcess(
    FFMpegCommand command, {
    Function(Statistics statistics)? statisticsCallback,
  }) async {
    String ffmpeg = 'ffmpeg';
    if ((_ffmpegBinDirectory != null) && (Platform.isWindows)) {
      ffmpeg = path.join(_ffmpegBinDirectory!, "ffmpeg.exe");
    }
    if (_ffmpegBinDirectory != null && Platform.isMacOS) {
      ffmpeg = path.join(_ffmpegBinDirectory!, "ffmpeg");
    }

    Process process = await Process.start(
      ffmpeg,
      command.toCli(),
    );

    process.stdout.transform(utf8.decoder).listen((String event) {
      parseStats(event, process, statisticsCallback: statisticsCallback);
    });
    process.stderr.transform(utf8.decoder).listen((event) {
      parseStats(event, process, statisticsCallback: statisticsCallback);
    });
    return process;
  }

  double parseTimeString(String timeString) {
    var parts = timeString.split(':');
    double hours = double.parse(parts[0]);
    double minutes = double.parse(parts[1]);
    var secondsParts = parts[2].split('.');
    double seconds = double.parse(secondsParts[0]);
    double milliseconds = double.parse(secondsParts[1]);
    return hours * 3600 + minutes * 60 + seconds + milliseconds / 1000;
  }

  void parseStats(
    String line,
    Process process, {
    Function(Statistics statistics)? statisticsCallback,
  }) {
    try {
      if (line.startsWith('frame=')) {
        var stats = Statistics(0, 0, 0.0, 0, 0, 0.0, 0.0, 0);

        var frameMatch = RegExp(r'frame\s*=\s*(-?\d+)').firstMatch(line);
        var fpsMatch = RegExp(r'fps\s*=\s*(-?[\d.]+)').firstMatch(line);
        var qualityMatch = RegExp(r'q\s*=\s*(-?[\d.]+)')
            .firstMatch(line); // Adjusted for quality
        var sizeMatch = RegExp(r'size\s*=\s*([\d.]+)')
            .firstMatch(line); // Adjusted for size
        var timeMatch = RegExp(r'time\s*=\s*([\d:.]+)')
            .firstMatch(line); // Adjusted for time
        var bitrateMatch =
            RegExp(r'bitrate\s*=\s*(-?[\d.]+)kbits/s').firstMatch(line);
        var speedMatch = RegExp(r'speed\s*=\s*(-?[\d.]+)x').firstMatch(line);

        if (frameMatch != null) {
          stats.videoFrameNumber = int.parse(frameMatch.group(1)!);
        }
        if (fpsMatch != null) {
          stats.videoFps = double.parse(fpsMatch.group(1)!);
        }
        if (qualityMatch != null) {
          stats.videoQuality = double.parse(qualityMatch.group(1)!);
        }
        if (sizeMatch != null) {
          stats.size = int.parse(sizeMatch.group(1)!);
        }
        if (timeMatch != null) {
          stats.time = parseTimeString(timeMatch.group(1)!);
        }
        if (bitrateMatch != null) {
          stats.bitrate = double.parse(bitrateMatch.group(1)!);
        }
        if (speedMatch != null) {
          stats.speed = double.parse(speedMatch.group(1)!);
        }
        statisticsCallback?.call(stats);
      }
    } catch (e) {}
  }

  Future<MediaInformation?> runProbe(String filePath) async {
    return _runProbe(filePath);
  }

  Future<MediaInformation?> _runProbe(String filePath) async {
    String ffprobe = 'ffprobe';
    if (((_ffmpegBinDirectory != null) && (Platform.isWindows))) {
      ffprobe = path.join(_ffmpegBinDirectory!, "ffprobe.exe");
    }

    if (_ffmpegBinDirectory != null && Platform.isMacOS) {
      ffprobe = path.join(_ffmpegBinDirectory!, "ffprobe");
    }
    final result = await Process.run(ffprobe, [
      '-v',
      'quiet',
      '-print_format',
      'json',
      '-show_format',
      '-show_streams',
      '-show_chapters',
      filePath,
    ]);
    if (result.stdout == null ||
        result.stdout is! String ||
        (result.stdout as String).isEmpty) {
      return null;
    }

    if (result.exitCode == ReturnCode.success) {
      try {
        final json = jsonDecode(result.stdout);
        return MediaInformation(json);
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<bool> setupFFMpegOnWindows({
    CancelToken? cancelToken,
    void Function(FFMpegProgress progress)? onProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (Platform.isWindows) {
      if ((_ffmpegBinDirectory == null) || (_tempFolderPath == null)) {
        await initialize();
      }
      Directory tempDir = Directory(_tempFolderPath!);
      if (await tempDir.exists() == false) {
        await tempDir.create(recursive: true);
      }
      Directory installationDir = Directory(_ffmpegInstallationPath!);
      if (await installationDir.exists() == false) {
        await installationDir.create(recursive: true);
      }
      final String ffmpegZipPath = path.join(_tempFolderPath!, "ffmpeg.zip");
      final File tempZipFile = File(ffmpegZipPath);
      if (await tempZipFile.exists() == false) {
        try {
          Dio dio = Dio();
          Response response = await dio.download(
            _windowsFfmpegUrl,
            ffmpegZipPath,
            cancelToken: cancelToken,
            onReceiveProgress: (int received, int total) {
              onProgress?.call(FFMpegProgress(
                downloaded: received,
                fileSize: total,
                phase: FFMpegProgressPhase.downloading,
              ));
            },
            queryParameters: queryParameters,
          );
          if (response.statusCode == HttpStatus.ok) {
            onProgress?.call(FFMpegProgress(
              downloaded: 0,
              fileSize: 0,
              phase: FFMpegProgressPhase.decompressing,
            ));
            await compute(extractZipFileIsolate, {
              'zipFile': tempZipFile.path,
              'targetPath': _ffmpegInstallationPath,
            });
            onProgress?.call(FFMpegProgress(
              downloaded: 0,
              fileSize: 0,
              phase: FFMpegProgressPhase.inactive,
            ));
            return true;
          } else {
            onProgress?.call(FFMpegProgress(
              downloaded: 0,
              fileSize: 0,
              phase: FFMpegProgressPhase.inactive,
            ));
            return false;
          }
        } catch (e) {
          onProgress?.call(FFMpegProgress(
            downloaded: 0,
            fileSize: 0,
            phase: FFMpegProgressPhase.inactive,
          ));
          return false;
        }
      } else {
        onProgress?.call(FFMpegProgress(
          downloaded: 0,
          fileSize: 0,
          phase: FFMpegProgressPhase.decompressing,
        ));
        try {
          await compute(extractZipFileIsolate, {
            'zipFile': tempZipFile.path,
            'targetPath': _ffmpegInstallationPath,
          });
          onProgress?.call(FFMpegProgress(
            downloaded: 0,
            fileSize: 0,
            phase: FFMpegProgressPhase.inactive,
          ));
          return true;
        } catch (e) {
          onProgress?.call(FFMpegProgress(
            downloaded: 0,
            fileSize: 0,
            phase: FFMpegProgressPhase.inactive,
          ));
          return false;
        }
      }
    } else {
      onProgress?.call(FFMpegProgress(
        downloaded: 0,
        fileSize: 0,
        phase: FFMpegProgressPhase.inactive,
      ));
      return true;
    }
  }

  Future<bool> setupFFMpegOnMacOS({
    CancelToken? cancelToken,
    void Function(FFMpegProgress progress)? onProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    if ((_ffmpegBinDirectory == null) || (_tempFolderPath == null)) {
      await initialize();
    }
    Directory tempDir = Directory(_tempFolderPath!);
    if (await tempDir.exists() == false) {
      await tempDir.create(recursive: true);
    }
    Directory installationDir = Directory(_ffmpegInstallationPath!);
    if (await installationDir.exists() == false) {
      await installationDir.create(recursive: true);
    }
    final String ffmpegZipPath = path.join(_tempFolderPath!, "ffmpeg.zip");
    final File tempZipFile = File(ffmpegZipPath);
    if (await tempZipFile.exists() == false) {
      try {
        Dio dio = Dio();
        print(ffmpegZipPath);
        Response response = await dio.download(
          _macosFfmpegUrl,
          ffmpegZipPath,
          cancelToken: cancelToken,
          onReceiveProgress: (int received, int total) {
            onProgress?.call(FFMpegProgress(
              downloaded: received,
              fileSize: total,
              phase: FFMpegProgressPhase.downloading,
            ));
          },
          queryParameters: queryParameters,
        );

        if (response.statusCode == HttpStatus.ok) {
          onProgress?.call(FFMpegProgress(
            downloaded: 0,
            fileSize: 0,
            phase: FFMpegProgressPhase.decompressing,
          ));
          await compute(extractZipFileIsolate, {
            'zipFile': tempZipFile.path,
            'targetPath': _ffmpegInstallationPath,
          });
          var ffmpeg = 'ffmpeg';
          var ffprobe = 'ffprobe';

          if (_ffmpegBinDirectory != null && Platform.isMacOS) {
            ffprobe = path.join(_ffmpegBinDirectory!, "ffprobe");
            ffmpeg = path.join(_ffmpegBinDirectory!, "ffmpeg");
          }

          Process permissionProcess = await Process.start(
            "chmod",
            [
              "+x",
              ffmpeg,
              "&&",
              ffprobe,
            ],
          );

          if (await permissionProcess.exitCode != ReturnCode.success) {
            throw Exception("Permission denied");
          }
          await tempZipFile.delete();
          onProgress?.call(FFMpegProgress(
            downloaded: 0,
            fileSize: 0,
            phase: FFMpegProgressPhase.inactive,
          ));
          return true;
        } else {
          onProgress?.call(FFMpegProgress(
            downloaded: 0,
            fileSize: 0,
            phase: FFMpegProgressPhase.inactive,
          ));
          return false;
        }
      } catch (e) {
        onProgress?.call(FFMpegProgress(
          downloaded: 0,
          fileSize: 0,
          phase: FFMpegProgressPhase.inactive,
        ));
        return false;
      }
    } else {
      onProgress?.call(FFMpegProgress(
        downloaded: 0,
        fileSize: 0,
        phase: FFMpegProgressPhase.decompressing,
      ));
      try {
        await compute(extractZipFileIsolate, {
          'zipFile': tempZipFile.path,
          'targetPath': _ffmpegInstallationPath,
        });
        onProgress?.call(FFMpegProgress(
          downloaded: 0,
          fileSize: 0,
          phase: FFMpegProgressPhase.inactive,
        ));
        return true;
      } catch (e) {
        onProgress?.call(FFMpegProgress(
          downloaded: 0,
          fileSize: 0,
          phase: FFMpegProgressPhase.inactive,
        ));
        return false;
      }
    }
  }
}
