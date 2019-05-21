import 'dart:html';
import 'package:AudioLib/AudioLib.dart';

void main() {
  Element output = querySelector("#output");
  ButtonElement button = new ButtonElement()..text = "Play";
  output.append(button);
  button.onClick.listen((MouseEvent event){
    new Audio("Audio");
    Audio.createChannel("Voice");
    Audio.play("warning", "Voice");
    });
}
