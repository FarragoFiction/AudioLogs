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
    fuckAround(node, 0.1, 1);
  }
  AudioBufferSourceNode nodeBG = await Audio.play(rand.pickFrom(soothingMusic), "BG",pitchVar: 13.0)..playbackRate.value = 0.1;
  bg.volumeParam.value = 0.3;

  fuckAroundMusic(nodeBG, 0.1, 1);
}

//return all absolute bullshit that matches this.
//if nothing matches should still use the LETTERS (not the sum of them) to retrieve what files are invovled.
//this way you can see iterations of the same file by picking similar words
List<String> selectCorruptChannels(String value) {
  List<String> ret = new List<String>();
  //TODO first see if the thing starts with you.
  //then see if it contains you
  //then figure out a unique mapping from string start to file. maybe first letter?
  /*
  basically, what you want to do is first see if any start with what was passed in
  if none do, then look for contains
  if STILL none do, then grab only the first letter of the value and look for that
  if STILL STILL none do just pick one thing at random okay
   */
  absoluteBullshit.forEach((String bullshit) {
    if(bullshit.toLowerCase().startsWith(value.toLowerCase())){
      ret.add(bullshit);
    }
  });

  if(ret.isNotEmpty) return ret;

  absoluteBullshit.forEach((String bullshit) {
    if(bullshit.toLowerCase().contains(value.toLowerCase())){
      ret.add(bullshit);
    }
  });

  if(ret.isNotEmpty) return ret;

  absoluteBullshit.forEach((String bullshit) {
    if(bullshit.toLowerCase().startsWith(value.toLowerCase().substring(0,1))){
      ret.add(bullshit);
    }
  });

  if(ret.isNotEmpty) return ret;
  //you picked something just non existant
  ret.add(rand.pickFrom(absoluteBullshit));
  ret.add(rand.pickFrom(absoluteBullshit));
  ret.add(rand.pickFrom(absoluteBullshit));

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
  if(rate >0.9) {
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

  new Timer(Duration(milliseconds: 200), ()
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
