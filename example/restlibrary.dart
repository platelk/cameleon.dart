import 'packages/sdhs/Sdhs.dart';
import "dart:io";

@Route("/")
class Root {
    Sdhs rest;

    Root([this.rest = null]);

    @Route(r'login/(\w+)/(\w+)', others_param: "Session")
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
      sleep(new Duration(seconds:10));
      print("getApps Called");
      return "App getted";
    }

    @Route(r'blog/(\d+)')
    String getBlogBillet(int b) {
      return "Billet nb ${b}";
    }

    @Route(r'apps/', method: "PUT")
    String putApps() {
      sleep(new Duration(seconds:10));
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
  Sdhs r = new Sdhs(8080);

  r.addRoute(new Root(r));
  r.addRouteFile("/index", "../assets/index.html", method: "GET");
  r.addRouteDir("/public", "../assets");
  r.run();
}
