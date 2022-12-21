# Paperfold
<p align="center">  
<a href="https://github.com/flutter/packages/tree/master/packages/flutter_lints"><img src="https://img.shields.io/badge/style-flutter_lints-40c4ff.svg" alt="style: flutter lints"></a>  
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>  
<a href="https://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>  
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>  
</p>

---
<p>This package provides a simple to use widget to apply a paper fold effect on it's child. You can choose between horizontal and vertical fold direction, the number of strips are at least two.</p>

<img src="paperfold.gif" alt="preview" width="200" height="433" />

# Getting startet

## Installation
Add `paperfold` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

## Usage
Simply add the widget to your tree and done :). Take a look at example to see more.

```
PaperFold(
  mainAxis: PaperFoldMainAxis.vertical,
  strips: 4,
  foldValue: .5,
  pixelRatio: 1,//works best if you query the device pixel ration with MediaQuery.of
  child: ClipRRect(
    borderRadius: BorderRadius.all(Radius.circular(20)),
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
```

## Limitation
- no interaction (gesture detection) when the widget is folded (fold value < 1)
- no animations, videos or something, you can add it but no frame updates if the widget is folded (fold value < 1) so it will look weired

## Issues
Feel free to file any [issues, bugs, or feature requests](https://github.com/dasRicardo/flutter_paperfold/issues).
All contributions are welcome :)

## License
[MIT](https://choosealicense.com/licenses/mit/)
