import 'dart:io';

class FFMpegHelperSession {
  final Function cancelSession;
  final Process? windowSession;

  FFMpegHelperSession({
    required this.cancelSession,
    this.windowSession,
  });
}
