import 'chapter.dart';
import 'stream_information.dart';

/// Media information class.
class MediaInformation {
  static const keyFormatProperties = "format";
  static const keyFilename = "filename";
  static const keyFormat = "format_name";
  static const keyFormatLong = "format_long_name";
  static const keyStartTime = "start_time";
  static const keyDuration = "duration";
  static const keySize = "size";
  static const keyBitRate = "bit_rate";
  static const keyTags = "tags";

  final Map<dynamic, dynamic>? _allProperties;

  /// Creates a new [MediaInformation] instance
  MediaInformation(this._allProperties);

  /// Returns file name.
  String? getFilename() =>
      getStringFormatProperty(MediaInformation.keyFilename);

  /// Returns format.
  String? getFormat() => getStringFormatProperty(MediaInformation.keyFormat);

  /// Returns long format.
  String? getLongFormat() =>
      getStringFormatProperty(MediaInformation.keyFormatLong);

  /// Returns duration.
  String? getDuration() =>
      getStringFormatProperty(MediaInformation.keyDuration);

  /// Returns start time.
  String? getStartTime() =>
      getStringFormatProperty(MediaInformation.keyStartTime);

  /// Returns size.
  String? getSize() => getStringFormatProperty(MediaInformation.keySize);

  /// Returns bitrate.
  String? getBitrate() => getStringFormatProperty(MediaInformation.keyBitRate);

  /// Returns all tags.
  Map<dynamic, dynamic>? getTags() =>
      getFormatProperty(StreamInformation.keyTags);

  /// Returns the property associated with the key.
  String? getStringProperty(String key) => getAllProperties()?[key];

  /// Returns the property associated with the key.
  num? getNumberProperty(String key) => getAllProperties()?[key];

  /// Returns the property associated with the key.
  dynamic getProperty(String key) => getAllProperties()?[key];

  /// Returns the format property associated with the key.
  String? getStringFormatProperty(String key) => getFormatProperties()?[key];

  /// Returns the format property associated with the key.
  num? getNumberFormatProperty(String key) => getFormatProperties()?[key];

  /// Returns the format property associated with the key.
  dynamic getFormatProperty(String key) => getFormatProperties()?[key];

  /// Returns all streams found as a list.
  List<StreamInformation> getStreams() {
    final List<StreamInformation> list =
        List<StreamInformation>.empty(growable: true);

    dynamic createStreamInformation(Map<dynamic, dynamic> streamProperties) =>
        list.add(StreamInformation(streamProperties));

    _allProperties?["streams"]?.forEach((Object? stream) {
      createStreamInformation(stream as Map<dynamic, dynamic>);
    });

    return list;
  }

  /// Returns all chapters found as a list.
  List<Chapter> getChapters() {
    final List<Chapter> list = List<Chapter>.empty(growable: true);

    dynamic createChapter(Map<dynamic, dynamic> chapterProperties) =>
        list.add(Chapter(chapterProperties));

    _allProperties?["chapters"]?.forEach((Object? chapter) {
      createChapter(chapter as Map<dynamic, dynamic>);
    });

    return list;
  }

  /// Returns all format properties found.
  Map<dynamic, dynamic>? getFormatProperties() =>
      _allProperties?[keyFormatProperties];

  /// Returns all properties found, including stream properties.
  Map<dynamic, dynamic>? getAllProperties() => _allProperties;
}
