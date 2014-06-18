part of cameleon;

class RouteTools {
  
}

/**
 * [Redirect] object is a return value that indicate to Cameleon that it will need to redirect the user to [Redirect.url];
 * 
 * it can used as :
 *     @Route("login/:login/:mdp", others_param: "HttpSession")
 *     Object adminLogin(String login, String mdp, HttpSession session) {
 *       if (login == "admin" && mdp == "admin") {
 *         session["isLogin"] = true;
 *         return new Redirect("/admin/index");
 *       }
 *       return 'Bad password';
 *     }
 */
class Redirect extends RouteTools {
 String url;
 
 Redirect(this.url);
 
 void redirect(HttpResponse res, HttpServer serv) {
   res.headers.set(HttpHeaders.LOCATION, this.url);
   res.statusCode = HttpStatus.MOVED_TEMPORARILY;
 }

  static void redirection() {

  }
}

class Next extends RouteTools {
  
}

class Method {
  static const String GET = "GET";
  static const String POST = "POST";
  static const String OPTION = "OPTION";
}

class HttpParams {
  static const String Session = "Session";
  static const String Route = "RouteObject";
  static const String Request = "HttpRequest";
  static const String Response = "HttpResponse";
  static const String Server = "Server";
  static const String File = "RawData";
  static const String Data = "Data";
  static const String PostData = "PostData";
  static const String GetData = "GetData";
}