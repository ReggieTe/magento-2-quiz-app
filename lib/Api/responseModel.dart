import 'dart:convert';

class ResponseModel {
  final String message;

  ///  returns true if the api call failed i.e status code not equal to 200/400
  final bool error;
  final Map<String, dynamic> data;

  /// returns a list of errors
  final Map<String, dynamic> errors;

  ResponseModel(
      { required this.message,
      required this.error,
       required this.data,
      required this.errors});

  factory ResponseModel.fromJson(String rawData) {
    var jsonn = json.decode(rawData);
    return new ResponseModel(
        //errors: jsonn["errors"] ??  jsonn["body"]["data"].runtimeType != List && jsonn["body"]["data"].containsKey("errors") ? jsonn["body"]["data"]["errors"] : [],
        errors: jsonn["errors"] ?? {},
        message: jsonn["message"] ?? "",
        data: jsonn['body'] ?? const {},
        error: jsonn["code"]==400?true:false);
  }

  factory ResponseModel.error(String errorMessage) {
    return ResponseModel(
        message: errorMessage,
        data: {},
        error: true,
        errors: {});
  }

  @override
  String toString() {
    return {
      'message': message,
      'error': error,
      'data': data,
      'errors': errors,
    }.toString();
  }
}

class GetRequestModel {
  final String authid;
  final String section;
  final String count;
  
  GetRequestModel({
    required this.authid,
    required this.section,
    required this.count
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'token': authid.trim(),
      'section':section.trim(),
      'count':count.trim()
    };
    return map;
  }
}
