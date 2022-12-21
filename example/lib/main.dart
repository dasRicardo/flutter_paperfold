import 'package:flutter/material.dart';
import 'package:paperfold/paperfold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  var foldSliderValue = 1.0;
  var splitsSliderValue = 2.0;
  var mainAxis = PaperFoldMainAxis.horizontal;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter paper fold',
      home: Builder(builder: (context) {
        final pixelRatio = MediaQuery.of(context).devicePixelRatio;
        // final pixelRatio = 1.0;
        return Scaffold(
          backgroundColor: Colors.red,
          onDrawerChanged: (isOpened) {},
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _getContent(pixelRatio),
                  // _getContent(),
                  Align(
                    alignment: Alignment.topRight,
                    child: _getContent(pixelRatio),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: _getContent(pixelRatio),
                  ),
                  Slider(
                    value: foldSliderValue,
                    min: 0,
                    max: 1,
                    divisions: 100,
                    label: foldSliderValue.toString(),
                    onChanged: (double value) {
                      setState(() {
                        foldSliderValue = value;
                      });
                    },
                  ),
                  Slider(
                    value: splitsSliderValue,
                    min: 2,
                    max: 10,
                    divisions: 10,
                    label: splitsSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        splitsSliderValue = value;
                      });
                    },
                  ),
                  Row(
                    children: [
                      const Text("MainAxis: HORIZONTAL"),
                      Checkbox(
                        value: mainAxis == PaperFoldMainAxis.horizontal,
                        onChanged: (value) {
                          setState(() {
                            if (mainAxis == PaperFoldMainAxis.horizontal) {
                              mainAxis = PaperFoldMainAxis.vertical;
                            } else {
                              mainAxis = PaperFoldMainAxis.horizontal;
                            }
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _getContent(double pixelRatio) {
    return PaperFold(
      mainAxis: mainAxis,
      strips: splitsSliderValue.round(),
      foldValue: foldSliderValue,
      pixelRatio: pixelRatio,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Container(
          color: Colors.green,
          height: 150,
          child: ListView.builder(
            itemCount: 30,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.translate,
                        size: 50,
                      ),
                      Text("hello world, hello world")
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
