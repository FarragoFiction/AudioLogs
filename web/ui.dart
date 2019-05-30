import "dart:html";

import "package:AudioLib/AudioLib.dart";
import "package:CommonLib/Logging.dart";

import "main.dart";

abstract class Keyboard {
    static final Logger logger = new Logger("Keyboard", true);
    static final List<List<Key>> _keyData = <List<Key>>[
        <Key>[Key("1","!"), Key("2","@"), Key("3","#"), Key("4","\$"), Key("5","%"), Key("6","^"), Key("7","&"), Key("8","*"), Key("9","("), Key("0",")"), Key("Backspace","","←")],
        <Key>[Key("q","Q","Q"), Key("w","W","W"), Key("e","E","E"), Key("r","R","R"), Key("t","T","T"), Key("y","Y","Y"), Key("u","U","U"), Key("i","I","I"), Key("o","O","O"), Key("p","P","P")],
        <Key>[Key("a","A","A"), Key("s","S","S"), Key("d","D","D"), Key("f","F","F"), Key("g","G","G"), Key("h","H","H"), Key("j","J","J"), Key("k","K","K"), Key("l","L","L"), Key("'","\"")],
        <Key>[Key("Shift","","▲")..toggleOnClick=true,Key("z","Z","Z"), Key("x","X","X"), Key("c","C","C"), Key("v","V","V"), Key("b","B","B"), Key("n","N","N"), Key("m","M","M"), Key(","), Key(".")],
        <Key>[SpaceKey(" ")]
    ];
    static const int keySounds = 7;

    static final Map<String, Key> keys = <String, Key>{};
    static Element element;

    static Key shift = keys["Shift"];
    static Key backspace = keys["Backspace"];

    static Future<void> init() async {
        await Future.wait(new List<int>.generate(keySounds, (int i) => i).map((int i) => Audio.SYSTEM.load("${audioUrl}keydown$i")));
        await Future.wait(new List<int>.generate(keySounds, (int i) => i).map((int i) => Audio.SYSTEM.load("${audioUrl}keyup$i")));

        // ignore: unnecessary_statements
        _keyData; // this is actually essential, since it forces the lazy init on _keyData to happen, which populates keys
        logger.debug(keys);

        window.onKeyDown.listen(onKeyDown);
        window.onKeyUp.listen(onKeyUp);
        window.onFocus.listen(refocus);
        window.onBlur.listen(refocus);
        window.onMouseUp.listen(onMouseUp);

        Audio.createChannel("keyboard", 0.6);

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
            logger.debug("Backspace!");
        } else {
            logger.debug("Typed $glyph");
        }
    }

    static void onKeyDown(KeyboardEvent event) {
        if (keys.containsKey(event.key)) {
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
        if (pressed) { return; }
        pressed = true;
        if (click) {
            wasClicked = true;
        }
        Keyboard.logger.debug("$this pressed");
        this.element.classes.add("pressed");

        Audio.play("${audioUrl}keydown${rand.nextInt(Keyboard.keySounds)}", "keyboard");

        Keyboard.pressKey(this);
    }

    void release([bool refocus = false]) {
        if (!pressed) { return; }
        if (refocus && toggleOnClick && wasClicked) { return; }
        pressed = false;
        wasClicked = false;
        Keyboard.logger.debug("$this released");
        this.element.classes.remove("pressed");

        Audio.play("${audioUrl}keyup${rand.nextInt(Keyboard.keySounds)}", "keyboard");
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
