import "dart:html";

abstract class Keyboard {
    static final List<List<Key>> _keyData = <List<Key>>[
        <Key>[Key("1","!"), Key("2","@"), Key("3","#"), Key("4","\$"), Key("5","%"), Key("6","^"), Key("7","&"), Key("8","*"), Key("9","("), Key("0",")"), Key("Backspace","","←")],
        <Key>[Key("q","Q","Q"), Key("w","W","W"), Key("e","E","E"), Key("r","R","R"), Key("t","T","T"), Key("y","Y","Y"), Key("u","U","U"), Key("i","I","I"), Key("o","O","O"), Key("p","P","P")],
        <Key>[Key("a","A","A"), Key("s","S","S"), Key("d","D","D"), Key("f","F","F"), Key("g","G","G"), Key("h","H","H"), Key("j","J","J"), Key("k","K","K"), Key("l","L","L"), Key("'","\""), Key("Enter","","█")],
        <Key>[Key("z","Z","Z"), Key("x","X","X"), Key("c","C","C"), Key("v","V","V"), Key("b","B","B"), Key("n","N","N"), Key("m","M","M"), Key(","), Key(".")],
        <Key>[SpaceKey(" ")]
    ];

    static final Map<String, Key> keys = <String, Key>{};

    static void init() {
        // ignore: unnecessary_statements
        _keyData; // this is actually essential, since it forces the lazy init on _keyData to happen, which populates keys
        print(keys);

        window.onKeyDown.listen(onKeyDown);
        window.onKeyUp.listen(onKeyUp);
    }

    static void onKeyDown(KeyboardEvent event) {
        String k = event.key;
        if (keys.containsKey(k)) {
            print("${keys[k]} pressed");
        }
    }

    static void onKeyUp(KeyboardEvent event) {
        String k = event.key;
        if (keys.containsKey(k)) {
            print("${keys[k]} released");
        }
    }
}

class Key {
    final String glyph;
    final String upperGlyph;
    final String displayOverride;

    bool toggleOnClick = false;

    Key(String this.glyph, [String this.upperGlyph, String this.displayOverride]) {
        Keyboard.keys[glyph] = this;
        if (this.upperGlyph != null) {
            Keyboard.keys[upperGlyph] = this;
        }
    }

    String get lower => displayOverride != null ? displayOverride : glyph;
    String get upper => displayOverride != null ? null : upperGlyph;

    @override
    String toString() => "[ $lower ]";
}

class SpaceKey extends Key {
    SpaceKey(String glyph) : super(glyph);
}

