import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:twyshe/classes/color.dart';
import 'package:twyshe/classes/country.dart';
import 'package:twyshe/classes/facility.dart';
import 'package:twyshe/classes/resource.dart';
import 'package:twyshe/classes/upload_file.dart';
import 'package:twyshe/screens/task_result.dart';
import 'package:http/http.dart' as http;
import 'package:twyshe/utils/assist.dart';

///Contains common properties and methods for communicating with the twyshe server
///Date: 25 August 2023
///Author: Nkole Evans
class TwysheAPI {
  ///Fetches the reource from online
  static Future<TwysheTaskResult> fetchTwysheResources() async {
    http.Client client = http.Client();

    Assist.log(
        'Loading resources from the server: ${Assist.apiUrl}/resource/list');
    try {
      final response =
          await client.get(Uri.parse('${Assist.apiUrl}/resource/list'));

      // Use the compute function to run parseTwysheResources in a separate isolate.

      return parseTwysheResources(response.body);
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when loading resources from the server: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading resources from the server: ${x.toString()}');
      return TwysheTaskResult(
          succeeded: false, message: x.toString(), items: []);
    }
  }

// Converts a response body into a List<TwysheResource>.
  static TwysheTaskResult parseTwysheResources(String responseBody) {
    Assist.log(
        'Starting to parse resources response (<100) from the server: ${responseBody.substring(0, 100)}');

    final parsed = jsonDecode(responseBody);

    TwysheTaskResult res = TwysheTaskResult.fromJson(parsed);

    res.items = parsed['items']
        .map<TwysheResource>((res) => TwysheResource.fromJson(res))
        .toList();
    Assist.log(
        'Completed parsing resources responsefrom the server and loaded ${res.items.length} resource(s)');
    return res;
  }

  ///Fetches the reource from online
  static Future<TwysheTaskResult> fetchTwysheFacilities() async {
    http.Client client = http.Client();

    Assist.log(
        'Loading facilities from the server: ${Assist.apiUrl}/facility/list');
    try {
      final response =
          await client.get(Uri.parse('${Assist.apiUrl}/facility/list'));

      // Use the compute function to run parseTwysheFacilitys in a separate isolate.

      return parseTwysheFacilitys(response.body);
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when loading facilities from the server: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading facilities from the server: ${x.toString()}');
      return TwysheTaskResult(
          succeeded: false, message: x.toString(), items: []);
    }
  }

// Converts a response body into a List<TwysheFacility>.
  static TwysheTaskResult parseTwysheFacilitys(String responseBody) {
    Assist.log(
        'Starting to parse resources response (<100) from the server: ${responseBody.substring(0, 100)}');

    final parsed = jsonDecode(responseBody);

    TwysheTaskResult res = TwysheTaskResult.fromJson(parsed);

    res.items = parsed['items']
        .map<TwysheFacility>((res) => TwysheFacility.fromJson(res))
        .toList();
    Assist.log(
        'Completed parsing resources responsefrom the server and loaded ${res.items.length} resource(s)');
    return res;
  }

  ///Fetches the color from online
  static Future<TwysheTaskResult> fetchTwysheColors() async {
    http.Client client = http.Client();

    Assist.log('Loading colors from the server: ${Assist.apiUrl}/color/list');
    try {
      final response =
          await client.get(Uri.parse('${Assist.apiUrl}/color/list'));

      // Use the compute function to run parseTwysheColors in a separate isolate.

      return parseTwysheColors(response.body);
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when loading colors from the server: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading colors from the server: ${x.toString()}');
      return TwysheTaskResult(
          succeeded: false, message: x.toString(), items: []);
    }
  }

// Converts a response body into a List<TwysheColor>.
  static TwysheTaskResult parseTwysheColors(String responseBody) {
    Assist.log(
        'Starting to parse color response (<100) from the server: ${responseBody.substring(0, 100)}');

    final parsed = jsonDecode(responseBody);

    TwysheTaskResult res = TwysheTaskResult.fromJson(parsed);

    res.items = parsed['items']
        .map<TwysheColor>((res) => TwysheColor.fromJson(res))
        .toList();
    Assist.log(
        'Completed parsing colors responsefrom the server and loaded ${res.items.length} colors(s)');
    return res;
  }

  ///Fetches the countries from online
  static Future<TwysheTaskResult> fetchTwysheCountries() async {
    http.Client client = http.Client();

    Assist.log(
        'Loading countries from the server: ${Assist.apiUrl}/country/list');
    try {
      final response =
          await client.get(Uri.parse('${Assist.apiUrl}/country/list'));

      // Use the compute function to run parseTwysheColors in a separate isolate.

      return parseTwysheCountries(response.body);
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when loading countries from the server: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading countries from the server: ${x.toString()}');
      return TwysheTaskResult(
          succeeded: false, message: x.toString(), items: []);
    }
  }

// Converts a response body into a List<TwysheCountry>.
  static TwysheTaskResult parseTwysheCountries(String responseBody) {
    Assist.log(
        'Starting to parse country response (<100) from the server: ${responseBody.substring(0, 100)}');

    final parsed = jsonDecode(responseBody);

    TwysheTaskResult res = TwysheTaskResult.fromJson(parsed);

    res.items = parsed['items']
        .map<TwysheCountry>((res) => TwysheCountry.fromJson(res))
        .toList();
    Assist.log(
        'Completed parsing countries response from the server and loaded ${res.items.length} countries(s)');
    return res;
  }

  ///Sends a topic message using the server
  static Future<TwysheTaskResult> sendTopicMessage(
      String topicId, String notificationTitle, String notificationBody) async {
    http.Client client = http.Client();

    Assist.log(
        'Sending a topic message to the server: ${Assist.apiUrl}/send-fcm-topic-message');

    Map<String, dynamic> fields = {
      'topic': topicId,
      'title': notificationTitle,
      'body': notificationBody
    };
    try {
      final response = await client.post(
          Uri.parse('${Assist.apiUrl}/send-fcm-topic-message'),
          body: fields);

      // Use the compute function to run parseTwysheColors in a separate isolate.
      Assist.log(
          'The topic notification has been sent successfully on the server: ${response.body}');

      return TwysheTaskResult(
          succeeded: true, message: response.body, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when sending a topic notification on the server: ${x.toString()}');
      return TwysheTaskResult(
          succeeded: false, message: x.toString(), items: []);
    }
  }

  static Future<TwysheTaskResult> uploadImageFileToCloud(
      XFile file) async {
    Assist.log(
        'Starting the image upload for file ${file.name} to server ${Assist.fileServerUrl}...');

    try {
      int sizeInBytes = await file.length();

      final uri = Uri.parse('${Assist.fileServerUrl}/APIClient.php');
      final multiPartFile = await http.MultipartFile.fromPath('file', file.path,
          filename: file.name);
      final uploadRequest = http.MultipartRequest('POST', uri)
        ..files.add(multiPartFile)
        ..fields.addAll(<String, String>{
          'task': Assist.fileServerUploadTask,
          'key': Assist.fileServerKey,
          'id': 'chatImage'
        });

      final responseStream = await uploadRequest.send();
      final response = await http.Response.fromStream(responseStream);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        if (parsed['Succeeded']) {
          String url = parsed['Data'];
          Assist.log(
              'The image upload succeeded and file url is ${Assist.fileServerUrl}$url');

          return TwysheTaskResult(
            succeeded: true,
            message: '',
            items: [],
            data: TwysheUploadFile(
                mimeType: lookupMimeType(file.path),
                name: file.name,
                uri: '${Assist.fileServerUrl}$url',
                size: sizeInBytes),
          );
        } else {
          Assist.log(
              'The image upload failed and returned reason from server is ${parsed['Message']}');

          return TwysheTaskResult(
              succeeded: false,
              message: 'Unable to post image: ${parsed['Message']}',
              items: []);
        }
      } else {
        Assist.log(
            'The image upload failed and returned status code is ${response.statusCode}');

        return TwysheTaskResult(
            succeeded: false,
            message: 'Unable to post image due to server error',
            items: []);
      }
    } on SocketException catch (e) {
      Assist.log(
          'Unable to post image to chat due to a socket error: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message: 'Unable to post image. Please make sure you have internet',
          items: []);
    } on FormatException catch (e) {
      Assist.log(
          'Unable to post image to chat due to a format error: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message: 'Unable to post image. Please try again',
          items: []);
    } on Error catch (e) {
      Assist.log(
          'Unable to post image to chat due to an unknown error: ${e.toString()}');

      return TwysheTaskResult(
          succeeded: false,
          message: 'Unable to post image due. An error occured',
          items: []);
    }
  }

  static Future<TwysheTaskResult> uploadFileToCloud(
      PlatformFile file) async {
    Assist.log(
        'Starting the file upload for file ${file.name} to server ${Assist.fileServerUrl}...');

    try {
      int sizeInBytes = file.size;

      final uri = Uri.parse('${Assist.fileServerUrl}/APIClient.php');
      final multiPartFile = await http.MultipartFile.fromPath(
          'file', file.path!,
          filename: file.name);
      final uploadRequest = http.MultipartRequest('POST', uri)
        ..files.add(multiPartFile)
        ..fields.addAll(<String, String>{
          'task': Assist.fileServerUploadTask,
          'key': Assist.fileServerKey,
          'id': 'chatFile'
        });

      final responseStream = await uploadRequest.send();
      final response = await http.Response.fromStream(responseStream);

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        if (parsed['Succeeded']) {
          String url = parsed['Data'];
          Assist.log(
              'The file upload succeeded and file url is ${Assist.fileServerUrl}$url');

          return TwysheTaskResult(
            succeeded: true,
            message: '',
            items: [],
            data: TwysheUploadFile(
                mimeType: lookupMimeType(file.path!),
                name: file.name,
                uri: '${Assist.fileServerUrl}$url',
                size: sizeInBytes),
          );
        } else {
          Assist.log(
              'The file upload failed and returned reason from server is ${parsed['Message']}');

          return TwysheTaskResult(
              succeeded: false,
              message: 'Unable to post file: ${parsed['Message']}',
              items: []);
        }
      } else {
        Assist.log(
            'The file upload failed and returned status code is ${response.statusCode}');

        return TwysheTaskResult(
            succeeded: false,
            message: 'Unable to post file due to server error',
            items: []);
      }
    } on SocketException catch (e) {
      Assist.log(
          'Unable to post file to chat due to a socket error: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message: 'Unable to post file. Please make sure you have internet',
          items: []);
    } on FormatException catch (e) {
      Assist.log(
          'Unable to post file to chat due to a format error: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message: 'Unable to post file. Please try again',
          items: []);
    } on Error catch (e) {
      Assist.log(
          'Unable to post file to chat due to an unknown error: ${e.toString()}');

      return TwysheTaskResult(
          succeeded: false,
          message: 'Unable to post file due. An error occured',
          items: []);
    }
  }
}
