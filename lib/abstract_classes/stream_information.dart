/// Stream information class.
class StreamInformation {
  static const keyIndex = "index";
  static const keyType = "codec_type";
  static const keyCodec = "codec_name";
  static const keyCodecLong = "codec_long_name";
  static const keyFormat = "pix_fmt";
  static const keyWidth = "width";
  static const keyHeight = "height";
  static const keyBitRate = "bit_rate";
  static const keySampleRate = "sample_rate";
  static const keySampleFormat = "sample_fmt";
  static const keyChannelLayout = "channel_layout";
  static const keySampleAspectRatio = "sample_aspect_ratio";
  static const keyDisplayAspectRatio = "display_aspect_ratio";
  static const keyAverageFrameRate = "avg_frame_rate";
  static const keyRealFrameRate = "r_frame_rate";
  static const keyTimeBase = "time_base";
  static const keyCodecTimeBase = "codec_time_base";
  static const keyTags = "tags";

  final Map<dynamic, dynamic>? _allProperties;

  /// Creates a new [StreamInformation] instance
  StreamInformation(this._allProperties);

  /// Returns stream index.
  int? getIndex() => getNumberProperty(keyIndex)?.toInt();

  /// Returns stream type.
  String? getType() => getStringProperty(StreamInformation.keyType);

  /// Returns stream codec.
  String? getCodec() => getStringProperty(StreamInformation.keyCodec);

  /// Returns stream codec in long format.
  String? getCodecLong() => getStringProperty(StreamInformation.keyCodecLong);

  /// Returns stream format.
  String? getFormat() => getStringProperty(StreamInformation.keyFormat);

  /// Returns width.
  int? getWidth() => getNumberProperty(StreamInformation.keyWidth)?.toInt();

  /// Returns height.
  int? getHeight() => getNumberProperty(StreamInformation.keyHeight)?.toInt();

  /// Returns bitrate.
  String? getBitrate() => getStringProperty(StreamInformation.keyBitRate);

  /// Returns sample rate.
  String? getSampleRate() => getStringProperty(StreamInformation.keySampleRate);

  /// Returns sample format.
  String? getSampleFormat() =>
      getStringProperty(StreamInformation.keySampleFormat);

  /// Returns channel layout.
  String? getChannelLayout() =>
      getStringProperty(StreamInformation.keyChannelLayout);

  /// Returns sample aspect ratio.
  String? getSampleAspectRatio() =>
      getStringProperty(StreamInformation.keySampleAspectRatio);

  /// Returns display aspect ratio.
  String? getDisplayAspectRatio() =>
      getStringProperty(StreamInformation.keyDisplayAspectRatio);

  /// Returns average frame rate.
  String? getAverageFrameRate() =>
      getStringProperty(StreamInformation.keyAverageFrameRate);

  /// Returns real frame rate.
  String? getRealFrameRate() =>
      getStringProperty(StreamInformation.keyRealFrameRate);

  /// Returns time base.
  String? getTimeBase() => getStringProperty(StreamInformation.keyTimeBase);

  /// Returns codec time base.
  String? getCodecTimeBase() =>
      getStringProperty(StreamInformation.keyCodecTimeBase);

  /// Returns all tags.
  Map<dynamic, dynamic>? getTags() => getProperty(StreamInformation.keyTags);

  /// Returns the stream property associated with the key.
  String? getStringProperty(String key) => _allProperties?[key];

  /// Returns the stream property associated with the key.
  num? getNumberProperty(String key) => _allProperties?[key];

  /// Returns the stream property associated with the key.
  dynamic getProperty(String key) => _allProperties?[key];

  /// Returns all properties found.
  Map<dynamic, dynamic>? getAllProperties() => _allProperties;
}
