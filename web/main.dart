import 'dart:html';
import 'dart:web_audio';
import 'package:AudioLib/AudioLib.dart';

void main() {
  Element output = querySelector("#output");

  new Audio("http://farragnarok.com/PodCasts");
  Audio.createChannel("Voice");

  InputElement input = new InputElement()..value = "Passphrase";
  output.append(input);

  ButtonElement button = new ButtonElement()..text = "Play";
  output.append(button);
  output.append(Audio.slider(Audio.SYSTEM.volumeParam));

  button.onClick.listen((MouseEvent event) async {
    try {
      AudioBufferSourceNode node = await Audio.play(input.value, "Voice");
      output.append(Audio.slider(node.playbackRate));

    }catch(e) {
      AudioBufferSourceNode node = await Audio.play("warning", "Voice",pitchVar: 13.0)..playbackRate.value = 0.1;
      output.append(Audio.slider(node.playbackRate));

    }
    });
}
