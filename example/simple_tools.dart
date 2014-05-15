import 'packages/sdhs/sdhs.dart';
import 'dart:io';

@Route("/")
class WebApp {
  @Route("login/:login/:mdp", others_param: "HttpSession")
  Object adminLogin(String login, String mdp, HttpSession session) {
    if (login == "admin" && mdp == "admin") {
      session["isLogin"] = true;
      return new Redirect("/admin/index");
    }
    return 'Bad password';
  }
  
  @Route.Interceptor(r'admin/.*')
  adminZone() {
    print("Admin zone");
  }
  
  @Route(r"admin/index")
  String adminMainPage() {
    print("AdminMainPage");
    return "Main page";
  }
}


void main() {
  Sdhs r = new Sdhs(4242);
  
  r.addRoute(new WebApp());
  r.run();
}