import 'package:http/http.dart' as http;
import 'package:quiz_app/Api/responseModel.dart';

class APIServiceList {
  

  Future<ResponseModel> getUpdates(GetRequestModel requestModel) async {
    String url = "http://quizapp.jiriapp.com/api/v1/check/updates";
    return processRequest(requestModel, url);
  }

  Future<ResponseModel> getQuestions(GetRequestModel requestModel) async {
    String url = "http://quizapp.jiriapp.com/api/v1/get/questions";
    return processRequest(requestModel, url);
  }

bool testNoExc = false;

  Future<ResponseModel> processRequest(dynamic requestModel, String url) async {
    if (testNoExc) {
      final response =
          await http.post(Uri.parse(url), body: requestModel.toJson());
      if (response.statusCode == 200 || response.statusCode == 400) {
        return ResponseModel.fromJson(response.body);
      } else {
        //print(response.body);
        return ResponseModel.error(
            "Server failed to load request.Please try again");
      }
    } else {
      try {
        final response =
            await http.post(Uri.parse(url), body: requestModel.toJson());
        print(url);
        print(response.body);
        if (response.statusCode == 200 || response.statusCode == 400) {
          return ResponseModel.fromJson(response.body);
        } else {
          print(response.body);
          return ResponseModel.error(
              "Server failed to load request.Please try again");
        }
      } catch (e) {
        print(e.toString());
        return ResponseModel.error("Critical : " + e.toString());
      }
    }
  }
}
