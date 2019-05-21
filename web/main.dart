import 'dart:html';
import 'package:AudioLib/AudioLib.dart';

void main() {
  Element output = querySelector("#output");

  new Audio("http://farragnarok.com/PodCasts");
  Audio.createChannel("Voice");

  InputElement input = new InputElement()..value = "Passphrase";
  output.append(input);

  ButtonElement button = new ButtonElement()..text = "Play";
  output.append(button);
  button.onClick.listen((MouseEvent event){
    Audio.play(input.value, "Voice");
    });
}
