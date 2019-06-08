import 'dart:convert';

import 'package:CommonLib/Logging.dart';
import 'package:CommonLib/Utility.dart';
import 'package:LoaderLib/Loader.dart';

abstract class SystemPrint {


   static  void print(String text, [int size = 18]) {
        const String fontFamiily = "'Courier New', Courier, monospace";
        const String fontWeight = "bold";
        const String fontColor = "#000000";
        final String consortCss = "font-family: $fontFamiily;color:$fontColor;font-size: ${size}px;font-weight: $fontWeight;";
        fancyPrint("Gigglette Player: $text",consortCss);
        /*final DivElement div = new DivElement()..style.fontFamily = fontFamiily..style.fontWeight=fontWeight..style.color=fontColor..style.fontSize="${size}px";
    div.text = text;
    system.text = "";
    system.append(div);*/
    }
}