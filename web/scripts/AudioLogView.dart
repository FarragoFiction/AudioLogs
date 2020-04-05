import 'dart:html';

import 'dart:svg' as SVG;
import 'package:CommonLib/Random.dart';
import 'package:CommonLib/Colours.dart';
import 'package:CommonLib/Utility.dart';
import 'package:LoaderLib/Loader.dart';

import 'MetaDataSlurper.dart';

//show every pass phrase you have, if there is an image, and any gigglesnort associated with it.
class AudioLogView {
    DivElement container;
    String phrase;
    AudioLogView(this.phrase);
    bool displayPaldemicLogo = false;
    ImageElement paldemicLogo = new ImageElement(src: "images/paldemic.png");
    ImageElement associatedImage;
    AnchorElement paldemic;
    String gigglesnort = "???";
    String speaker = "???";
    String transcript = "???";
    Map<String, Element> jsonElements = <String, Element>{};

    void display(Element parent) {
        container = new DivElement()..classes.add("audioLogView");
        parent.append(container);
        final Random rand = new Random(phrase.hashCode);
        container.append(imagePreviewElement());
        container.append(newFrameElement(rand));
        container.append(newphraseElement(rand));
        container.onClick.listen((Event e) => handleDetailsView());
    }

    Future<void> handleDetailsView() async {
        window.scrollTo(0,0);
        final Element parent = querySelector("#focusEgg");
        parent.text = "";
        if(associatedImage != null) parent.append(associatedImage);
        parent.append(newphraseDetailElement());
        parent.append(newspeakerElement());
        parent.append(newsnortElement());
        parent.append(newPaldemicElement());
        parent.append(newtranscriptElement());
        await populateJson();
    }

    Element newFrameElement(Random rand) {
        //final SVG.SvgElement egg = new SVG.SvgElement.svg("""<svg class='svg_egg'  version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 132.2 189" style="enable-background:new 0 0 132.2 189;" xml:space="preserve"><path class='eggcolor' d="M131.2,101.7c4.1,56.2-28.6,86.3-64.6,86.3S-3.7,157.2,1,101.7C6,43,45,1,66.1,1C86,1,127,44,131.2,101.7z"/></svg>""");

        const double height = 189;
        const double width = 132.2;
        const double thickness = 20;
        const double spacing = 10;

        final SVG.SvgSvgElement svg = new SVG.SvgSvgElement()
            ..viewBox.baseVal.width = width
            ..viewBox.baseVal.height = height;
        final SVG.GElement group = new SVG.GElement()
            ..setAttribute("clip-path", "url(#egg)");
        final SVG.RectElement background = new SVG.RectElement()
            ..width.baseVal.value = width
            ..height.baseVal.value = height
            ..style.setProperty('fill', new Colour.hsv(rand.nextDouble(360), rand.nextDouble(0.1), 1.0).toStyleString());

        final SVG.PathElement path = new SVG.PathElement()
            ..setAttribute("d", "M131.2,101.7c4.1,56.2-28.6,86.3-64.6,86.3S-3.7,157.2,1,101.7C6,43,45,1,66.1,1C86,1,127,44,131.2,101.7z");

        final SVG.ClipPathElement clip = new SVG.ClipPathElement()
            ..append(path)
            ..id = "egg";
        final SVG.DefsElement defs = new SVG.DefsElement()
            ..append(clip);
        svg.append(defs);
        group.append(background);
        svg.append(group);

        const double spotThickness = thickness;
        final int spotCount = (width / spotThickness).ceil();
        final double spotXOffset = ((spotThickness * spotCount) - width)/2;
        const double spotYOffset = (thickness - spotThickness) * 0.5;

        const double zigzagThickness = thickness * 0.6;
        final int zigzagCount = (width / zigzagThickness).ceil();
        final double zigzagXOffset = ((zigzagThickness * zigzagCount) - width)/2;
        const double zigzagYOffset = (thickness - zigzagThickness) * 0.5;

        for (double y = 0; y < height; y += spacing+thickness) {
            if (rand.nextBool()) {
                final String stripColour = new Colour.hsv(rand.nextDouble(360), rand.nextDouble(0.5) + 0.2, 1.0).toStyleString();
                final String spotColour = new Colour.hsv(rand.nextDouble(360), rand.nextDouble(0.7) + 0.3, 1.0).toStyleString();
                final SVG.RectElement strip = new SVG.RectElement()
                    ..width.baseVal.value = width
                    ..height.baseVal.value = thickness
                    ..style.setProperty("fill", stripColour)
                    ..y.baseVal.value = y;

                group.append(strip);

                for (int i=0; i<spotCount; i++) {
                    final SVG.CircleElement dot = new SVG.CircleElement()
                        ..r.baseVal.value = thickness * 0.7 *0.5
                        ..cx.baseVal.value = thickness * (i+0.5) - spotXOffset
                        ..cy.baseVal.value = thickness * 0.5 + y + spotYOffset
                        ..style.setProperty("fill", spotColour);
                    group.append(dot);
                }
            } else {
                final String colour = new Colour.hsv(rand.nextDouble(360), rand.nextDouble(0.7) + 0.3, 1.0).toStyleString();
                final SVG.PathElement zigzag = new SVG.PathElement()
                    ..style.setProperty("fill", "none")
                    ..style.setProperty("stroke", colour)
                    ..style.setProperty("stroke-width", (rand.nextDouble(3)+3.5).toString());

                final StringBuffer pathString = new StringBuffer("M");
                for (int i=0; i<zigzagCount+2; i++) {
                    pathString
                        ..write(" ")
                        ..write(zigzagThickness * (i-0.5) - zigzagXOffset)
                        ..write(",")
                        ..write(y + (i % 2 == 0 ? 0 : zigzagThickness) + zigzagYOffset);
                }
                zigzag.setAttribute("d", pathString.toString());
                group.append(zigzag);
            }
        }

        svg.classes.add("visible-egg");
        svg.id="${phrase}_egg";
        return svg;

    }

    Element newphraseElement(Random rand) {
        final DivElement ret = new DivElement()..classes.add("phrase");
        //final Random rand = new Random(phrase.codeUnitAt(phrase.length-1));
        final int number = rand.nextIntRange(-20,20);
        final int width = rand.nextIntRange(75,150);
        final int leftPos = rand.nextIntRange(45,75);
        final int topPos = rand.nextIntRange(-10,0);
        ret.style..transform = "translate(-50%,-50%) rotate(${number}deg)"
            ..width ="${width}px"
            ..marginLeft="$leftPos%"
            ..marginTop="${topPos}px";
        ret.append(paldemicPreviewElement());
        final SpanElement textDiv = new SpanElement()..text = this.phrase;
        ret.append(textDiv);


        return ret;
    }

    Element newphraseDetailElement() {
        final DivElement ret = new DivElement()..text = this.phrase..classes.add("detailPhrase");
        return ret;
    }

    Element newtranscriptElement() {
        final DivElement ret = new DivElement()..text = "Transcript: ???"..classes.add("transcript")..classes.add("detailsSection");
        jsonElements["transcript"] = ret;
        return ret;
    }

    Element newspeakerElement() {
        final DivElement ret = new DivElement()..text = "Speakers: ???"..classes.add("whoIsSpeaking")..classes.add("detailsSection");
        jsonElements["speaker"] = ret;
        return ret;
    }

    Element newsnortElement() {
        final DivElement ret = new DivElement()..text = "Gigglesnort: ???"..classes.add("snort")..classes.add("detailsSection");
        jsonElements["snort"] = ret;
        return ret;
    }

    Element newPaldemicElement() {
        final DivElement ret = new DivElement()..setInnerHtml( "<b>Paldemic Chat</b>: N/A")..classes.add("paldemic")..classes.add("detailsSection");
        populatePaldemicLink(ret);
        return ret;
    }

    Element imagePreviewElement() {
        final ImageElement image = new ImageElement();
        populateImage(image);
        return image;
    }

    Element paldemicPreviewElement() {
        final ImageElement image = new ImageElement();
        populatePaldemicPreview(image);
        return image;
    }

    Future<void> populatePaldemicPreview(ImageElement image) async {
        await populatePaldemicLink(null);
        if(displayPaldemicLogo) {
            image.src = paldemicLogo.src;
            image.classes.add("paldemicLogo");
        }
    }

    Future<void> populatePaldemicLink(Element parent) async {
        if(paldemic != null && parent != null) {
            parent.setInnerHtml("<b>Paldemic Chat</b>: ");
            parent.append(paldemic);
        }
        try {
            await Loader.getResource(
                "${MetaDataSlurper.podUrl}$phrase.paldemic", format: Formats.text);
            paldemic = new AnchorElement()..href='http://www.farragofiction.com/PaldemicSim/login.html?passPhrase=$phrase'..text = "Click Here";
            paldemic.target = "_blank";
            displayPaldemicLogo = true;
            if(parent != null) {
                parent.setInnerHtml("<b>Paldemic Chat</b>: ");
                parent.append(paldemic);
            }
        }on LoaderException {
            //yeah most of them are like this
        }
    }

    Future<void> populateImage(ImageElement image) async{
        try {
            associatedImage = await Loader.getResource(
                "${MetaDataSlurper.podUrl}$phrase.png");
            image.src = associatedImage.src;
            associatedImage.classes.add("detailImage");
            image.classes.add("eggThumbnail");

        }on LoaderException {
            //no worries.
        }
    }

    void syncElementsToJson() {
        if(jsonElements.containsKey("transcript")) jsonElements["transcript"].setInnerHtml("<b>Transcript</b>: $transcript");
        if(jsonElements.containsKey("snort")) jsonElements["snort"].setInnerHtml("<b>Gigglesnort</b>: $gigglesnort");
        if(jsonElements.containsKey("speaker")) jsonElements["speaker"].setInnerHtml("<b>Speaker</b>: $speaker");

    }

    Future<void> populateJson()async {
        try {
            final Map<String,dynamic> jsonRet = await Loader.getResource(
                "http://farragnarok.com/PodCasts/$phrase.json");
            final JsonHandler json = new JsonHandler(jsonRet);
            speaker = json.getValue("speaker");
            if(json.data.containsKey("transcript")) {
                transcript = json.getValue("transcript");
            }

            if(jsonRet.containsKey("gigglesnort")) {
                gigglesnort = json.getValue("gigglesnort");
            }else {
                gigglesnort = null;
            }
            syncElementsToJson();

        } on LoaderException {
            //whoops
        }
    }
}