import 'dart:html';

import 'package:LoaderLib/Loader.dart';

import 'scripts/SystemPrint.dart';

String caption;
const String podUrl = "http://farragnarok.com/PodCasts/";

//sorry wastes, these passwords are going to be much, much harder than the pod casts, especially since we have to slowly wire them up :) :) :)
void main()
{
    String initPW = "";
    if(Uri.base.queryParameters['passPhrase'] != null) {
        initPW = Uri.base.queryParameters['passPhrase'];
    }

    caption = initPW;
    hack(caption);
}

Future<void> hack(String file) async{
    try {
        final ImageElement image = await Loader.getResource("$podUrl$file.png");
        final ImageElement currentImage = querySelector("#srcImg0");
        currentImage.src = image.src; //sync them.
    }on Exception {
        SystemPrint.print("Invalid Passphrase!");
    }
}