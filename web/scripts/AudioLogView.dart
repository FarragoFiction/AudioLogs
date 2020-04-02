import 'dart:html';

import 'dart:svg' as SVG;
import 'package:CommonLib/Random.dart';
import 'package:CommonLib/Colours.dart';
import 'package:LoaderLib/Loader.dart';

import 'MetaDataSlurper.dart';

//show every pass phrase you have, if there is an image, and any gigglesnort associated with it.
class AudioLogView {
    DivElement container;
    String phrase;
    AudioLogView(this.phrase);

    void display(Element parent) {
        container = new DivElement()..classes.add("audioLogView");
        parent.append(container);
        container.append(imagePreviewElement);
        container.append(newFrameElement);
        container.append(newphraseElement);
        container.onClick.listen((Event e) => handleDetailsView());
    }

    void handleDetailsView() {
        Element parent = querySelector("#focusEgg");
        parent.text = phrase;
    }

    Element get newFrameElement {
        SVG.SvgElement egg = new SVG.SvgElement.svg("<svg class='svg_egg'  version=\"1.1\" id=\"Layer_1\" xmlns=\"http:\/\/www.w3.org\/2000\/svg\" xmlns:xlink=\"http:\/\/www.w3.org\/1999\/xlink\" x=\"0px\" y=\"0px\"\r\n\t viewBox=\"0 0 132.2 189\" style=\"enable-background:new 0 0 132.2 189;\" xml:space=\"preserve\">\r\n<path class='eggcolor' class=\"st0\" d=\"M131.2,101.7c4.1,56.2-28.6,86.3-64.6,86.3S-3.7,157.2,1,101.7C6,43,45,1,66.1,1C86,1,127,44,131.2,101.7z\"\/>\r\n<\/svg>");
        Random rand = new Random(phrase.codeUnitAt(0));
        Colour randomColor = new Colour(rand.nextInt(255),rand.nextInt(255),rand.nextInt(255));
        Colour finalColor = new Colour.hsv(randomColor.hue, rand.nextDouble(.5),1.0);
        egg.classes.add("visible-egg");
        egg.style..setProperty('fill', finalColor.toStyleString());
        egg.id="${phrase}_egg";
        return egg;

    }

    Element get newphraseElement {
        DivElement ret = new DivElement()..text = this.phrase..classes.add("phrase");
        Random rand = new Random(phrase.codeUnitAt(phrase.length-1));
        int number = rand.nextIntRange(-20,20);
        int width = rand.nextIntRange(75,150);
        int leftPos = rand.nextIntRange(45,75);
        int topPos = rand.nextIntRange(-10,0);
        ret.style.transform = "translate(-50%,-50%) rotate(${number}deg)";
        ret.style.width ="${width}px";
        ret.style.marginLeft="${leftPos}%";
        ret.style.marginTop="${topPos}px";

        return ret;
    }

    Element get imagePreviewElement {
        final ImageElement image = new ImageElement()..classes.add("eggThumbnail");
        populateImage(image);
        return image;
    }

    Future<void> populateImage(ImageElement image) async{
        try {
            ImageElement real = await Loader.getResource(
                "${MetaDataSlurper.podUrl}$phrase.png");
            image.src = real.src;

        }on LoaderException {
            //no worries.
        }
    }
}