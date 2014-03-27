import 'packages/sdhs/Sdhs.dart';
import "dart:io";

@Route("/test") String my_function() {
  return "LOOOOL";
}

@Route("/nope")
String other_func() {
  return "Mdr";
}

void main() {
  Sdhs r = new Sdhs(8080);

  r.addRouteFile("/index", "../assets/index.html", method: "GET");
  r.addRoute(my_function);
  r.addRoute(() => "Salut", session: null, routePath: "/other", base_url: "", method : "GET");
  r.addRoute(#other_func);
  r.run();
}
