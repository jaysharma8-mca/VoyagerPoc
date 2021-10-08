import 'package:alan_voice/alan_voice.dart';
import 'package:ewallet_hackathon/views/DashBoard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    setupAlan();
  }

  setupAlan() {
    setState(() {
      AlanVoice.removeButton();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveBuilder(
        builder: (context, size) {
          if (size.isMobile)
            return Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('asset/images/sideImg.png'),
                        fit: BoxFit.cover),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image:
                                            AssetImage('asset/images/logo.png'),
                                        fit: BoxFit.contain)),
                              ),
                              Text(
                                "eWallet",
                                style: TextStyle(
                                    fontSize: 50,
                                    fontFamily: 'ubuntu',
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Open An Account For \nDigital E-Wallet Solutions. \nInstant Payouts.",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(
                                height: 40.h,
                              ),
                              SizedBox(
                                width: 220,
                                height: 60,
                                child: ElevatedButton.icon(
                                  label: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  icon: Icon(Icons.arrow_forward),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DashBoard()),
                                    );
                                    //Set visual state to `second`
                                    setVisuals("first");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          return Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.15,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('asset/images/sideImg.png'),
                      fit: BoxFit.cover),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image:
                                          AssetImage('asset/images/logo.png'),
                                      fit: BoxFit.contain)),
                            ),
                            Text(
                              "eWallet",
                              style: TextStyle(
                                  fontSize: 50,
                                  fontFamily: 'ubuntu',
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Open An Account For \nDigital E-Wallet Solutions. \nInstant Payouts.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(
                              height: 40.h,
                            ),
                            ElevatedButton.icon(
                              icon: Icon(Icons.thumb_up),
                              label: Text("Like"),
                              onPressed: () => print("it's pressed"),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void openHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DashBoard()),
    );
    setVisuals("first");
  }

  void setVisuals(String screen) {
    var visual = "{\"screen\":\"$screen\"}";
    AlanVoice.setVisualState(visual);
  }
}
