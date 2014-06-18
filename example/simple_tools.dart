import 'packages/cameleon/cameleon.dart';
import 'dart:io';

class WebApp {
  @Route('/')
  Object index() {
    print("Index");
    return Route.file('assets/index.html');
  }

  @Route("login/:login/:mdp", others_param: "HttpSession")
  Object adminLogin(String login, String mdp, HttpSession session) {
    print('Admin registration');
    if (login == "admin" && mdp == "admin") {
      session["isLogin"] = true;
      return Route.redirect('admin/index');
    }
    return Route.redirect('/');
  }
  
  @Route.Interceptor(r'admin/.*')
  void adminZone() {
    print("Admin zone");
  }

  @Route("data", method: "GET,POST", others_param: "Data")
  String data(Map d) {
    print('Post request ${d}');
    return "Post request";
  }
  
  @Route(r"admin/index", others_param: "HttpSession")
  dynamic adminMainPage(HttpSession session) {
    if (session["isLogin"]) {
      print("AdminMainPage");
      return "Admin Zone";
    }
    return Route.redirect('/');
  }
}


void main() {
  Cameleon r = new Cameleon(4240);
  
  r.addRoute(new WebApp());
  r.setDebug(true, level: 3);
  r.run();
}