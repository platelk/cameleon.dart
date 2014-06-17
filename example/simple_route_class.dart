import 'packages/cameleon/cameleon.dart';
import "dart:io";

@Route("/")
class Root {
    Sdhs rest;

    Root([this.rest = null]);

    @Route(r'login/(\w+)/(\w+)', others_param: "HttpSession")
    String login(String login, String pass, HttpSession session) {
      if (session.isNew) {
        session["login"] = login;
        session["pass"] = pass;
        return "registration of ${session["login"]}, ${pass}";
      }
      return "Hi ${session["login"]}";
    }

    @Route(r'apps')
    String getApps() {
      print("getApps Called");
      return "App getted";
    }

    @Route(r'blog/(\d+)')
    String getBlogBillet(int b) {
      return "Billet nb ${b}";
    }

    @Route(r'apps/', method: "PUT")
    String putApps() {
      print("putApps called");
      return "App putted";
    }

    @Route(r'apps/(\d)', method: "PUT")
    String putNumApps(int d) {
      print("putNumApps called");
      return "App Numputted ${d}";
    }

    @Route(r'apps/(\d+)', method: "PUT")
    String putBigNumApps(int d) {
      print("putBigNumApps called");
      return "App BigNumputted ${d}";
    }

    @Route(r'apps/(\d+)/(\d+)', method: "PUT", others_param: "HttpRequest,RouteObject")
    String putBigMulNumApps(int d, int d2, HttpRequest r, RouteObject route) {
      print("putBigNumApps called ${d} - ${d2} ${r} ${route}");
      this.rest.addRouteFile("/test", "../assets/index.html", method: "GET");
      return "App BigNumputted ${d} - ${d2}";
    }


    @Route(r'apps/(\w+)', method: "PUT")
    String putWordApps(String w) {
      print("putWordApps called");
      return "App Word putted ${w}";
    }

    String postApps() {
      print("postApps called");
      return "App posted";
    }
}

void main() {
  Cameleon r = new Cameleon(8080);

  r.addRoute(new Root(r));
  r.run();
}
