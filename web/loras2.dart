import 'dart:async';
import 'dart:html';

import 'package:LoaderLib/Loader.dart';

import 'scripts/MetaDataSlurper.dart';
import 'scripts/SystemPrint.dart';

String caption;
const String podUrl = "http://farragnarok.com/PodCasts/";

//sorry wastes, these passwords are going to be much, much harder than the pod casts, especially since we have to slowly wire them up :) :) :)
Future<void> main() async
{
    String initPW = "";
    if(Uri.base.queryParameters['passPhrase'] != null) {
        initPW = Uri.base.queryParameters['passPhrase'];
    }

    caption = initPW;
    //new Timer(Duration(milliseconds: 100), () => hack(caption));
    hack(caption);
    print("oh?");
}

Future<void> hack(String file, [int time = 0]) async{
    print("hacking $file for the $time time");
    hackQuip(file);
    try {
        final ImageElement image = await Loader.getResource("$podUrl$file.png");
        print("i found file $image");
        final ImageElement currentImage = querySelector("#srcImg0");
        print("current image is $currentImage");
        if(currentImage != null && image.src != null) {
            currentImage.src = image.src; //sync them.
        }else {
            print("is there some sort of race condition? i'll try again in a second");
            if(currentImage != null) {
                currentImage.onLoad.listen((Event e) {
                    print("i think it loaded???");
                    hack(file, time + 1);
                });
            }else if(time < 5){
                new Timer(Duration(milliseconds: 100), () =>
                    hack(file, time+1));
            }
        }
    }on Exception {
        SystemPrint.print("Invalid Passphrase for Image Retrieval!");
    }
}

Future<void> hackQuip(String file) async {
    final Element quip = querySelector("#quip");
    await MetaDataSlurper.loadMetadata(caption);
    quip.setInnerHtml("I can feel the gigglethroes taking me: <br><br>${MetaDataSlurper.gigglesnort.replaceAll("\n","<br>")}");
}