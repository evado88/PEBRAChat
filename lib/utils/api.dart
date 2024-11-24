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
import 'package:twyshe/classes/user.dart';
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

      //save the loaded data
      await Assist.saveResourcesLocally(response.body);

      // Use the compute function to run parseTwysheResources in a separate isolate.
      return parseTwysheResources(response.body);
    } on SocketException catch (e) {
      Assist.log(
          'A socket exception has occured when loading resources from the server: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message:
              'Unable to load resources. Please make sure you have internet',
          items: []);
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

    ///Fetches the reources locally
  static Future<TwysheTaskResult> fetchLocalTwysheResources() async {
    Assist.log('Loading local resources from the device');

    try {
      final response = await Assist.getLocalResources();
      // Use the compute function to run parseTwysheFacilitys in a separate isolate.
      if (response == null) {
        return TwysheTaskResult(
            succeeded: false,
            message: 'There are currently no saved resources on the device',
            items: []);
      } else {
        return parseTwysheResources(response);
      }
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when loading resources from the device: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading resources from the device: ${x.toString()}');
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

      //save the loaded data
      await Assist.saveFacilitiesLocally(response.body);

      // Use the compute function to run parseTwysheFacilitys in a separate isolate.
      return parseTwysheFacilitys(response.body);
    } on SocketException catch (e) {
      Assist.log(
          'A socket exception has occured when loading facilities from the server: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message:
              'Unable to load facilities. Please make sure you have internet',
          items: []);
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

  ///Fetches the facilities locally
  static Future<TwysheTaskResult> fetchLocalTwysheFacilities() async {
    Assist.log('Loading local facilities from the device');

    try {
      final response = await Assist.getLocalFacilities();
      // Use the compute function to run parseTwysheFacilitys in a separate isolate.
      if (response == null) {
        return TwysheTaskResult(
            succeeded: false,
            message: 'There are currently no saved facilities on the device',
            items: []);
      } else {
        return parseTwysheFacilitys(response);
      }
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when loading facilities from the device: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading facilities from the device: ${x.toString()}');
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

      //save the loaded data
      await Assist.saveColorsLocally(response.body);

      // Use the compute function to run parseTwysheColors in a separate isolate.
      return parseTwysheColors(response.body);
    } on SocketException catch (e) {
      Assist.log(
          'A socket exception has occured when loading colors from the server: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message: 'Unable to load colors. Please make sure you have internet',
          items: []);
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

      ///Fetches the reources locally
  static Future<TwysheTaskResult> fetchLocalTwysheColors() async {
    Assist.log('Loading local colors from the device');

    try {
      final response = await Assist.getLocalColors();
      // Use the compute function to run parseTwysheFacilitys in a separate isolate.
      if (response == null) {
        return TwysheTaskResult(
            succeeded: false,
            message: 'There are currently no saved colors on the device',
            items: []);
      } else {
        return parseTwysheColors(response);
      }
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when loading colors from the device: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading colors from the device: ${x.toString()}');
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

      //save the loaded data
      await Assist.saveCountriesLocally(response.body);

      // Use the compute function to run parseTwysheColors in a separate isolate.
      return parseTwysheCountries(response.body);
    } on SocketException catch (e) {
      Assist.log(
          'A socket exception has occured when loading countries from the server: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message:
              'Unable to load countries. Please make sure you have internet',
          items: []);
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

      ///Fetches the reources locally
  static Future<TwysheTaskResult> fetchLocalTwysheCountries() async {
    Assist.log('Loading local countries from the device');

    try {
      final response = await Assist.getLocalCountries();
      // Use the compute function to run parseTwysheFacilitys in a separate isolate.
      if (response == null) {
        return TwysheTaskResult(
            succeeded: false,
            message: 'There are currently no saved countries on the device',
            items: []);
      } else {
        return parseTwysheCountries(response);
      }
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when loading countries from the device: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading countries from the device: ${x.toString()}');
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

  ///Sends a device message using the server
  static Future<TwysheTaskResult> sendDeviceMessage(
      String phone, String notificationTitle, String notificationBody) async {
    http.Client client = http.Client();

    Assist.log(
        'Sending a device message to $phone: ${Assist.apiUrl}/send-fcm-device-message');

    Map<String, dynamic> fields = {
      'phone': phone,
      'title': notificationTitle,
      'body': notificationBody
    };

    try {
      final response = await client.post(
          Uri.parse('${Assist.apiUrl}/send-fcm-device-message'),
          body: fields);

      // Use the compute function to run parseTwysheColors in a separate isolate.
      Assist.log(
          'The device notification has been sent successfully to $phone: ${response.body}');

      return TwysheTaskResult(
          succeeded: true, message: response.body, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when sending a device notification to $phone: ${x.toString()}');
      return TwysheTaskResult(
          succeeded: false, message: x.toString(), items: []);
    }
  }

  static Future<TwysheTaskResult> uploadImageFileToCloud(XFile file) async {
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

  static Future<TwysheTaskResult> uploadFileToCloud(PlatformFile file) async {
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

  ///Registers the current phone
  static Future<TwysheTaskResult> registerPhone(
      String nickname, phone, pin, color, email) async {
    http.Client client = http.Client();

    Assist.log(
        'Starting to register phone on the server: ${Assist.apiUrl}/phone/register');

    String token = await Assist.getFCMToken();

    Map<String, String> values = {
      'unumber': phone,
      'uname': nickname,
      'upin': pin,
      'utoken': token,
      'ucolor': color,
      'uemail': email
    };

    try {
      final response = await client
          .post(Uri.parse('${Assist.apiUrl}/phone/register'), body: values);

      // check the response

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        if (parsed['succeeded']) {
          TwysheUser current = TwysheUser.fromJson(parsed['items'][0]);

          Assist.log(
              'Phone registration successfully with phone ${current.phone} and name ${current.nickname} and status ${current.status}');

          return TwysheTaskResult(
            succeeded: true,
            message: '',
            items: [],
            data: current,
          );
        } else {
          Assist.log(
              'Unable to complete phone registration and reason from server is ${parsed['message']}');

          return TwysheTaskResult(
              succeeded: false,
              message:
                  'Unable to complete phone registration: ${parsed['message']}',
              items: []);
        }
      } else {
        Assist.log(
            'Unable to complete phone registration and status code is ${response.statusCode}');

        return TwysheTaskResult(
            succeeded: false,
            message:
                'Unable to complete phone registration due to server error',
            items: []);
      }
    } on SocketException catch (e) {
      Assist.log(
          'Unable to complete phone registration due to a socket error: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message:
              'Unable to complete phone registration. Please make sure you have internet',
          items: []);
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when loading peer from the server: ${e.message}');
      return TwysheTaskResult(
          succeeded: false,
          message: 'Unable to complete phone registration. Please try again',
          items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading peer from the server: ${x.toString()}');
      return TwysheTaskResult(
          succeeded: false,
          message:
              'Unable to complete phone registration due to error. Please try again',
          items: []);
    }
  }

  ///Fetches the resource from online
  static Future<TwysheTaskResult> performHandshake(String phone) async {
    http.Client client = http.Client();

    String token = await Assist.getFCMToken();

    Assist.log(
        'Starting handshake for the user $phone and token $token: ${Assist.apiUrl}/phone/handshake');

    Map<String, String> values = {
      'unumber': phone,
      'utoken': token,
    };

    try {
      final response = await client
          .post(Uri.parse('${Assist.apiUrl}/phone/handshake'), body: values);

      // check the response

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        if (parsed['succeeded']) {
          TwysheUser current = TwysheUser.fromJson(parsed['items'][0]);

          Assist.log(
              'The handshake has been successfully completed for user ${current.phone}, name ${current.nickname}, status ${current.status}');

          return TwysheTaskResult(
              succeeded: true, message: '', items: [], data: current);
        } else {
          Assist.log(
              'The handshake failed and reason from server is ${parsed['message']}');

          return TwysheTaskResult(
              succeeded: false,
              message: 'Unable to complete handshake: ${parsed['message']}',
              items: []);
        }
      } else {
        Assist.log(
            'The handshake failed and status code is ${response.statusCode}');

        return TwysheTaskResult(
            succeeded: false,
            message: 'Unable to perform handshake due to server error',
            items: []);
      }
    } on SocketException catch (e) {
      Assist.log(
          'Unable to perform handshake due to a socket error: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message:
              'Unable to perform handshake. Please make sure you have internet',
          items: []);
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when performing handshake: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when performing handshak: ${x.toString()}');
      return TwysheTaskResult(
          succeeded: false, message: x.toString(), items: []);
    }
  }

  ///Fetches the reource from online
  static Future<TwysheTaskResult> fetchParticipantPeer(
      String participant) async {
    http.Client client = http.Client();

    Assist.log(
        'Loading the peer from the server: ${Assist.apiUrl}/participant/list/peer/$participant');
    try {
      final response = await client.get(
          Uri.parse('${Assist.apiUrl}/participant/list/peer/$participant'));

      // Use the compute function to run parseTwysheFacilitys in a separate isolate.

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        if (parsed['succeeded']) {
          List values = parsed['items'];

          if (values.isNotEmpty) {
            TwysheUser peer = TwysheUser.fromJson(parsed['items'][0]);

            Assist.log(
                'The peer has been successfully retrieved with phone ${peer.phone} and name ${peer.nickname}');

            return TwysheTaskResult(
              succeeded: true,
              message: '',
              items: [],
              data: peer,
            );
          } else {
            Assist.log(
                'The current participant does not have a peer navigator assigned');

            return TwysheTaskResult(
                succeeded: false,
                message:
                    'Unable to retrieve peer: Peer navigator not yet assigned',
                items: []);
          }
        } else {
          Assist.log(
              'The peer could not be retrived and reason from server is ${parsed['message']}');

          return TwysheTaskResult(
              succeeded: false,
              message: 'Unable to retrieve peer: ${parsed['message']}',
              items: []);
        }
      } else {
        Assist.log(
            'The peer could not be retrived and status code is ${response.statusCode}');

        return TwysheTaskResult(
            succeeded: false,
            message: 'Unable to retrieve peer due to server error',
            items: []);
      }
    } on SocketException catch (e) {
      Assist.log('Unable to retrieve peer due to a socket error: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message:
              'Unable to retrieve peer. Please make sure you have internet',
          items: []);
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when loading peer from the server: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading peer from the server: ${x.toString()}');
      return TwysheTaskResult(
          succeeded: false, message: x.toString(), items: []);
    }
  }

  ///Fetches the resource from online
  static Future<TwysheTaskResult> fetchPeerParticipants(String peer) async {
    http.Client client = http.Client();

    Assist.log(
        'Loading the participants for the peer from the server: ${Assist.apiUrl}/participant/list/peer/$peer');
    try {
      final response = await client
          .get(Uri.parse('${Assist.apiUrl}/peer/list/participant/$peer'));

      // Use the compute function to run parseTwysheFacilitys in a separate isolate.

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        if (parsed['succeeded']) {
          List<TwysheUser> participants = parsed['items']
              .map<TwysheUser>((res) => TwysheUser.fromJson(res))
              .toList();

          Assist.log(
              'The peer participants have been successfully retrieved and are ${participants.length} item(s) total');

          return TwysheTaskResult(
            succeeded: true,
            message: '',
            items: participants,
          );
        } else {
          Assist.log(
              'The peer participants could not be retrieved and reason from server is ${parsed['message']}');

          return TwysheTaskResult(
              succeeded: false,
              message:
                  'Unable to retrieve peer participants: ${parsed['message']}',
              items: []);
        }
      } else {
        Assist.log(
            'The peer participants could not be retrived and status code is ${response.statusCode}');

        return TwysheTaskResult(
            succeeded: false,
            message: 'Unable to retrieve participants peer due to server error',
            items: []);
      }
    } on SocketException catch (e) {
      Assist.log(
          'Unable to retrieve peer participants due to a socket error: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message:
              'Unable to retrieve peer participants. Please make sure you have internet',
          items: []);
    } on FormatException catch (e) {
      Assist.log(
          'A format exeception has occured when loading peer participants from the server: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading peer participants from the server: ${x.toString()}');
      return TwysheTaskResult(
          succeeded: false, message: x.toString(), items: []);
    }
  }

  ///Fetches the resource from online
  static Future<TwysheTaskResult> fetchPhone(String phone) async {
    http.Client client = http.Client();

    Assist.log(
        'Loading the phone from the server: ${Assist.apiUrl}/phone/number/$phone');
    try {
      final response =
          await client.get(Uri.parse('${Assist.apiUrl}/phone/number/$phone'));

      // Use the compute function to run parseTwysheFacilitys in a separate isolate.

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        if (parsed['succeeded']) {
          TwysheUser user = TwysheUser.fromJson(parsed['items'][0]);

          Assist.log(
              'The phone have been successfully retrieved and is name ${user.nickname} and color ${user.color}');

          return TwysheTaskResult(
              succeeded: true, message: '', data: user, items: []);
        } else {
          Assist.log(
              'The phone could not be retrieved and reason from server is ${parsed['message']}');

          return TwysheTaskResult(
              succeeded: false,
              message: 'Unable to retrieve phone: ${parsed['message']}',
              items: []);
        }
      } else {
        Assist.log(
            'The phone could not be retrived and status code is ${response.statusCode}');

        return TwysheTaskResult(
            succeeded: false,
            message: 'Unable to retrieve phone due to server error',
            items: []);
      }
    } on SocketException catch (e) {
      Assist.log(
          'Unable to retrieve phone due to a socket error: ${e.message}');

      return TwysheTaskResult(
          succeeded: false,
          message:
              'Unable to retrieve phone. Please make sure you have internet',
          items: []);
    } on FormatException catch (e) {
      Assist.log(
          'A format exception has occured when loading phone from the server: ${e.message}');
      return TwysheTaskResult(succeeded: false, message: e.message, items: []);
    } on Error catch (x) {
      Assist.log(
          'An error has occured when loading phone from the server: ${x.toString()}');
      return TwysheTaskResult(
          succeeded: false, message: x.toString(), items: []);
    }
  }
}
