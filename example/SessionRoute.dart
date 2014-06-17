import 'packages/cameleon/cameleon.dart';
import "dart:io";

@Route("/func")
String my_function() {
  return "my_function call";
}

@Route(r"/login/:login/:password", others_param: "HttpSession,Sdhs")
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

void main() {
  Cameleon r = new Cameleon(4244);

  r
  ..addRoute(login)
  ..addRoute(disconnect)
  ..setDebug(true, level: 4)
  ..run();
}
