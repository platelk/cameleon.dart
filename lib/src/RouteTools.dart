part of sdhs;

class RouteTools {
  
}

/**
 * [Redirect] object is a return value that indicate to SDHS that it will need to redirect the user to [Redirect.url];
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
}

class Next extends RouteTools {
  
}