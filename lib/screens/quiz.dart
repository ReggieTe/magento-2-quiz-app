import 'package:flutter/material.dart';
import 'package:quiz_app/Api/api.service.list.dart';
import 'package:quiz_app/Api/responseModel.dart';
import 'package:quiz_app/Class/Question.dart';
import 'package:quiz_app/Class/ScreenArguments.dart';
import 'package:quiz_app/Class/StartTestArguments.dart';
import 'package:quiz_app/components/ad_helper.dart';
import 'package:quiz_app/components/custom_button.dart';
import 'package:quiz_app/components/progress_loader.dart';
import 'package:quiz_app/components/quiz_option.dart';
import 'package:quiz_app/screens/start.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quiz_app/constants.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class Quiz extends StatefulWidget {
  final StartTestArguments startValues;
  const Quiz({super.key, required this.startValues});

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  
  BannerAd? _bannerAd;
  final formKey = GlobalKey<FormState>();
  InterstitialAd? _interstitialAd;
  late List<Question> questions;
  late List currentCorrectAnswers;
  late String currentTitle;
  late String currentCorrectAnswer;
  late List<dynamic> currentAnswers;
  late List<int> previousAnswers;
  late int corrects;
  late int currentQuestion;
  late List<int> selectedAnswers;
  late DateTime now;
  bool isApiCallProcess = false;
  late bool showAnswers;
  String _timeString = '00:00';
  String _startedAt = '00:00';

  @override
  void initState() {
    this.now = DateTime.now();
    this.corrects = 0;
    this.currentTitle = "Magento 2";
    this.currentQuestion = 0;
    this.questions = [];
    this.currentCorrectAnswers = [];
    this.currentAnswers = [];
    this.selectedAnswers = [];    
     _loadBanner();
     _loadInterstitialAd();
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    _startedAt = _formatDateTime(DateTime.now());
    this.getQuestions();
    super.initState();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);    
      if(mounted){
      setState(() {
          _timeString = formattedDateTime;      
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss').format(dateTime);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();    
   _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // _moveToHome();
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
         print('BannerAd failedToLoad: $err');
            _interstitialAd?.dispose();
            _interstitialAd = null;
        },
      ),
    );
  }

  void _loadBanner() {
    try {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          print('BannerAd failedToLoad: $err');
            _bannerAd?.dispose();
            _bannerAd = null;
        },
      ),
    ).load();
      }catch (exce) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Failed to load ad :"+exce.toString()),
                duration: Duration(seconds: 5),
              ));
      }
  }

  void getQuestions() async {
    String section = widget.startValues.section;
    String count = widget.startValues.count;
    showAnswers = widget.startValues.showCorrectAnswers == 'Yes' ? true : false;
    GetRequestModel requestModel =
        new GetRequestModel(authid:appKey, section: section, count: count);
    setState(() {
      isApiCallProcess = true;
    });

    APIServiceList apiService = new APIServiceList();
    apiService.getQuestions(requestModel).then((value) async {
      setState(() {
        isApiCallProcess = false;
      });
      if (value.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value.message),
          duration: Duration(seconds: 5),
        ));
      }
      if (!value.error) {
        
          for (var item in value.data['questions']) {
            List<String> answers = [];
            List<String> correctAnswers = [];
            for (var answersList in item['answers']) {
              answers.add(answersList['text']);
              if (answersList['correct']) {
                correctAnswers.add(answersList['text']);
              }
            }
            setState(() {
              questions.add(Question(
                  question: item['text'],
                  answers: answers,
                  correctAnswers: correctAnswers));
            });
          }
          setState(() {
            this.currentTitle = questions.first.question;
            this.currentCorrectAnswers = questions.first.correctAnswers;
            this.currentAnswers = questions.first.answers..shuffle();
          });
        
      }
    });
  }

  void verifyAndNext(BuildContext context) {
    
    bool allAnswersAreCorrect = false;
    for (var selectedAnswer in this.selectedAnswers) {
      String textSelectAnswer = this.currentAnswers[selectedAnswer];
      if (this.currentCorrectAnswers.contains(textSelectAnswer)) {
        allAnswersAreCorrect = true;
      } else {
        allAnswersAreCorrect = false;
        break;
      }
    }
    if (allAnswersAreCorrect) {
      setState(() {
        this.corrects++;
      });
    }
    this.nextQuestion(context);
  }

  void nextQuestion(BuildContext context) {
    int actualQuestion = this.currentQuestion;
    if (actualQuestion + 1 < this.questions.length) {
      setState(() {
        this.previousAnswers = this.selectedAnswers;
        this.currentQuestion++;
        this.currentTitle = this.questions[actualQuestion + 1].question;
        this.currentCorrectAnswers =
            this.questions[actualQuestion + 1].correctAnswers;
        this.currentAnswers = this.questions[actualQuestion + 1].answers
          ..shuffle();
        this.selectedAnswers = [];
      });
    } else {
      Navigator.pushReplacementNamed(context, 'result',
          arguments: ScreenArguments(
            this.corrects,
            this.questions.length,
            this.now,
          ));
    }
  }

  void previousQuestion(BuildContext context) {
    int actualQuestion = this.currentQuestion;
    setState(() {
      this.currentQuestion--;
      this.currentTitle = this.questions[actualQuestion - 1].question;
      this.currentCorrectAnswers =
          this.questions[actualQuestion - 1].correctAnswers;
      this.currentAnswers = this.questions[actualQuestion - 1].answers;
      this.selectedAnswers = this.previousAnswers;
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
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child:
        this.questions.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  bottom: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                       if (_bannerAd != null)
                                Column(
                                  children: [
                                    Container(
                                      width: _bannerAd!.size.width.toDouble(),
                                      height: _bannerAd!.size.height.toDouble(),
                                      child: AdWidget(ad: _bannerAd!),
                                    ),
                                     ],
                                ),
                                
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, 'start');
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 32.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(                          
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[   
                            Column(children:[
                              Text("Started At",style:TextStyle(color:Colors.white,fontSize:12)),
                              Text(_startedAt,style:TextStyle(color:Colors.white,fontSize:12)),
                            ])  ,                     
                             
                            Column(children:[
                              Text("Current",style:TextStyle(color:Colors.white,fontSize:12)),
                              Text(_timeString,style:TextStyle(color:Colors.white,fontSize:12)),
                            ]) 
                          
                        ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        
                        
                        Text(
                          'Question ${this.currentQuestion + 1}',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '/${this.questions.length}',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        this.currentTitle.replaceAll('<br>', '\n'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: this.currentAnswers.length + 1,
                        itemBuilder: (context, index) {
                          if (index == this.currentAnswers.length) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (this.currentTitle !=
                                    this.questions.first.question)
                                  GestureDetector(
                                    onTap: () {
                                      this.previousQuestion(context);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 15.0,
                                        horizontal: 30.0,
                                      ),
                                      padding: const EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                        color: (this
                                                .selectedAnswers
                                                .contains(index))
                                            ? Colors.grey
                                            : theme.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(180.0),
                                      ),
                                      child: Text(
                                        'Previous',
                                        textAlign: TextAlign.center,
                                        maxLines: 5,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: () {
                                     
                                    if (!this.showAnswers) {
                                      if (this.selectedAnswers.isNotEmpty){
                                        // if(this.currentQuestion%4 == 0){
                                        //   if (_interstitialAd != null) {
                                        //         _interstitialAd?.show();
                                        //       }
                                        // }
                                          this.verifyAndNext(context);
                                      }else{
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text("Select atleast one answer to continue"),
                                          duration: Duration(seconds: 5),
                                        ));
                                      }
                                        
                                    } else {
                                      this.verifyAndNext(context);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 15.0,
                                      horizontal: 30.0,
                                    ),
                                    padding: const EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                      color:
                                          (this.selectedAnswers.contains(index))
                                              ? Colors.grey
                                              : theme.primaryColor,
                                      borderRadius:
                                          BorderRadius.circular(180.0),
                                    ),
                                    child: Text(
                                      'Next',
                                      textAlign: TextAlign.center,
                                      maxLines: 5,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }
                          String answer = this.currentAnswers[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (this.selectedAnswers.contains(index)) {
                                  this.selectedAnswers.remove(index);
                                } else {
                                  this.selectedAnswers.add(index);
                                }
                              });
                            },
                            child: QuizOption(
                              index: index,
                              selectedAnswers: this.selectedAnswers,
                              correctAnswer: this.currentCorrectAnswers,
                              showAnswer: showAnswers,
                              answer: answer,
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            : isApiCallProcess
                ? Container()
                : Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Failed to load test!" ,style: TextStyle(color: Colors.white,fontSize: 18),),
                        if (questions.isEmpty) 
                        Text("No questions available for "+widget.startValues.section,style: TextStyle(color: Colors.red),),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Start();
                            }));
                          },
                          child: CustomButton(text: 'Try again '),
                        )
                      ],
                    ),
                  ),
                              
        
    ));
  }
}
