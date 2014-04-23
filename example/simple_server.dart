import 'packages/sdhs/Sdhs.dart';
import "dart:io";
import "dart:async";

@Route("/test") String my_function() {
  return "LOOOOL";
}

@Route("/data", method: "GET,POST", others_param: "HttpRequest,HttpResponse")
String get_data(HttpRequest res, HttpResponse r) {
  res.forEach((e) => print("-> " + new String.fromCharCodes(e)));
  print(res);
  r.headers.set(HttpHeaders.LOCATION, "http://127.0.0.1:4242/");
  r.statusCode = HttpStatus.MOVED_PERMANENTLY;
  return "ok";
}

@Route("/nope")
Future<String> other_func() {
  return new Future(() => "Mdr");
}

class R {
    @Route(r'class')
    String login() {
      return "Hi ! i'm glad to see you";
    }
}

void main() {
  Sdhs r = new Sdhs(4242);

  r.addRouteFile("/index", "../assets/index.html", method: "GET");
  r.addRoute(my_function);
  r.addRoute(get_data);
  r.addRoute(() => "Salut", session: null, routePath: "/other", base_url: "", method : "GET");
  r.addRoute(#other_func);
  r.addRoute(new R());
  r.setDebug(true, level: 4);
  r.run();
}
