import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quiz_app/Class/StartTestArguments.dart';
import 'package:quiz_app/components/custom_button.dart';
import 'package:quiz_app/screens/quiz.dart';
import 'package:quiz_app/components/progress_loader.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/Api/api.service.list.dart';
import 'package:quiz_app/Api/responseModel.dart';

class Start extends StatefulWidget {
  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  List<String> list = <String>['Backend Developer', 'Frontend Developer'];
  List<String> questionCount = <String>['10','20','30','60', '120'];
  List<String> showAnswers = <String>['No','Yes'];
  String dropdownValueList = '';
  String dropdownValueQuestionCount = '';
  String dropdownValueShowAnswers = '';
  bool newUpdatesAvailable = false;
  String updateMessage = '';
  bool isApiCallProcess = false;


 
  @override
  void initState() {   
    dropdownValueList = list.first;
    dropdownValueQuestionCount = questionCount.first;
    dropdownValueShowAnswers = showAnswers.first;
    checkUpdates();
    super.initState();
  }


  void checkUpdates() async {
    GetRequestModel requestModel =
        new GetRequestModel(authid:dotenv.get('API_KEY'), section: '', count: '');
    setState(() {
      isApiCallProcess = true;
    });
    APIServiceList apiService = new APIServiceList();
      apiService.getUpdates(requestModel).then((value) async {
            setState(() {
              isApiCallProcess = false;
            });
            if (!value.error) {
              if(value.data['update']['state'] == 1){
               var newVersion = value.data['update']['version'];
              setState(() {
               if(newVersion > appVersion){
                  newUpdatesAvailable = true;                  
                  String message = "\nYour current version "+appVersion.toString()+" and the lastest version is "+newVersion.toString();
                  updateMessage = value.data['update']['message']+message;
               }
            });  
  
              }
            }
      });
  }

 @override
  Widget build(BuildContext context) => ProgressLoader(
        child: _uiSetup(context),
        inAsyncCall: isApiCallProcess,
        opacity: 0.3,
      );

  Widget _uiSetup(BuildContext context) {

    ThemeData theme = Theme.of(context);
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 30.0),
              height: screen.width / 3,
              width: screen.width / 3,
              child: Image(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
            Text("Magento 2",style: TextStyle(fontSize: 40,color: Colors.white),),
            SizedBox(height: 10,),
            Text("Questions & Answers",style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w600),),
            SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.all(5),
              child:  Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Text("Section",style: TextStyle(color: Colors.white,fontSize: 16),),
                      DropdownButton<String>(
                            value: dropdownValueList,
                            icon: const Icon(Icons.check_circle_outline,color:Colors.white),
                            elevation: 16,
                            style: TextStyle(color: theme.primaryColor),
                            underline: Container(
                              height: 2,
                              color: theme.primaryColor,
                            ),
                            onChanged: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                dropdownValueList = value!;
                              });
                            },
                            items: list.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                      
                  ],
                ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Questions",style: TextStyle(color: Colors.white,fontSize: 16),),
                    DropdownButton<String>(
                          value: dropdownValueQuestionCount,
                          icon: const Icon(Icons.check_circle_outline,color:Colors.white),
                          elevation: 16,
                          style: TextStyle(color: theme.primaryColor),
                          underline: Container(
                            height: 2,
                            color: theme.primaryColor,
                          ),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              dropdownValueQuestionCount = value!;
                            });
                          },
                          items: questionCount.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
            
                  ],
                ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Show correct answers",style: TextStyle(color: Colors.white,fontSize: 16),),
            DropdownButton<String>(
                  value: dropdownValueShowAnswers,
                  icon: const Icon(Icons.check_circle_outline,color:Colors.white),
                  elevation: 16,
                  style: TextStyle(color: theme.primaryColor),
                  underline: Container(
                    height: 2,
                    color: theme.primaryColor,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValueShowAnswers = value!;
                    });
                  },
                  items: showAnswers.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                       
                  ],
                )
              ],),
              ), Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Quiz(startValues: StartTestArguments(dropdownValueList, dropdownValueQuestionCount, dropdownValueShowAnswers),);
                          }));
                },
                child: CustomButton(text: 'Start Quiz!'),
              ),
            ), 
            
            if(newUpdatesAvailable)
            Text(updateMessage,style:TextStyle(fontSize:12,color:Colors.red))
          ],
        ),
      ),
    );
  }
}
