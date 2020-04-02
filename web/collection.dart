import 'dart:html';

import 'scripts/AudioLogView.dart';
import 'scripts/MetaDataSlurper.dart';

Future<void> main() async {
 final DivElement output = querySelector("#collection");
 if(window.localStorage != null) {
     final String existing = window.localStorage[MetaDataSlurper.key];
     final List<String> parts = existing.split(",");
     final Set<String> uniqueParts = new Set.from(parts);
     for(String uniquePart in uniqueParts) {
        final AudioLogView view = new AudioLogView(uniquePart);
        view.display(output);
     }
 }else {
     print("Can't load tape deck: you don't have local storage");
 }
}