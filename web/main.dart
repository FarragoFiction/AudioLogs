import 'dart:async';
import 'dart:html';
import 'dart:web_audio';
import 'package:AudioLib/AudioLib.dart';
import 'package:CommonLib/Random.dart';
Random rand = new Random(13);

//the sources we'll use for wrong passphrases
//TODO choose which of the absolutebullshit to choose based on the content of the input
List<String> absoluteBullshit = <String>["warning","weird","conjecture", "Verthfolnir_Podcast","echidnas","dqon"];

//the sources we'll use for wrong passphrases bg music
List<String> soothingMusic = <String>["Verthfolnir","Splinters_of_Royalty","Shooting_Gallery","Ares_Scordatura","Vargrant","Campfire_In_the_Void", "Flow_on_2","Noirsong","Saphire_Spires"];

void main() {
  rand.nextInt();
  Element output = querySelector("#output");

  new Audio("http://farragnarok.com/PodCasts");
  Audio.SYSTEM.rand = rand;
  AudioChannel voice = Audio.createChannel("Voice");
  AudioChannel bg = Audio.createChannel("BG");

  String initPW = "Passphrase";
  if(Uri.base.queryParameters['passPhrase'] != null) {
    initPW = Uri.base.queryParameters['passPhrase'];
  }

  InputElement input = new InputElement()..value = initPW;
  output.append(input);
  changePassPhrase(input.value);


  ButtonElement button = new ButtonElement()..text = "Play";
  output.append(button);
  output.append(Audio.slider(Audio.SYSTEM.volumeParam));

  button.onClick.listen((MouseEvent event) async {
    changePassPhrase(input.value);
    try {
      AudioBufferSourceNode node = await Audio.play(input.value, "Voice");
      output.append(Audio.slider(node.playbackRate));

    }catch(e) {
      AudioBufferSourceNode node = await Audio.play(rand.pickFrom(absoluteBullshit), "Voice",pitchVar: 13.0)..playbackRate.value = 0.1;
      AudioBufferSourceNode nodeBG = await Audio.play(rand.pickFrom(soothingMusic), "BG",pitchVar: 13.0)..playbackRate.value = 0.1;
      bg.volumeParam.value = 0.3;

      fuckAround(node, 0.1, 1);
      fuckAround(nodeBG, 0.1, 1);

    }
    });
}

void changePassPhrase(String value) {
  setPassPhraseLink(value);
  rand.setSeed(convertSentenceToNumber(value));
}

void setPassPhraseLink(String passPhrase) {
  window.history.replaceState(<String,String>{}, "???", "${Uri.base.path}?passPhrase=${passPhrase}");
}

int convertSentenceToNumber(String sentence) {
  int ret = 0;
  for(int s in sentence.codeUnits) {
    ret += s;
  }
  return ret;
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
