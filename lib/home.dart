import 'dart:math';

import 'package:flutter/material.dart';
import 'package:heart/main.dart';
import 'package:heart_bpm/chart.dart';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:collection/collection.dart';
import 'package:cool_alert/cool_alert.dart';

class _HeartBPM {
  final double weight;
  final int value;

  _HeartBPM({
    required this.value,
    required this.weight,
  });
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SensorValue> data = [];
  List<SensorValue> bpmValues = [];
  List<SensorValue> fftValues = [];
  //  Widget chart = BPMChart(data);

  int? currentValue;
  double? currentReliability;

  List<_HeartBPM> heartRateValues = [];

  bool isBPMEnabled = false;
  Widget? dialog;

  double? sum;
  double? weight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          isBPMEnabled
              ? SizedBox()
              : Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: AssetImage("assets/background.jpg"))),
                ),
          ListView(
            children: [
              isBPMEnabled
                  ? dialog = Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 20),
                      child: SizedBox(
                        height: 120,
                        width: 80,
                        child: HeartBPMDialog(
                          context: context,
                          layoutType: HeartBPMDialogLayoutType.circle,
                          onRawData: (value) {
                            setState(() {
                              if (data.length >= 100) data.removeAt(0);
                              data.add(value.first);
                            });
                          },
                          onBPM: (value, kek) => setState(() {
                            if (bpmValues.length >= 100) bpmValues.removeAt(0);
                            bpmValues.add(SensorValue(
                                value: value.toDouble(), time: DateTime.now()));
                            currentValue = value;

                            heartRateValues
                                .add(_HeartBPM(value: value, weight: kek));

                            sum = heartRateValues.reversed
                                .take(50)
                                .map((e) => e.value * e.weight)
                                .sum;
                            weight = heartRateValues.reversed
                                .take(50)
                                .map((e) => e.weight)
                                .sum;

                            currentReliability =
                                weight! / min(heartRateValues.length, 50);
                          }),
                          onFFT: (value) {
                            fftValues = value;
                          },
                        ),
                      ),
                    )
                  : SizedBox(),
              // if (bpmValues.isNotEmpty) Text('Current value: $currentValue'),
              // if (bpmValues.isNotEmpty)
              //   Text(
              //     'Current value\'s reliability: ${currentReliability?.toStringAsFixed(2)}',
              //   ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (bpmValues.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Heart Rate BPM: ${sum == null ? null : sum! ~/ weight!}',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    ),
                  isBPMEnabled && data.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: Colors.red)),
                            height: 150,
                            child: BPMChart(data),
                          ),
                        )
                      : Container(
                          height: 10,
                        ),
                  isBPMEnabled && bpmValues.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: Colors.red)),
                            constraints: BoxConstraints.expand(height: 150),
                            child: BPMChart(bpmValues),
                          ),
                        )
                      : Container(
                          height: 10,
                        ),
                  isBPMEnabled && fftValues.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: Colors.red)),
                            constraints: BoxConstraints.expand(height: 150),
                            child: BPMChart(fftValues),
                          ),
                        )
                      : Container(
                          height: 10,
                        ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: TextButton(
                          onPressed: () => setState(() {
                            if (isBPMEnabled) {
                              isBPMEnabled = false;

                              CoolAlert.show(
                                context: context,
                                type: CoolAlertType.success,
                                text:
                                    'Your Heart Rate BPM is : ${sum == null ? null : sum! ~/ weight!}',
                                titleTextStyle: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textTextStyle: TextStyle(
                                  color: Colors.blue[500],
                                  fontSize: 14,
                                ),
                              );
                            } else
                              isBPMEnabled = true;
                          }),
                          child: Text(
                            isBPMEnabled ? "Stop measurement" : "Measure BPM",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),

              // child: ElevatedButton.icon(
              //   icon: Icon(Icons.favorite_rounded),
              //   label: Text(isBPMEnabled ? "Stop measurement" : "Measure BPM"),
              //   onPressed: () => setState(() {
              //     if (isBPMEnabled) {
              //       isBPMEnabled = false;
              //       // dialog.
              //     } else
              //       isBPMEnabled = true;
              //   }),
              // ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
