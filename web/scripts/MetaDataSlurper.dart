import 'dart:convert';
import 'dart:html';

import 'package:CommonLib/Utility.dart';
import 'package:LoaderLib/Loader.dart';

import 'SystemPrint.dart';

abstract class MetaDataSlurper {
    static String gigglesnort;
    static String speaker;
    static String keywords;
    static String summary;
    static const String key = "AUDIOLOGSCASETTELIBRARY";


    static Future<void> loadMetadata(String passphrase) async {
        storeTape(passphrase);
        printFoundTapes();
        try {
            final dynamic jsonRet = await Loader.getResource(
                "http://farragnarok.com/PodCasts/${passphrase}.json");
            final JsonHandler json = new JsonHandler(jsonRet);
            speaker = json.getValue("speaker");
            keywords = json.getValue("keywords");
            summary = json.getValue("summary");

            if(jsonRet.containsKey("gigglesnort")) {
                gigglesnort = json.getValue("gigglesnort");
            }else {
                gigglesnort = null;
            }
            printMe();
        } on LoaderException {
            SystemPrint.print("Metadata not found. JR must not have gotten to this one yet?");
        }
    }

    static void printMe() {
        SystemPrint.print("Speaker: $speaker");
        SystemPrint.print("Keywords: $keywords");
        SystemPrint.print("Summary: $summary");
        if(gigglesnort != null) {
            SystemPrint.print("There is gigglesnort here. But you can't access it yet.");
            //SystemPrint.print("Gigglesnort: $gigglesnort");
        }

    }

    static void printFoundTapes() {
        if(window.localStorage == null) {
            final String existing = window.localStorage[key];
            final List<String> parts = existing.split(",");
            SystemPrint.print("Found tapes is ${parts.length} long. $existing");
        }else {
            print("saving isn't possible....you don't have local storage");
        }

    }

    //if you haven't already heard this tape, add it.
    static void storeTape(String tapeName) {
        if(window.localStorage == null) {
            print("saving isn't possible....you don't have local storage");
            return;
        }
        try {
            if (window.localStorage.containsKey(key)) {
                final String existing = window.localStorage[key];
                final List<String> parts = existing.split(",");
                if (!parts.contains(tapeName)) window.localStorage[key] = "$existing,$tapeName";
            } else {
                window.localStorage[key] = tapeName;
            }
        }on Exception {
            print("Saving isn't possible....you don't have local storage");
        }
    }
}