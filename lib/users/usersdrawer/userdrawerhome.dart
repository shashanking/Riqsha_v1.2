import 'package:flutter/material.dart';
import 'package:last_mile_v2/localization/language_constants.dart';
import 'package:last_mile_v2/users/configmaps.dart';

class UserDrawerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userCurrentInfo.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 65.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            // maybe need to change title to drivertitle

            SizedBox(
              height: 20.0,
              width: 200.0,
              child: Divider(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40.0),

            InfoCard(
              text: userCurrentInfo.phone,
              icon: Icons.phone,
              
            ),
            InfoCard(
              text: userCurrentInfo.email,
              icon: Icons.email,
              
            ),

            FlatButton(
              color: Colors.green,
              onPressed: () {
                // Navigator.of(context).push(MaterialPageRoute(
                //   builder: (context) => UserMainScreen(),
                // ));
                Navigator.pop(context);
              },
              child: Text(
                getTranslated(context, "Go Back"),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onPressed;

  InfoCard({
    this.text,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 25.0,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.black87,
          ),
          title: Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
