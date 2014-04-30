import 'packages/sdhs/sdhs.dart';
import "dart:io";

@Route("/func")
String my_function() {
  return "my_function call";
}

@Route(r"/login/(\w+)/:password", others_param: "HttpSession,Sdhs")
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
  Sdhs r = new Sdhs(4244);

  r.addRoute(login);
  r.addRoute(disconnect);
  r.setDebug(true, level: 4);
  r.run();
}
