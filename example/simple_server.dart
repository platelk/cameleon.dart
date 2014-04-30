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

@Route(r"/redirect")
Future<String> other_func([String request = "", var a = null]) {
  return new Future(() => "welcome");
}

@Route(r"/login/(\w+)/(\w+)", others_param: "HttpSession,Sdhs")
String login(String login, String password, HttpSession session, Sdhs s) {
  if (login == "admin" && password == "admin") {
    session["login"] = true;
    session["level"] = "admin";
    s.addRoute(my_function, session: session);
    return "Ok";
  }
  return "fail";
}

@Route("disconnect", others_param: "HttpSession")
String disconnect(HttpSession session) {
  session.destroy();
  return "Disconnected";
}

@Route("")

class R {
    @Route(r'class')
    String login() {
      return "Hi ! i'm glad to see you";
    }
}

void main() {
  Sdhs r = new Sdhs(4242);

  r.addRouteFile("/index", "../assets/index.html", method: "GET");
  r.addRoute(get_data);
  r.addRoute(() => "Salut", session: null, routePath: "/other", base_url: "", method : "GET");
  r.addRoute(#other_func);
  r.addRoute(new R());
  r.addRoute(login);
  r.addRoute(disconnect);
  r.setDebug(true, level: 4);
  r.run();
}
