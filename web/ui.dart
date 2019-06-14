import "dart:async";
import "dart:html";
import "dart:math" as Math;
import "dart:web_audio";

import "package:AudioLib/AudioLib.dart";
import "package:CommonLib/Logging.dart";
import "package:CommonLib/Random.dart";
import "package:CommonLib/Utility.dart";

import "main.dart";

abstract class Keyboard {
    static final  logger = new Logger("Keyboard", true);
    static final List<List<Key>> _keyData = <List<Key>>[
        <Key>[Key("1","!"), Key("2","@"), Key("3","#"), Key("4","\$"), Key("5","%"), Key("6","^"), Key("7","&"), Key("8","*"), Key("9","("), Key("0",")"), Key("Backspace","","←")],
        <Key>[Key("q","Q","Q"), Key("w","W","W"), Key("e","E","E"), Key("r","R","R"), Key("t","T","T"), Key("y","Y","Y"), Key("u","U","U"), Key("i","I","I"), Key("o","O","O"), Key("p","P","P")],
        <Key>[Key("a","A","A"), Key("s","S","S"), Key("d","D","D"), Key("f","F","F"), Key("g","G","G"), Key("h","H","H"), Key("j","J","J"), Key("k","K","K"), Key("l","L","L"), Key("'","\"")],
        <Key>[Key("Shift","","▲")..toggleOnClick=true,Key("z","Z","Z"), Key("x","X","X"), Key("c","C","C"), Key("v","V","V"), Key("b","B","B"), Key("n","N","N"), Key("m","M","M"), Key("."), Key("?")],
        <Key>[SpaceKey(" ")]
    ];
    static const int keySounds = 7;

    static final Map<String, Key> keys = <String, Key>{};
    static Element element;

    static Key shift = keys["Shift"];
    static Key backspace = keys["Backspace"];

    static bool enabled = true;

    static Lambda<String> keyCallback;
    static Action backspaceCallback;

    static Random rand = new Random();

    static Future<void> init() async {
        final List<Future<AudioBuffer>> toLoad = <Future<AudioBuffer>>[];
        toLoad.addAll(new List<int>.generate(keySounds, (int i) => i).map((int i) => Audio.SYSTEM.load("${audioUrl}keydown$i")));
        toLoad.addAll(new List<int>.generate(keySounds, (int i) => i).map((int i) => Audio.SYSTEM.load("${audioUrl}keyup$i")));
        await Future.wait(toLoad);

        // ignore: unnecessary_statements
        _keyData; // this is actually essential, since it forces the lazy init on _keyData to happen, which populates keys
        //logger.debug(keys);

        window.onKeyDown.listen(onKeyDown);
        window.onKeyUp.listen(onKeyUp);
        window.onFocus.listen(refocus);
        window.onBlur.listen(refocus);
        window.onMouseUp.listen(onMouseUp);

        element = makeElement();
    }

    static void pressKey(Key key) {
        if (key == shift) { return; }

        String glyph;
        if (shift.pressed && key.upperGlyph != null) {
            glyph = key.upperGlyph;
        } else {
            glyph = key.glyph;
        }

        if (key == backspace) {
            //logger.debug("Backspace!");
            if (backspaceCallback != null) {
                backspaceCallback();
            }
        } else {
            //logger.debug("Typed $glyph");
            if (keyCallback != null) {
                keyCallback(glyph);
            }
        }
    }

    static void onKeyDown(KeyboardEvent event) {
        final bool valid = keys.containsKey(event.key);
        if (valid && !event.ctrlKey && !event.altKey) {
            event.preventDefault();
        }
        if (valid) {
            keys[event.key].press();
        }
    }

    static void onKeyUp(KeyboardEvent event) {
        if (keys.containsKey(event.key)) {
            keys[event.key].release();
        }
    }

    static void onMouseUp(MouseEvent event) {
        for (final Key key in keys.values) {
            key.onMouseUp(event);
        }
    }

    static void refocus(Event event) {
        for (final Key key in keys.values) {
            key.release(true);
        }
    }

    static Element makeElement() {
        final Element board = new DivElement()..className="keyboard";
        for ( int i=0; i<_keyData.length; i++ ) {
            final List<Key> datarow = _keyData[i];
            final Element row = new DivElement()..className="keyrow";

            for (final Key key in datarow) {
                key.rowNumber = i;
                key.makeElement();
                row.append(key.element);
            }

            board.append(row);
        }
        return board;
    }

    static void disable() {
        enabled = false;
        for (final Key key in keys.values) {
            key.release();
        }
    }

    static void enable() {
        enabled = true;
    }
}

class Key {
    final String glyph;
    final String upperGlyph;
    final String displayOverride;

    bool pressed = false;
    bool wasClicked = false;
    bool toggleOnClick = false;

    Element element;

    int rowNumber;

    Key(String this.glyph, [String this.upperGlyph, String this.displayOverride]) {
        Keyboard.keys[glyph] = this;
        if (this.upperGlyph != null) {
            Keyboard.keys[upperGlyph] = this;
        }
    }

    void press([bool click = false]) {
        if (!Keyboard.enabled) { return; }
        if (pressed) { return; }
        pressed = true;
        if (click) {
            wasClicked = true;
        }
        //Keyboard.logger.debug("$this pressed");
        this.element.classes.add("pressed");

        Audio.play("${audioUrl}keydown${Keyboard.rand.nextInt(Keyboard.keySounds)}", "ui");

        Keyboard.pressKey(this);
    }

    void release([bool refocus = false]) {
        if (!pressed) { return; }
        if (refocus && toggleOnClick && wasClicked) { return; }
        pressed = false;
        wasClicked = false;
        //Keyboard.logger.debug("$this released");
        this.element.classes.remove("pressed");

        Audio.play("${audioUrl}keyup${Keyboard.rand.nextInt(Keyboard.keySounds)}", "ui");
    }

    void makeElement() {
        final Element key = new DivElement()..className="key row$rowNumber";

        final Element head = new DivElement()..className="head";

        key..append(new DivElement()..className="base"..onMouseDown.listen((Event e) {e.stopImmediatePropagation();} ))
            ..append(new DivElement()..className="stem"..onMouseDown.listen((Event e) {e.stopImmediatePropagation();} ))
            ..append(head);

        if (this.lower != null) {
            if (this.upper != null) {
                head.append(new DivElement()..className="lower"..text=lower);
                head.append(new DivElement()..className="upper"..text=upper);
            } else {
                head.append(new DivElement()..className="middle"..text=lower);
            }
        }

        this.element = key;

        this.element.onMouseDown.listen(onMouseDown);
    }

    void onMouseDown(MouseEvent event) {
        if (event.button == 0) {
            if (!toggleOnClick) {
                press(true);
            } else {
                if (pressed) {
                    release();
                } else {
                    press(true);
                }
            }
        }
    }

    void onMouseUp(MouseEvent event) {
        if (event.button == 0) {
            if (!toggleOnClick) {
                release();
            }
        }
    }

    String get lower => displayOverride != null ? displayOverride : glyph;
    String get upper => displayOverride != null ? null : upperGlyph;

    @override
    String toString() => "[ $lower ]";
}

class SpaceKey extends Key {
    SpaceKey(String glyph) : super(glyph);

    @override
    void makeElement() {
        super.makeElement();
        this.element.classes.add("spacebar");
    }
}

class Speaker {
    Element container;
    Element inner;

    Speaker(Element this.container, String className) {
        this.inner = new DivElement()..className = "$className speakerInner";
        container.append(inner);
        container.append(new DivElement()..className="$className speakerOuter");
    }
}

class Cassette {
    Element element;
    Element leftSpool;
    Element rightSpool;
    Element label;

    Cassette() {
        this.element = new DivElement()..className="cassette";

        leftSpool = makeSpool()..classes.add("left");
        rightSpool = makeSpool()..classes.add("right");
        label = new DivElement()..className="label";

        element
            ..append(leftSpool)
            ..append(rightSpool)
            ..append(new DivElement()..className="overlay")
            ..append(label);
    }

    static Element makeSpool() {
        return new DivElement()
            ..className="spool"
            ..append(new DivElement()..style.transform = "translate(-50%,-50%)")
            ..append(new DivElement()..style.transform = "translate(-50%,-50%) rotate(60deg)")
            ..append(new DivElement()..style.transform = "translate(-50%,-50%) rotate(-60deg)")
        ;
    }

    void cycleElement() {
        if (this.element.parent == null) { return; }
        final Element e = this.element.parent;
        this.element.remove();
        e.append(this.element);
    }
}

class UiButton {
    Element element;
    String pressedClass;

    bool pressed = false;

    UiButton(String className, String this.pressedClass) {
        element = new DivElement()..className = className;
    }

    void press([bool silent = false]) {
        if (pressed) { return; }

        this.pressed = true;
        this.element.classes.add(pressedClass);

        if (!silent) {
            Audio.play("${audioUrl}button", "ui", pitchVar: 0.2);
        }
    }

    void release([bool silent = false]) {
        if (!pressed) { return; }

        this.pressed = false;
        this.element.classes.remove(pressedClass);

        if (!silent) {
            Audio.play("${audioUrl}button", "ui", pitchVar: 0.2);
        }
    }
}

class VolumeKnob {
    int size;
    AudioEffect linkedParam;

    Element element;
    Element knob;

    bool dragging = false;

    static const double deadZone = 35;
    static const int majorDivisions = 10;
    static const int minorDivisions = 5;

    static const int steps = majorDivisions * minorDivisions;
    final double step = (360 - deadZone*2) / steps;
    
    double get value => linkedParam.value;
    set value(double v) {
        linkedParam.value = v;
        this.updateElement();
    }

    static const double _rad2Deg = 360 / (Math.pi * 2);

    VolumeKnob(dynamic audioParamORAudioEffect, int this.size, String title) {
        linkedParam = Audio.validateParamInput(audioParamORAudioEffect);

        element = new DivElement()..className="volumeKnobContainer";

        for (int i=0; i <= steps; i++) {
            final bool isMajor = i % minorDivisions == 0;

            final double angle = i * step - 180 + deadZone;

            final Element mark = new DivElement()..className="knobDivision${isMajor ? "Major" : "Minor"}";
            mark.style.transform = "rotate(${angle.toStringAsFixed(2)}deg)";

            if (isMajor) {
                final Element markLabel = new DivElement()..className="knobLabel"..text = ((i/steps)*10).round().toString();
                //markLabel.style.transform = "rotate(${(-angle).toStringAsFixed(2)}deg) translate(-50%,-50%)";
                mark.append(markLabel);
            }

            element.append(mark);
        }

        element.append(new DivElement()..className="knobTitle"..text=title);

        knob = new DivElement()..className="volumeKnob";
        element.append(knob);

        const double scrollIncrement = 0.02;

        knob.onMouseWheel.listen((WheelEvent event) {
            event.preventDefault();
            final double adjusted = (this.value + scrollIncrement * event.deltaY.sign * -1).clamp(0, 1.0);
            this.value = roundToStep(adjusted);
        });

        knob.onMouseDown.listen(_mouseDown);
        window.onMouseUp.listen(_mouseUp);
        window.onMouseMove.listen(_mouseMove);

        updateElement();
    }

    void _mouseDown(MouseEvent e) {
        this.dragging = true;
    }

    void _mouseUp(MouseEvent e) {
        _mouseMove(e);
        this.dragging = false;
    }

    void _mouseMove(MouseEvent e) {
        if (this.dragging) {
            final int kSize = knob.offsetWidth~/2;
            final Point<num> relativePos = e.page - (knob.documentOffset + new Point<num>(kSize,kSize));

            this.value = valueFromOffset(relativePos).clamp(0, 1);
        }
    }

    double roundToStep(double input) {
        return (input * steps).round() / steps;
    }
    
    void updateElement() {
        final String angle = angleStyle(angleFromValue(this.value));
        knob.style.transform = angle;
    }

    double angleFromOffset(Point<num> offset) {
        return (-Math.atan2(offset.x, offset.y) * _rad2Deg) % 360;
    }

    double angleFromValue(double value) {
        return deadZone + value * (360 - (deadZone * 2));
    }

    double valueFromAngle(double angle) {
        return (angle - deadZone) / (360 - (deadZone * 2));
    }

    double valueFromOffset(Point<num> offset) => valueFromAngle(angleFromOffset(offset));

    static String angleStyle(double angle) {
        return "rotate(${(angle - 180).toStringAsFixed(2)}deg)";
    }
}

class Gauge {

    double _value = 0.0;

    Element element;
    Element dial;
    Element overlay;

    static const double spread = 60;
    final int majorDivisions;
    final int minorDivisions;

    int steps;
    double step;

    final double lowValue;
    final double highValue;

    double readingAverage = 0;
    double readingSpread = 0;

    Timer ticker;
    Random rand = new Random();

    bool active = false;

    double get value => _value;
    set value(double v) {
        _value = v;
        updateElement();
    }

    Gauge(String upperLabel, String middleLabel, [double this.lowValue = 0.0, double this.highValue = 1.0, int this.majorDivisions = 10, int this.minorDivisions = 5]) {
        steps = majorDivisions * minorDivisions;
        step = (spread*2) / steps;

        element = new DivElement()..className="gauge";

        for (int i=0; i <= steps; i++) {
            final bool isMajor = i % minorDivisions == 0;

            final double angle = i * step - spread;

            final Element mark = new DivElement()..className="gaugeDivision${isMajor ? "Major" : "Minor"}";
            mark.style.transform = "rotate(${angle.toStringAsFixed(2)}deg)";

            if (isMajor) {
                final Element markLabel = new DivElement()..className="gaugeDivisionLabel"..text = (lowValue + (i/steps) * (highValue - lowValue)).toString();
                //markLabel.style.transform = "rotate(${(-angle).toStringAsFixed(2)}deg) translate(-50%,-50%)";
                mark.append(markLabel);
            }

            element.append(mark);
        }

        element.append(new DivElement()..className="gaugeLabel"..text = middleLabel);

        dial = new DivElement()..className="gaugeDial";
        element.append(dial);

        overlay = new DivElement()..className="gaugeOverlay";
        overlay.append(new DivElement()..className="gaugeLabel"..text = upperLabel);
        element.append(overlay);

        ticker = new Timer.periodic(Duration(milliseconds: 100), tick);
    }

    void tick([Timer t]) {
        if (active) {
            value = (rand.nextDouble(readingSpread) - readingSpread * 0.5 + readingAverage).clamp(0, 1);
        } else {
            value = 0;
        }
    }

    void updateElement() {
        dial.style.transform = "translateX(-50%) rotate(${angleFromValue(value).toStringAsFixed(2)}deg)";
    }

    double angleFromValue(double value) {
        return spread * 2 * (value - 0.5);
    }
}

Cassette cassette;
UiButton playButton;
UiButton stopButton;
UiButton ejectButton;
UiButton typewriterButton;
Element keyboardLight;
VolumeKnob playbackVolume;
VolumeKnob uiVolume;
Gauge ontologicalGauge; //realness quotient
Gauge narrativeGauge; //relevance quotient

Future<void> setupUi() async {
    final Element container = querySelector("#container");
    final Element topButtons = querySelector("#topbuttons");
    final Element keyboardUpper = querySelector("#keyboardUpper");
    final Element boombox = querySelector("#boombox");

    keyboardLight = querySelector("#keyboardLight");

    Audio.createChannel("ui", 0.6);

    await Keyboard.init();
    querySelector("#keyboard").append(Keyboard.element);

    final ElementList<Element> speakers = querySelectorAll(".speakerContainer");

    for (final Element container in speakers) {
        new Speaker(container, "speaker");
    }

    playButton = new UiButton("topbutton", "topbuttonpressed")..element.title="Play";
    playButton.element.classes..add("glyphicon")..add("glyphicon-play");
    stopButton = new UiButton("topbutton", "topbuttonpressed")..element.title="Stop";
    stopButton.element.classes..add("glyphicon")..add("glyphicon-stop");
    ejectButton = new UiButton("topbutton", "topbuttonpressed")..element.title="Eject";
    ejectButton.element.classes..add("glyphicon")..add("glyphicon-eject");

    typewriterButton = new UiButton("bottombutton", "bottombuttonpressed")..element.title="Transfer";
    typewriterButton.element.append(new DivElement()..classes.add("glyphicon")..classes.add("glyphicon-ok"));

    // top button block

    topButtons.append(new DivElement()..className="topbuttonbroken");//..append(new DivElement()..classes.add("glyphicon")..classes.add("glyphicon-backward")));

    topButtons.append(stopButton.element);
    topButtons.append(playButton.element);


    topButtons.append(new DivElement()..className="topbuttonbroken");//..append(new DivElement()..classes.add("glyphicon")..classes.add("glyphicon-forward")));

    topButtons.append(new DivElement()..className="topbuttonbroken");//..append(new DivElement()..classes.add("glyphicon")..classes.add("glyphicon-pause")));
    topButtons.append(ejectButton.element);

    keyboardUpper.append(typewriterButton.element);

    // knobs

    playbackVolume = new VolumeKnob(Audio.SYSTEM.channels["Voice"].volumeParam, 128, "VOLUME")..element.classes.add("rightKnob");
    boombox.append(playbackVolume.element);
    uiVolume = new VolumeKnob(Audio.SYSTEM.channels["ui"].volumeParam, 128, "TUNING")..element.classes.add("leftKnob");
    boombox.append(uiVolume.element);

    ontologicalGauge = new Gauge("Ontological Stability", "O = kSn", 0,8, 8)..element.classes.add("leftGauge")..readingSpread=0.035;
    boombox.append(ontologicalGauge.element);
    narrativeGauge = new Gauge("Narrative Stability", "N = kSn", 0,4, 4, 10)..element.classes.add("rightGauge")..readingSpread=0.035;
    boombox.append(narrativeGauge.element);

    cassette = new Cassette();

    container.append(cassette.element);

    /*container.append(new ButtonElement()
        ..style.position="absolute"
        ..style.left = "330px"
        ..style.top = "350px"
        ..text = "(TEMP) insert cassette"
        ..onClick.listen((Event e){
            switchToPlaying();
        })
    );*/
    typewriterButton.element.onClick.listen((Event e){
        switchToPlaying();
    });
}