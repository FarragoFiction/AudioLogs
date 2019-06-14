import 'dart:convert';

import 'package:CommonLib/Utility.dart';
import 'package:LoaderLib/Loader.dart';

abstract class GlitchSlurper {
    static List<String> glitchFiles;
    static String lastUpdated;

    static Future<List<String>> loadAbsoluteBullshit() async {
        dynamic jsonRet = await  Loader.getResource("http://farragnarok.com/PodCasts/glitches.json");
        JsonHandler json = new JsonHandler(jsonRet);
        glitchFiles = json.getArray("glitches");
        lastUpdated = json.getValue("lastUpdate");
        return glitchFiles;
    }
}