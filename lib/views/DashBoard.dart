import 'dart:convert';

import 'package:ewallet_hackathon/ccValidator/input_formatters.dart';
import 'package:ewallet_hackathon/ccValidator/payment_card.dart';
import 'package:ewallet_hackathon/viewCardDetails/CardDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:http/http.dart' as http;
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navDrawer/CustomDrawer.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key key}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = new GlobalKey<FormState>();
  var numberController = new TextEditingController();
  var _paymentCard = PaymentCard();
  var _autoValidateMode = AutovalidateMode.disabled;
  final _cardNumberController = TextEditingController();
  String cardNumber;

  var _card = new PaymentCard();

  FSBStatus drawerStatus;
  List users = [];
  List cardDetails = [];
  List failedTransactions = [];
  String balanceAmt;
  String transDate;
  bool _isDialogShowing = false;
  ProgressHUD _progressHUD;

  bool _loading = true;

  String phpUrl =
      "https://jaysharma8.000webhostapp.com/getBankUserFailedTransactionForParticularDate.php";

  @override
  void initState() {
    super.initState();
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
    /*setupAlanVoice();*/
    fetchUser();
  }

  /*pageVisuals() {
    setState(() {
      setVisuals("first");
    });
  }*/

  /*setupAlanVoice() {
    AlanVoice.addButton(
      "cf5e5707f0cb663630fb2385e6de925f2e956eca572e1d8b807a3e2338fdd0dc/stage",
      buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT,
    );
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
    pageVisuals();
    //Alan Voice Setup
  }*/

  /*_handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "info":
        break;
      case "statement":
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SuccessTransactions()),
          );
          setVisuals("second");
        }
        break;
      case "failed":
        if (mounted) {
          openFailedTransactionPage();
          setVisuals("third");
        }
        break;
      case "failed5":
        if (mounted) {
          openFailed5TransactionPage();
          setVisuals("third");
        }
        break;
      case "failed10":
        if (mounted) {
          openFailed10TransactionPage();
          setVisuals("third");
        }
        break;
      case "show_data":
        if (mounted) {
          transDate = response["id"];
          if (transDate.contains("th") |
              transDate.contains("st") |
              transDate.contains("rd") |
              transDate.contains("nd") |
              transDate.contains("of")) {
            transDate = transDate.replaceAll("th", "");
            transDate = transDate.replaceAll("st", "");
            transDate = transDate.replaceAll("rd", "");
            transDate = transDate.replaceAll("nd", "");
            transDate = transDate.replaceAll("of", "");
            transDate = transDate.replaceAll("  ", " ");
            //Fluttertoast.showToast(msg: transDate);
            //print(transDate);
            sendData(transDate);
          }
        }
        break;
      case "dialog":
        if (mounted) {
          if (_isDialogShowing == true) {
            Navigator.of(context).maybePop();
          }
        }
        break;
      case "balance":
        break;
      case "money":
        break;
      case "send_money":
        if (mounted) {
          Fluttertoast.showToast(msg: response["id"]);
          convStrToNum(response["id"]);
        }
        break;
      case "exit_app":
        if (mounted) {
          SystemNavigator.pop();
        }
        break;
      default:
        print("Command was ${response["command"]}");
        break;
    }
  }*/

  getCardDetails() async {
    String apiUrl =
        "https://jaysharma8.000webhostapp.com/getCardDetails.php"; //api url
    cardNumber = numberController.text;

    var response = await http.post(Uri.parse(apiUrl), body: {
      'cardNo': cardNumber.replaceAll(' ', ''), //get the username text
    });

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body)['viewPinDebitCards'];
      cardDetails = jsonData;
      cardDetails[0]['name'].toString();
      cardDetails[0]['cardNo'].toString();
      cardDetails[0]['issueDate'].toString();
      cardDetails[0]['expiryDate'].toString();
      //print(cardDetails[0]['name'].toString());
      //print(cardDetails[0]['cardNo'].toString());
      //print(cardDetails[0]['issueDate'].toString());
      //print(cardDetails[0]['expiryDate'].toString());

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('name', cardDetails[0]['name'].toString());
      prefs.setString('cardNo', cardDetails[0]['cardNo'].toString());
      prefs.setString('issueDate', cardDetails[0]['issueDate'].toString());
      prefs.setString('expiryDate', cardDetails[0]['expiryDate'].toString());
      //getStringValuesSF();
      Navigator.pop(context);
      numberController.clear();
      openCardDetailsPage();
      //dismissProgressHUD();
    }
  }

  void openCardDetailsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CardDetails()),
    );
  }

  /*void openStatementPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SuccessTransactions()),
    );
  }*/

  fetchUser() async {
    var response = await http
        .get(Uri.https("jaysharma8.000webhostapp.com", "getBankUserInfo.php"));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body)['userInfo'];
      if (mounted) {
        setState(() {
          users = jsonData;
        });
      }
    } else {
      users = [];
      print("Loading");
    }
  }

  void dismissProgressHUD() {
    setState(() {
      if (_loading) {
        _progressHUD.state.dismiss();
      } else {
        _progressHUD.state.show();
      }

      _loading = !_loading;
    });
  }

  /*Future<int> convStrToNum(String str) async {
    var oneTen = <String, num>{
      'one': 1,
      'two': 2,
      'three': 3,
      'four': 4,
      'five': 5,
      'six': 6,
      'seven': 7,
      'eight': 8,
      'nine': 9,
      'ten': 10,
      'two hundred': 200,
      'fifty': 50,
      'hundred': 100,
    };
    if (oneTen.keys.contains(str)) {
      if (oneTen[str] < 52000) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RazorPay(oneTen[str])),
        );
        //setVisuals("fourth");
      }
    }
    return oneTen[str];
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      floatingActionButton: Container(
        height: 30.0,
        width: 30.0,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Color(0xfffcc900).withOpacity(0.4),
            child: Container(
              margin: EdgeInsets.all(17),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('asset/images/menu.png'),
                ),
              ),
            ),
            onPressed: () {
              setState(
                () {
                  drawerStatus = drawerStatus == FSBStatus.FSB_OPEN
                      ? FSBStatus.FSB_CLOSE
                      : FSBStatus.FSB_OPEN;
                },
              );
            },
          ),
        ),
      ),
      body: FoldableSidebarBuilder(
        //drawerBackgroundColor: Colors.deepOrange,
        drawer: CustomDrawer(
          closeDrawer: () {
            setState(() {
              drawerStatus = FSBStatus.FSB_CLOSE;
            });
          },
        ),
        screenContents: Container(
          padding: EdgeInsets.only(
            bottom: 30,
            top: 30,
            left: 10,
            right: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage('asset/images/logo.png'),
                        )),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "eWallet",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'ubuntu',
                            fontSize: 25),
                      )
                    ],
                  ),
                  if (users.length != 0)
                    Text(
                      users[0]['name'].toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    Container(),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Account Overview",
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'avenir'),
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          new LengthLimitingTextInputFormatter(16),
                          new CardNumberInputFormatter()
                        ],
                        controller: numberController,
                        decoration: new InputDecoration(
                          border: const UnderlineInputBorder(),
                          filled: true,
                          icon: CardUtils.getCardIcon(_paymentCard.type),
                          hintText: 'Enter Card Number',
                        ),
                        onSaved: (String value) {
                          print('onSaved = $value');
                          print(
                              'Num controller has = ${numberController.text}');
                          _paymentCard.number =
                              CardUtils.getCleanedNumber(value);
                        },
                        validator: CardUtils.validateCardNum,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  TextButton(
                    child: Text("View".toUpperCase(),
                        style: TextStyle(fontSize: 12)),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(10)),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color(0xff130f49),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(
                            color: Color(0xff130f49),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      showAlertDialog(context);
                      getCardDetails();
                      //_progressHUD.state.dismiss();
                    },
                  ),
                ],
              ),
              /* Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Send Money",
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'avenir'),
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('asset/images/scanqr.png'))),
                  )
                ],
              ),*/
              /*SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                child: Row(
                  children: [
                    InkWell(
                      //onTap: openPaymentPage,
                      child: Container(
                        height: 70,
                        width: 70,
                        margin: EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xffffac30),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 40,
                        ),
                      ),
                    ),
                    avatarWidget("avatar1", "Mike"),
                    avatarWidget("avatar2", "Joseph"),
                    avatarWidget("avatar3", "Ashley"),
                  ],
                ),
              ),*/
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Services',
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'avenir'),
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    child: Icon(Icons.dialpad),
                  )
                ],
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  physics: BouncingScrollPhysics(),
                  children: [
                    serviceWidget("sendMoney", "Send\nMoney"),
                    serviceWidget("receiveMoney", "Receive\nMoney"),
                    serviceWidget("phone", "Mobile\nRecharge"),
                    serviceWidget("electricity", "Electricity\nBill"),
                    serviceWidget("tag", "Cashback\nOffer"),
                    serviceWidget("movie", "Movie\nTicket"),
                    serviceWidget("flight", "Flight\nTicket"),
                    serviceWidget("more", "More\n"),
                  ],
                ),
              )
            ],
          ),
        ),
        status: drawerStatus,
      ),
    );
  }

  Column serviceWidget(String img, String name) {
    return Column(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.r)),
                color: Color(0xfff1f3f6),
              ),
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('asset/images/$img.png'))),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'avenir',
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Container avatarWidget(String img, String name) {
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      height: 100.h,
      width: 120.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.r)),
          color: Color(0xfff1f3f6)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 60.h,
            width: 60.w,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: DecorationImage(
                    image: AssetImage('asset/images/$img.png'),
                    fit: BoxFit.contain),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                )),
          ),
          Text(
            name,
            style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'avenir',
                fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
  }

  /*void openFailedTransactionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FailedTransactions()),
    );
    setVisuals("third");
  }

  void openFailed5TransactionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Failed5Transactions()),
    );
    setVisuals("third");
  }

  void openFailed10TransactionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Failed10Transactions()),
    );
    setVisuals("third");
  }*/

  Future<void> sendData(String transactionDate) async {
    var response = await http.post(Uri.parse(phpUrl), body: {
      "date": transactionDate,
    }); //sending post request with header data

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body)['transactions'];
      if (mounted) {
        setState(() {
          failedTransactions = jsonData;
          for (dynamic user in failedTransactions) {
            _asyncConfirmDialog(
              context,
              user["transAmt"],
              user["reason"],
              user["destination"],
              user["date"],
            );
          }
        });
      }
    } else {
      failedTransactions = [];
      Fluttertoast.showToast(msg: "No Data Found");
    }
  }

  Future _asyncConfirmDialog(BuildContext context, String transAmt,
      String reason, String destination, String date) async {
    _isDialogShowing = true;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text(
              'Failed Transaction',
              style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.date_range, size: 22),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          date,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Icon(Icons.monetization_on, size: 22),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          transAmt,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Icon(Icons.description, size: 22),
                        SizedBox(
                          width: 5.0,
                        ),
                        Flexible(
                          child: Text(
                            destination,
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Icon(Icons.error, size: 22),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          reason,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                    _isDialogShowing = false;
                  })
            ],
          );
        });
  }

  /*void setVisuals(String screen) {
    var visual = "{\"screen\":\"$screen\"}";
    AlanVoice.setVisualState(visual);
  }*/
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.always; // Start validating on every change.
      });
      _showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      // Encrypt and send send payment details to payment gateway
      _showInSnackBar('Payment card is valid');
    }
  }

  void _showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(value),
      duration: new Duration(seconds: 3),
    ));
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 5), child: Text("Loading")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
