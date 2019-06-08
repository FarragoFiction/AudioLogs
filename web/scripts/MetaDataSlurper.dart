import 'dart:convert';

import 'package:CommonLib/Utility.dart';
import 'package:LoaderLib/Loader.dart';

import 'SystemPrint.dart';

abstract class MetaDataSlurper {
    static String gigglesnort;
    static String speaker;
    static String keywords;
    static String summary;

    static Future<List<String>> loadMetadata(String passphrase) async {
        try {
            dynamic jsonRet = await Loader.getResource(
                "http://farragnarok.com/PodCasts/${passphrase}.json");
            JsonHandler json = new JsonHandler(jsonRet);
            speaker = json.getValue("speaker");
            keywords = json.getValue("keywords");
            summary = json.getValue("summary");

            if(jsonRet.containsKey("gigglesnort")) {
                gigglesnort = json.getValue("gigglesnort");
            }else {
                gigglesnort = null;
            }
            print();
        } on LoaderException {
            SystemPrint.print("Metadata not found. JR must not have gotten to this one yet?");
        }
    }

    static void print() {
        SystemPrint.print("Speaker: $speaker");
        SystemPrint.print("Keywords: $keywords");
        if(gigglesnort != null) {
            SystemPrint.print("gigglesnort: $speaker");
        }

    }
}