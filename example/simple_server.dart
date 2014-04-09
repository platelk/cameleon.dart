import 'packages/sdhs/Sdhs.dart';
import "dart:io";
import "dart:async";

@Route("/test") String my_function() {
  return "LOOOOL";
}

@Route("/data", method: "GET,POST", others_param: "HttpRequest")
String get_data(HttpRequest res) {
  res.forEach((e) => print("-> " + new String.fromCharCodes(e)));
  print(res);
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
  Sdhs r = new Sdhs(8080);

  r.addRouteFile("/index", "../assets/index.html", method: "GET");
  r.addRoute(my_function);
  r.addRoute(get_data);
  r.addRoute(() => "Salut", session: null, routePath: "/other", base_url: "", method : "GET");
  r.addRoute(#other_func);
  r.addRoute(new R());
  r.run();
}
