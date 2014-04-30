import 'packages/sdhs/Sdhs.dart';
import "dart:io";
import "dart:async";



@Route(r"/")
Future<String> other_func([String request = "", var a = null]) {
  return new Future(() => "welcome");
}


void main() {
  Sdhs r = new Sdhs(4242);

  r
  ..addRouteFile("/index", "assets/index.html", method: "GET")
  ..addRoute(() => "Salut", routePath: "/other")
  ..addRoute(#other_func)
  // Or just : r.addRoute(other_func)
  ..setDebug(true, level: 4)
  ..run();
}
