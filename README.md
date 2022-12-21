# Paperfold
<p align="center">
<a href="https://github.com/flutter/packages/tree/master/packages/flutter_lints"><img src="https://img.shields.io/badge/style-flutter_lints-40c4ff.svg" alt="style: flutter lints"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
</p>

---
<p>This package provides a widget which applies a paper fold effect on it's child. You can choose between horizontal and vertical fold direction. The number of strips has to be at least two.</p>

<img src="https://github.com/dasRicardo/flutter_paperfold/raw/main/paperfold.gif" alt="preview" width="200" height="433" />

# Getting startet

## Installation
Add `paperfold` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/). Or run `pub add paperfold` in your terminal.

## Usage
Just add the widget to your tree and you're done :). Take a look at example to see more.

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
- User interactions (gestures etc.) with child only possible in unfold state. (0 <= fold value < 1)
- Child widgets can't be animated. This is also valid for videos. You can wrap it by the paperfold, but the content will not update in folded state.

## Issues
Feel free to file any [issues, bugs, or feature requests](https://github.com/dasRicardo/flutter_paperfold/issues).
All contributions are welcome :)

## License
<a href="https://opensource.org/licenses/BSD-3-Clause"><img src="https://img.shields.io/badge/License-BSD_3--Clause-blue.svg?longCache=true" alt="BSD-3-Clause"></a>

## Special thx
Special thanks to GwaedGlas for reviewing and sparring this package
