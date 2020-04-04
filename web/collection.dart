import 'dart:html';

import 'scripts/AudioLogView.dart';
import 'scripts/MetaDataSlurper.dart';

Future<void> main() async {
    final DivElement output = querySelector("#collection");
 if(window.localStorage != null) {
     final String existing = window.localStorage[MetaDataSlurper.key];
     if (existing == null) { return; }
     final List<String> parts = existing.split(",");
     for(String s in parts) {
        if(s == null || s.isEmpty) parts.remove(s);
     }
     final Set<String> uniqueParts = parts.toSet();
     for(final String uniquePart in uniqueParts) {
         if(uniquePart != null) {
             final AudioLogView view = new AudioLogView(uniquePart);
             view.display(output);
         }
     }
 }else {
     print("Can't load tape deck: you don't have local storage");
 }
}