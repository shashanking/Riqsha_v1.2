import 'package:flutter/material.dart';
import 'package:last_mile_v2/models.dart/history.dart';
import 'package:last_mile_v2/users/assistants/assistantMethods.dart';

class DriverHistoryItem extends StatelessWidget {
  final History history;
  DriverHistoryItem({this.history});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    Image.asset(
                      "images/pickicon.png",
                      height: 16,
                      width: 16,
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: Container(
                        child: Flexible(
                          child: Text(
                            history.pickup,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "₹${history.fares}",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset("images/desticon.png", height: 16, width: 16),
                  SizedBox(width: 18),
                  Flexible(
                      child: Text(
                    history.dropOff,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18),
                  )),
                ],
              ),
              SizedBox(height: 8.0),
              Text(history.status),
              SizedBox(height: 8.0),
              Text(
                AssistantMethods.formatTripDate(history.createdAt),
                style: TextStyle(color: Colors.grey),
              )
            ],
          )
        ],
      ),
    );
  }
}
