import 'dart:async';
import 'dart:html';
import 'dart:web_audio';
import 'package:AudioLib/AudioLib.dart';
import 'package:CommonLib/Random.dart';
Random rand = new Random(13);

void main() {
  rand.nextInt();
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
      fuckAround(node, 0.1, 1);
    }
    });
}

void fuckAround(AudioBufferSourceNode node, double rate, int direction) async {
  node.playbackRate.value = rate;
  if(rate >0.9) {
    rate = 0.1;
    direction = 1;
  }else if(rate < 0.1) {
    direction = -1;
    rate = 0.9;
  }else{
    rate += 0.05 * direction;
  }

  if(rand.nextDouble() >0.9) {
    rate = rand.nextDoubleRange(0.1,10.0);
    if(rand.nextBool()) {
      direction = -1;
    }else {
      direction = 1;
    }

  }

  if(rand.nextDouble() >0.9) {
    direction = direction * -1;
  }

  new Timer(Duration(milliseconds: 200), ()
  {
    fuckAround(node, rate, direction);
  });}
