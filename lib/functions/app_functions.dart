import 'package:google_mao/Models/location_model.dart';
import 'package:http/http.dart' as http;

class AppFunctions {
  static void refreshButtonPressed() {}
}

class AppApiFunctions {
  static Future<String> fetchData() async {
    var url = Uri.parse("https://stormy-overshirt-moth.cyclic.app/location");
    print("get - called");

    try {
      print("try block called");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        // Successful request
        var data = response.body;

        // Process the data as needed
        print('Response body: $data');
        return data;
      } else {
        // Error handling for non-200 status codes
        print('Request failed with status: ${response.statusCode}');
        return "error";
      }
    } catch (e) {
      // Error handling for exceptions
      print('An error occurred: $e');
      return "error";
    }
  }
}
