import 'dart:async';
import 'dart:html';
import 'dart:web_audio';

import 'package:AudioLib/AudioLib.dart';
import 'package:CommonLib/Logging.dart';
import 'package:CommonLib/Random.dart';

import "ui.dart";

Random rand = new Random(13);

//the sources we'll use for wrong passphrases
//TODO choose which of the absolutebullshit to choose based on the content of the input
List<String> absoluteBullshit = <String>["adults","void","voidplayers",'owo',"nope1","nope2","nope3","lohae","lilscumbag","ghoa","wolfcop","smokey","echidnamilk","charms4","charms3","charms2","charms1","warning","weird","conjecture", "Verthfolnir_Podcast","echidnas","dqon"];

//the sources we'll use for wrong passphrases bg music
List<String> soothingMusic = <String>["Vethrfolnir","Splinters_of_Royalty","Shooting_Gallery","Ares_Scordatura","Vargrant","Campfire_In_the_Void", "Flow_on_2","Noirsong","Saphire_Spires"];
Element system;
//smaller numbers mean more changes means less understandable at once
int legibilityLevelInMS = 20;
const String tapeIn = "casettein";
const String tapeOut = "cassetteout";

void main() {
    Keyboard.init();
    rand.nextInt();
    final Element output = querySelector("#output");
    output.append(Keyboard.element);
    system = new DivElement();
    output.append(system);

    new Audio("http://farragnarok.com/PodCasts");
    Audio.SYSTEM.rand = rand;
    final AudioChannel voice = Audio.createChannel("Voice");
    final AudioChannel bg = Audio.createChannel("BG");

    String initPW = "Passphrase";
    if(Uri.base.queryParameters['passPhrase'] != null) {
        initPW = Uri.base.queryParameters['passPhrase'];
    }

    final InputElement input = new InputElement()..value = initPW;
    output.append(input);
    changePassPhrase(input.value);


    final ButtonElement button = new ButtonElement()..text = "Play";
    button.autofocus = true;
    output.append(button);
    output.append(Audio.slider(Audio.SYSTEM.volumeParam));
    button.onClick.listen((MouseEvent event) async {
        systemPrint("wrrr...click!");
        changePassPhrase(input.value);
        try {
            await Audio.SYSTEM.load(input.value); //if theres a problem here, it will be caught.
        } on ProgressEvent {
            systemPrint("Error! Unknown Passphrase: ${input.value}");
            await bullshitCorruption(bg, input.value);
            return;
        }
        //Playlist playList = new Playlist(<String>[input.value]);

        final Playlist playList = new Playlist(<String>[tapeIn,input.value,tapeOut]);
        playList.output.connectNode(Audio.SYSTEM.channels["Voice"].volumeNode);
        await playList.play();
        systemPrint("Passphrase Accepted!");
    });
}

void systemPrint(String text, [int size = 18]) {
    const String fontFamiily = "'Courier New', Courier, monospace";
    const String fontWeight = "bold";
    const String fontColor = "#000000";
    final String consortCss = "font-family: $fontFamiily;color:$fontColor;font-size: ${size}px;font-weight: $fontWeight;";
    fancyPrint("Gigglette Player: $text",consortCss);
    final DivElement div = new DivElement()..style.fontFamily = fontFamiily..style.fontWeight=fontWeight..style.color=fontColor..style.fontSize="${size}px";
    div.text = text;
    system.text = "";
    system.append(div);
}

Future<void> bullshitCorruption(AudioChannel bg, String value) async {
    AudioBufferSourceNode node = await Audio.play(
        tapeIn, "Voice");
    await gigglesnort(value);
    final String music = rand.pickFrom(soothingMusic);
    print("music chosen is $music");
    final AudioBufferSourceNode nodeBG = await Audio.play(music, "BG",pitchVar: 13.0)..playbackRate.value = 0.1;
    bg.volumeParam.value = 0.8;
    print("legibilitiy level is $legibilityLevelInMS ;)");
    fuckAroundMusic(nodeBG, 0.2, 1);
}

Future<void> gigglesnort(String value) async {
    final List<String> corruptChannels = selectCorruptChannels(value);
    //print("REMOVE THIS JR, but choose $corruptChannels");
    //each channel individually fucks up
    //physically impossible to both layer noises AND have a tape in/tape out sound
    for(final String channel in corruptChannels) {
        try {
            AudioChannel newchannel = Audio.createChannel(channel);
        } on Exception {
            //it already exists, so we don't need to do anything
        }

        final AudioBufferSourceNode node = await Audio.play(
            channel, channel, pitchVar: 13.0)
            ..playbackRate.value = 0.1;
        fuckAround(node, legibilityLevelInMS/1000, 1);
    }
}

//return all absolute bullshit that matches this.
//if nothing matches should still use the LETTERS (not the sum of them) to retrieve what files are invovled.
//this way you can see iterations of the same file by picking similar words
List<String> selectCorruptChannels(String value) {
    final List<String> ret = <String>[];
    for (final String bullshit in absoluteBullshit) {
        if(bullshit.toLowerCase().startsWith(value.toLowerCase())){
            ret.add(bullshit);
        }
    }
    //the more letters you manage to match, the more legible it is.
    legibilityLevelInMS = 200 * value.length;

    if(ret.isNotEmpty) return ret;

    for(final String bullshit in absoluteBullshit) {
        if(bullshit.toLowerCase().contains(value.toLowerCase())){
            ret.add(bullshit);
        }
    }
    legibilityLevelInMS = 100 * value.length;

    if(ret.isNotEmpty) return ret;

    for (final String bullshit in absoluteBullshit) {
        if(bullshit.toLowerCase().startsWith(value.toLowerCase().substring(0,1))){
            ret.add(bullshit);
        }
    }
    legibilityLevelInMS = 200;

    if(ret.isNotEmpty) return ret;
    //you picked something just non existant
    //yes this allows repeats
    ret.add(rand.pickFrom(absoluteBullshit));
    ret.add(rand.pickFrom(absoluteBullshit));
    ret.add(rand.pickFrom(absoluteBullshit));
    final int num = rand.nextIntRange(1,5);
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
    window.history.replaceState(<String,String>{}, "???", "${Uri.base.path}?passPhrase=$passPhrase");
}

int convertSentenceToNumber(String sentence) {
    int ret = 0;
    for(final int s in sentence.codeUnits) {
        ret += s;
    }
    return ret;
}

Future<void> fuckAround(AudioBufferSourceNode node, double rate, int direction) async {
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

Future<void> fuckAroundMusic(AudioBufferSourceNode node, double rate, int direction) async {
    node.playbackRate.value = rate;
    if(rate >0.7) {
        direction = -1;
    }else if(rate < 0.1) {
        direction = 1;
    }
    rate += 0.001 * direction;


    if(rand.nextDouble() >0.7) {
        direction = direction * -1;
    }

    new Timer(Duration(milliseconds: 20), ()
    {
        fuckAroundMusic(node, rate, direction);
    });
}
