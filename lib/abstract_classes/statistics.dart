/// Statistics entry for an FFmpeg execute session.
class Statistics {
  int _sessionId;
  int _videoFrameNumber;
  double _videoFps;
  double _videoQuality;
  int _size;
  double _time;
  double _bitrate;
  double _speed;

  Statistics(this._sessionId, this._videoFrameNumber, this._videoFps,
      this._videoQuality, this._size, this._time, this._bitrate, this._speed);

  int getSessionId() => _sessionId;

  void setSessionId(int sessionId) {
    _sessionId = sessionId;
  }

  int getVideoFrameNumber() => _videoFrameNumber;

  set videoFrameNumber(int videoFrameNumber) {
    _videoFrameNumber = videoFrameNumber;
  }

  double getVideoFps() => _videoFps;

  set videoFps(double videoFps) {
    _videoFps = videoFps;
  }

  double getVideoQuality() => _videoQuality;

  set videoQuality(double videoQuality) {
    _videoQuality = videoQuality;
  }

  int getSize() => _size;

  set size(int size) {
    _size = size;
  }

  double getTime() => _time;

  set time(double time) {
    _time = time;
  }

  double getBitrate() => _bitrate;

  set bitrate(double bitrate) {
    _bitrate = bitrate;
  }

  double getSpeed() => _speed;

  set speed(double speed) {
    _speed = speed;
  }

  @override
  String toString() {
    return 'Frame: $_videoFrameNumber, FPS: $_videoFps, Quality: $_videoQuality, Size: $_size, Time: $_time, Bitrate: $_bitrate, Speed: $_speed';
  }
}
