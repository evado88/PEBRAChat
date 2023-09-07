import 'dart:async';
import 'dart:convert';

import 'package:twyshe/classes/color.dart';
import 'package:twyshe/classes/country.dart';
import 'package:twyshe/classes/facility.dart';
import 'package:twyshe/classes/resource.dart';
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
}
