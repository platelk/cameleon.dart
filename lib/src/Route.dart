part of cameleon;

/**
 * [Route] is a annotation type used to create the routing.
 *
 * - url : is the route that will be used
 * - method : It is the method that the route will listen. (GET / PUT ...)
 * - others_param : It decribes the additional parameter passed to the callBack function.
 *         Today, to possible parameter are : "RouteObject", "HttpRequest", "HttpResponse", "HttpSession".
 *         To get POST/GET data, you just put 'PostData' or 'GetData' or 'Data' for the both.
 *         The separator used is ",", So to get multiple parameter, the [String] passed will look like "RouteObject,HttpRequest"
 */
class Route {
  final String url;
  final String method;
  final String others_param;
  final bool isRedirect;
  static final Next _next = new Next();
  final bool isInterceptor;
  final bool isFile;

  const Route(this.url, {this.method: "GET", this.others_param: ""}) : isInterceptor = false, isRedirect= false, isFile= false;
  const Route.Interceptor(this.url, {this.method: "GET", this.others_param: ""}) : isInterceptor = true, isRedirect= false, isFile= false;
  static String file(url) {
    return new RouteFileObject(url).getFile();
  }

  static Redirect redirect(url) {
    return new Redirect(url);
  }

  static Next get next => Route._next;

  String toString() => "${this.method} : [${this.url}]";
}