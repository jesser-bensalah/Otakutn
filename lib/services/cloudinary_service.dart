import 'dart:io';
import 'dart:convert';
import 'dart:html' as html if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as path;

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  late String _cloudName;
  late String _apiKey;
  late String _apiSecret;

  factory CloudinaryService() => _instance;

  CloudinaryService._internal();

  static Future<void> init() async {
    if (kIsWeb) {
      // For web, we'll use compile-time environment variables
      _instance._cloudName = const String.fromEnvironment('CLOUD_NAME');
      _instance._apiKey = const String.fromEnvironment('API_KEY');
      _instance._apiSecret = const String.fromEnvironment('API_SECRET');
    } else {
      // For mobile/desktop, use dotenv
      await dotenv.load(fileName: ".env");
      _instance._cloudName = dotenv.get('CLOUD_NAME');
      _instance._apiKey = dotenv.get('API_KEY');
      _instance._apiSecret = dotenv.get('API_SECRET');
    }
  }

  // Get video URL from Cloudinary
  String getVideoUrl(String publicId, {String resourceType = 'video'}) {
    return 'https://res.cloudinary.com/$_cloudName/$resourceType/upload/$publicId';
  }

  // Get video URL with transformations
  String getVideoUrlWithTransformations(String publicId, {
    int width = 1280,
    int height = 720,
    String resourceType = 'video',
    String format = 'mp4',
  }) {
    return 'https://res.cloudinary.com/$_cloudName/$resourceType/upload/c_fill,w_$width,h_$height/$publicId.$format';
  }

  // Get video thumbnail URL
  String getVideoThumbnail(String publicId, {int width = 300, int height = 200}) {
    return 'https://res.cloudinary.com/$_cloudName/video/upload/w_$width,h_$height,c_thumb/$publicId.jpg';
  }

  Future<String> uploadVideo(String filePath) async {
    try {
      print('Starting upload to Cloudinary...');
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/video/upload');
      
      var request = http.MultipartRequest('POST', url)
        ..fields['folder'] = 'anime_episodes'
        ..files.add(await http.MultipartFile.fromPath(
          'file', 
          filePath,
          filename: path.basename(filePath),
        ));

      final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
      final signature = _generateSignature({
        'folder': 'anime_episodes',
        'timestamp': timestamp,
      });

      request.fields['api_key'] = _apiKey;
      request.fields['timestamp'] = timestamp;
      request.fields['signature'] = signature;

      print('Sending request to Cloudinary...');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      
      print('Cloudinary response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final secureUrl = jsonResponse['secure_url'];
        print('Upload successful! URL: $secureUrl');
        return secureUrl ?? '';
      } else {
        print('Upload failed with status: ${response.statusCode}');
        print('Error details: ${jsonResponse['error']}');
        return '';
      }
    } catch (e) {
      print('Error uploading video: $e');
      return '';
    }
  }

  String _generateSignature(Map<String, String> params) {
    // Sort parameters alphabetically
    final sortedKeys = params.keys.toList()..sort();
    final signatureString = sortedKeys.map((key) => '$key=${params[key]}').join('&');
    final fullString = '$signatureString$_apiSecret';
    
    
    // using a simple hash as placeholder
    return _simpleHash(fullString);
  }

  String _simpleHash(String input) {
    return input.hashCode.toString();
  }
}