import 'dart:html';

String caption;
const String podUrl = "http://farragnarok.com/PodCasts/";

void main()
{
    String initPW = "";
    if(Uri.base.queryParameters['passPhrase'] != null) {
        initPW = Uri.base.queryParameters['passPhrase'];
    }

    caption = initPW;
    hack(caption);
    print("Future JR: be sure to hack images image caches. You can find them by id.");
    //todo: do NOT actually wire this into anything just yet, just start out with testing things. woudln't do to spoil the whole thing for the wastes
}

void hack(String hack) {


}