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
        container.append(imagePreviewElement);
        container.append(newFrameElement);
        container.append(newphraseElement);
        container.onClick.listen((Event e) => handleDetailsView());
    }

    Future<void> handleDetailsView() async {
        window.scrollTo(0,0);
        final Element parent = querySelector("#focusEgg");
        parent.text = "";
        if(associatedImage != null) parent.append(associatedImage);
        parent.append(newphraseDetailElement);
        parent.append(newspeakerElement);
        parent.append(newsnortElement);
        parent.append(newPaldemicElement);
        parent.append(newtranscriptElement);
        await populateJson();
    }

    Element get newFrameElement {
        final SVG.SvgElement egg = new SVG.SvgElement.svg("""<svg class='svg_egg'  version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 132.2 189" style="enable-background:new 0 0 132.2 189;" xml:space="preserve"><path class='eggcolor' class="st0" d="M131.2,101.7c4.1,56.2-28.6,86.3-64.6,86.3S-3.7,157.2,1,101.7C6,43,45,1,66.1,1C86,1,127,44,131.2,101.7z"/></svg>""");
        final Random rand = new Random(phrase.codeUnitAt(0));
        final Colour randomColor = new Colour(rand.nextInt(255),rand.nextInt(255),rand.nextInt(255));
        final Colour finalColor = new Colour.hsv(randomColor.hue, rand.nextDouble(.5),1.0);
        egg.classes.add("visible-egg");
        egg.style.setProperty('fill', finalColor.toStyleString());
        egg.id="${phrase}_egg";
        return egg;

    }

    Element get newphraseElement {
        final DivElement ret = new DivElement()..classes.add("phrase");
        final Random rand = new Random(phrase.codeUnitAt(phrase.length-1));
        final int number = rand.nextIntRange(-20,20);
        final int width = rand.nextIntRange(75,150);
        final int leftPos = rand.nextIntRange(45,75);
        final int topPos = rand.nextIntRange(-10,0);
        ret.style..transform = "translate(-50%,-50%) rotate(${number}deg)"
            ..width ="${width}px"
            ..marginLeft="$leftPos%"
            ..marginTop="${topPos}px";
        ret.append(paldemicPreviewElement);
        final SpanElement textDiv = new SpanElement()..text = this.phrase;
        ret.append(textDiv);


        return ret;
    }

    Element get newphraseDetailElement {
        final DivElement ret = new DivElement()..text = this.phrase..classes.add("detailPhrase");
        return ret;
    }

    Element get newtranscriptElement {
        final DivElement ret = new DivElement()..text = "Transcript: ???"..classes.add("transcript")..classes.add("detailsSection");
        jsonElements["transcript"] = ret;
        return ret;
    }

    Element get newspeakerElement {
        final DivElement ret = new DivElement()..text = "Speakers: ???"..classes.add("whoIsSpeaking")..classes.add("detailsSection");
        jsonElements["speaker"] = ret;
        return ret;
    }

    Element get newsnortElement {
        final DivElement ret = new DivElement()..text = "Gigglesnort: ???"..classes.add("snort")..classes.add("detailsSection");
        jsonElements["snort"] = ret;
        return ret;
    }

    Element get newPaldemicElement {
        final DivElement ret = new DivElement()..setInnerHtml( "<b>Paldemic Chat</b>: N/A")..classes.add("paldemic")..classes.add("detailsSection");
        populatePaldemicLink(ret);
        return ret;
    }

    Element get imagePreviewElement {
        final ImageElement image = new ImageElement();
        populateImage(image);
        return image;
    }

    Element get paldemicPreviewElement {
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
            final dynamic jsonRet = await Loader.getResource(
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