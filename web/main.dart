import 'dart:async';
import 'dart:html';
import 'dart:web_audio';
import 'package:AudioLib/AudioLib.dart';
import 'package:CommonLib/Random.dart';
Random rand = new Random(13);

//the sources we'll use for wrong passphrases
//TODO choose which of the absolutebullshit to choose based on the content of the input
List<String> absoluteBullshit = <String>["echidnamilk","charms4","charms3","charms2","charms1","warning","weird","conjecture", "Verthfolnir_Podcast","echidnas","dqon"];

//the sources we'll use for wrong passphrases bg music
List<String> soothingMusic = <String>["Vethrfolnir","Splinters_of_Royalty","Shooting_Gallery","Ares_Scordatura","Vargrant","Campfire_In_the_Void", "Flow_on_2","Noirsong","Saphire_Spires"];

//smaller numbers mean more changes means less understandable at once
int legibilityLevelInMS = 20;

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
      await bullshitCorruption(bg, input.value);
    }
    });
}

Future bullshitCorruption(AudioChannel bg, String value) async {
  List<String> corruptChannels = selectCorruptChannels(value);
  print("REMOVE THIS JR, but choose $corruptChannels");
  //each channel individually fucks up

  for(String channel in corruptChannels) {
    try {
      AudioChannel newchannel = Audio.createChannel(channel);
    }catch(e) {
      //it already exists, so we don't need to do anything
    }

    AudioBufferSourceNode node = await Audio.play(
        channel, channel, pitchVar: 13.0)
      ..playbackRate.value = 0.1;
    fuckAround(node, legibilityLevelInMS/1000, 1);
  }
  AudioBufferSourceNode nodeBG = await Audio.play(rand.pickFrom(soothingMusic), "BG",pitchVar: 13.0)..playbackRate.value = 0.1;
  bg.volumeParam.value = 0.3;
  print("legibilitiy level is $legibilityLevelInMS ;)");
  fuckAroundMusic(nodeBG, 0.1, 1);
}

//return all absolute bullshit that matches this.
//if nothing matches should still use the LETTERS (not the sum of them) to retrieve what files are invovled.
//this way you can see iterations of the same file by picking similar words
List<String> selectCorruptChannels(String value) {
  List<String> ret = new List<String>();
  absoluteBullshit.forEach((String bullshit) {
    if(bullshit.toLowerCase().startsWith(value.toLowerCase())){
      ret.add(bullshit);
    }
  });
  //the more letters you manage to match, the more legible it is.
  legibilityLevelInMS = 200 * value.length;

  if(ret.isNotEmpty) return ret;

  absoluteBullshit.forEach((String bullshit) {
    if(bullshit.toLowerCase().contains(value.toLowerCase())){
      ret.add(bullshit);
    }
  });
  legibilityLevelInMS = 100 * value.length;

  if(ret.isNotEmpty) return ret;

  absoluteBullshit.forEach((String bullshit) {
    if(bullshit.toLowerCase().startsWith(value.toLowerCase().substring(0,1))){
      ret.add(bullshit);
    }
  });
  legibilityLevelInMS = 200;

  if(ret.isNotEmpty) return ret;
  //you picked something just non existant
  //yes this allows repeats
  ret.add(rand.pickFrom(absoluteBullshit));
  ret.add(rand.pickFrom(absoluteBullshit));
  ret.add(rand.pickFrom(absoluteBullshit));
  int num = rand.nextIntRange(1,5);
  for(int i =0; i<num; i++) {
    ret.add(rand.pickFrom(absoluteBullshit));
  }
  legibilityLevelInMS = 20;

  return ret;
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
  if(rate >1000/legibilityLevelInMS || rate > 1.3) {
    rate = 0.1;
    direction = 1;
  }else if(rate < 0.1) {
    direction = -1;
    rate = 0.9;
  }

  rate += 0.05 * direction;

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
  int next = legibilityLevelInMS;
  if(legibilityLevelInMS < 200) {
    next = rand.nextIntRange(200, 1000);
  }
  new Timer(Duration(milliseconds: next), ()
  {
    fuckAround(node, rate, direction);
  });
}

void fuckAroundMusic(AudioBufferSourceNode node, double rate, int direction) async {
  node.playbackRate.value = rate;
  if(rate >0.5) {
    direction = -1;
  }else if(rate < 0.01) {
    direction = 1;
  }
    rate += 0.01 * direction;


  if(rand.nextDouble() >0.7) {
    direction = direction * -1;
  }

  new Timer(Duration(milliseconds: 20), ()
  {
    fuckAroundMusic(node, rate, direction);
  });
}
