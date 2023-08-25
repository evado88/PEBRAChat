import 'dart:async';
import 'dart:convert';

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

    final response =
        await client.get(Uri.parse('${Assist.apiUrl}/resource/list'));

    // Use the compute function to run parseTwysheResources in a separate isolate.
    try {
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

    final response =
        await client.get(Uri.parse('${Assist.apiUrl}/facility/list'));

    // Use the compute function to run parseTwysheFacilitys in a separate isolate.
    try {
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
}
