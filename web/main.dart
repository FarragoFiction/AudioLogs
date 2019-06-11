import 'dart:async';
import 'dart:html';
import "dart:math" as Math;
import 'dart:web_audio';

import 'package:AudioLib/AudioLib.dart';
import 'package:CommonLib/Logging.dart';
import 'package:CommonLib/Random.dart';
import "package:LoaderLib/Loader.dart";
import "package:CommonLib/Utility.dart";

import 'scripts/GlitchSlurper.dart';
import 'scripts/MetaDataSlurper.dart';
import 'scripts/SystemPrint.dart';
import "ui.dart";

Random globalRand = new Random(13);

//the sources we'll use for wrong passphrases
//List<String> absoluteBullshit = <String>["decay","guarded_mythos","adults","void","voidplayers",'owo',"nope1","nope2","nope3","lohae","lilscumbag","ghoa","wolfcop","smokey","echidnamilk","charms4","charms3","charms2","charms1","warning","weird","conjecture", "Verthfolnir_Podcast","echidnas","dqon"];
List<String> absoluteBullshit;
//the sources we'll use for wrong passphrases bg music
List<String> soothingMusic = <String>["Vethrfolnir","Splinters_of_Royalty","Shooting_Gallery","Ares_Scordatura","Vargrant","Campfire_In_the_Void", "Flow_on_2","Noirsong","Saphire_Spires"];
Element system;
//smaller numbers mean more changes means less understandable at once
int legibilityLevelInMS = 20;
const String tapeIn = "audio/casettein";
const String tapeOut = "audio/cassetteout";
const String podUrl = "http://farragnarok.com/PodCasts/";
const String audioUrl = "audio/";

final List<StoppedFlagNodeWrapper> nodes = <StoppedFlagNodeWrapper>[];

Element door = querySelector("#door");

bool playing = false;
PlayerMode mode = PlayerMode.typing;
//const int switchTime = 2500; // timing more precise, using explicit values now
enum PlayerMode {
    typing,
    transition,
    playing
}

Future<void> delay(int ms, Action action) {
    return new Future<void>.delayed(Duration(milliseconds: ms), action);
}

void switchToPlaying() {
    if (mode != PlayerMode.typing) { return; }
    mode = PlayerMode.transition;
    Keyboard.disable();

    cassette.cycleElement();
    cassette.element.classes.remove("cassetteRemove");
    cassette.element.classes.add("cassetteInsert");
    cassette.element.classes.add("cassetteFront");

    typewriterButton.press();
    keyboardLight.classes.remove("keyboardLightOn");

    delay(1250, () { // half way curve switch
        cassette.element.classes.remove("cassetteFront");
    });

    delay(1500, () { // insertion sound offset
        Audio.play("${audioUrl}cassettein", "ui");
    });

    delay(2500,(){ // finished
        mode = PlayerMode.playing;
        ejectButton.release(true);
        stopButton.press(true);
        door.classes.remove("door_open");
        door.classes.add("door_closed");
    });
}

void switchToTyping() {
    if (mode != PlayerMode.playing) { return; }
    mode = PlayerMode.transition;

    cassette.cycleElement();
    cassette.element.classes.remove("cassetteInsert");
    cassette.element.classes.add("cassetteRemove");

    door.classes.remove("door_closed");
    door.classes.add("door_open");

    Audio.play("${audioUrl}cassetteout", "ui");

    delay(1250, () { // half way curve switch
        cassette.element.classes.add("cassetteFront");
    });

    delay(2300, () { // clunk on typewriter insertion
        Audio.play("${audioUrl}button", "ui", basePitch: 1.4);
        typewriterButton.release(true);
    });

    delay(2500,(){ // finished
        mode = PlayerMode.typing;
        Keyboard.enable();
        keyboardLight.classes.add("keyboardLightOn");
    });
}

String caption = "";
const int maxLabelLength = 23;

void writeLetter(String glyph) {
    if(caption.length < maxLabelLength) {
        caption = "$caption$glyph";
        updateCaption();
    }
}

void backspace() {
    if (caption.isNotEmpty) {
        caption = caption.substring(0, Math.min(caption.length - 1, maxLabelLength-1));
        updateCaption();
    }
}

void updateCaption() {
    print("caption: $caption");
    String text = caption;
    if (caption.length > maxLabelLength) {
        text = "${text.substring(0, maxLabelLength-1)}…";
    }
    if (text.length < maxLabelLength) {
        text = "${text}_";
    }
    cassette.label.text = text;
    changePassPhrase(caption);
}

Future<void> pressPlay([Event e]) async {
    if (mode != PlayerMode.playing || playing) {
        return;
    }

    cassette.element.classes.add("cassettePlaying");

    playButton.press();
    stopButton.release(true);
    ejectButton.release(true);

    playing = true;
    systemPrint("wrrr...click!");
    final String file = "$podUrl$caption";
    try {
        await Audio.SYSTEM.load(file); //if theres a problem here, it will be caught.
        MetaDataSlurper.loadMetadata(caption);
    } on LoaderException {
        systemPrint("Error! Unknown Passphrase: $caption");
        if (playing) {
            absoluteBullshit = await GlitchSlurper.loadAbsoluteBullshit();
            systemPrint("Last Glitch Bullshit Update: ${GlitchSlurper.lastUpdated}");
            bullshitCorruption(caption);
            narrativeGauge..readingAverage=0.1..active=true;
            ontologicalGauge..readingAverage = 0.1..active = true;
        }
        return;
    }
    //in git there is a playlist here i can use to understand
    if (playing) {
        await Audio.SYSTEM.load(file);
        if (!playing) {
            return;
        }
        nodes.add(new StoppedFlagNodeWrapper(await Audio.play(file, "Voice")));
        narrativeGauge..readingAverage=0.7..active=true;
        ontologicalGauge..readingAverage = 0.9..active = true;
        systemPrint("Passphrase Accepted!");
    }
}

Future<void> pressStop([Event e]) async {
    if (mode != PlayerMode.playing || !playing) {
        return;
    }

    cassette.element.classes.remove("cassettePlaying");

    stopButton.press();
    playButton.release(true);
    ejectButton.release(true);

    stop();
}

Future<void> pressEject([Event e]) async {
    if (mode != PlayerMode.playing) {
        return;
    }

    pressStop();
    stopButton.release(true);
    ejectButton.press();

    switchToTyping();
}

Future<void> main() async {
    new Audio();
    Audio.SYSTEM.rand = globalRand;

    globalRand.nextInt();

    Audio.createChannel("Voice", 0.5);
    Audio.createChannel("BG", 0.4);

    await setupUi();
    Keyboard.keyCallback = writeLetter;
    Keyboard.backspaceCallback = backspace;

    final Element output = querySelector("#output");

    system = new DivElement();
    output.append(system);

    String initPW = "";
    if(Uri.base.queryParameters['passPhrase'] != null) {
        initPW = Uri.base.queryParameters['passPhrase'];
    }

    caption = initPW;

    updateCaption();
    //output.append(Audio.slider(Audio.SYSTEM.volumeParam));

    playButton.element.onClick.listen(pressPlay);
    stopButton.element.onClick.listen(pressStop);
    ejectButton.element.onClick.listen(pressEject);

    ejectButton.press(true);
}

void systemPrint(String text, [int size = 18]) {
    SystemPrint.print(text, size);
}

Future<void> bullshitCorruption(String value) async {
    //AudioBufferSourceNode node = await Audio.play(
    //    tapeIn, "Voice");
    print("before bullshit, Random is ${globalRand.spawn().nextInt()}");
    final List<AudioBufferSourceNode> snorts = await gigglesnort(value);
    if (snorts == null) { return; }
    print("after gigglesnort, Random is ${globalRand.spawn().nextInt()}");

    final String music = "$podUrl${globalRand.pickFrom(soothingMusic)}";
    print("music chosen is $music");
    if(!playing) { return; }
    await Audio.SYSTEM.load(music);
    if(!playing) { return; }
    final AudioBufferSourceNode nodeBG = await Audio.play(music, "BG")..playbackRate.value = 0.9;
    nodes.add(new StoppedFlagNodeWrapper(nodeBG));
    systemPrint("legibilitiy level is $legibilityLevelInMS ;)");
    //don't fuck around till we know for certain what all we have.
    //await fuckAroundMusic(new StoppedFlagNodeWrapper(nodeBG), 0.2, 1);
    for(final AudioBufferSourceNode node in snorts) {
        await fuckAround(new StoppedFlagNodeWrapper(node), legibilityLevelInMS/1000, 1);
    }
    print("after music, Random is ${globalRand.spawn().nextInt()}");


}

//Warning, because "play" can take different subtle amounts of seconds this won't be 100% accurate.
Future<List<AudioBufferSourceNode>> gigglesnort(String value) async {
    final List<AudioBufferSourceNode> mynodes = <AudioBufferSourceNode>[];
    final List<String> corruptChannels = selectCorruptChannels(value);
    systemPrint("legibilitiy rank is ${corruptChannels.length} ;)");

    //print("REMOVE THIS JR, but choose $corruptChannels");
    //each channel individually fucks up
    //physically impossible to both layer noises AND have a tape in/tape out sound
    if(!playing) { return null; }
    for(final String channel in corruptChannels) {
        final String file = "$podUrl$channel";
        await Audio.SYSTEM.load(file);
        if(!playing) { return null; }
        final AudioBufferSourceNode node = await Audio.play(
            file, "Voice")
            ..playbackRate.value = 0.9;
        nodes.add(new StoppedFlagNodeWrapper(node));
        mynodes.add(node);
    }
    return mynodes;
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
    ret.add(globalRand.pickFrom(absoluteBullshit));
    ret.add(globalRand.pickFrom(absoluteBullshit));
    ret.add(globalRand.pickFrom(absoluteBullshit));
    final int num = globalRand.nextIntRange(1,5);
    for(int i =0; i<num; i++) {
        ret.add(globalRand.pickFrom(absoluteBullshit));
    }
    legibilityLevelInMS = 20;

    return ret;
}

void changePassPhrase(String value) {
    setPassPhraseLink(value);
    globalRand.setSeed(convertSentenceToNumber(value));
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

Future<void> fuckAround(StoppedFlagNodeWrapper wrapper, double rate, int direction) async {
    wrapper.node.playbackRate.value = rate;
    if(rate >1000/legibilityLevelInMS || rate > 1.3) {
        rate = 0.1;
        direction = 1;
    }else if(rate < 0.1) {
        direction = -1;
        rate = 0.9;
    }

    rate += 0.05 * direction;

    if(globalRand.nextDouble() >0.9) {
        rate = globalRand.nextDoubleRange(0.1,10.0);
        if(globalRand.nextBool()) {
            direction = -1;
        }else {
            direction = 1;
        }

    }

    if(globalRand.nextDouble() >0.9) {
        direction = direction * -1;
    }
    int next = legibilityLevelInMS;
    if(legibilityLevelInMS < 200) {
        next = globalRand.nextIntRange(200, 1000);
    }
    if(!wrapper.isStopped) {
        new Timer(Duration(milliseconds: next), () =>
            fuckAround(wrapper, rate, direction));
    }

}

Future<void> fuckAroundMusic(StoppedFlagNodeWrapper wrapper, double rate, int direction) async {
    wrapper.node.playbackRate.value = rate;
    if(rate >0.7) {
        direction = -1;
    }else if(rate < 0.1) {
        direction = 1;
    }
    rate += 0.001 * direction;


    if(globalRand.nextDouble() >0.7) {
        direction = direction * -1;
    }

    if(!wrapper.isStopped) {
        new Timer(Duration(milliseconds: 20), () =>
            fuckAroundMusic(wrapper, rate, direction));
    }

}

void stop() {
    if (!playing) { return; }
    playing = false;
    for(final StoppedFlagNodeWrapper wrapper in nodes) {
        wrapper.node.stop();
    }
    nodes.clear();
    narrativeGauge.active=false;
    ontologicalGauge.active = false;
}

//because for some damn reason i can't detect if shit is done
class StoppedFlagNodeWrapper {
    bool isStopped = false;
    AudioBufferSourceNode node;
    StoppedFlagNodeWrapper(AudioBufferSourceNode this.node) {
        node.onEnded.listen((Event e) {
            isStopped = true;
        });
    }
}