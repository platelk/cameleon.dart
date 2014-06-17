library cameleon;

import "dart:io";
import "dart:async";
import "dart:mirrors";
import 'dart:convert';

part 'src/Route.dart';
part 'src/RouteObject.dart';
part 'src/RouteFileObject.dart';
part 'src/RouteTools.dart';

typedef String NotFoundHandler(HttpResponse);

class Cameleon {
  static String KEY_ROUTE_SESSION = "__Cameleon_KEY_ROUTE_SESSION";
  static String WORD_SEP = ",";
  String _version = "0.2.3";
  int port;
  String ip = "0.0.0.0";
  List<RouteObject> _routes;
  HttpServer _serv;
  NotFoundHandler handleNotFound = (v) => "404 not found.";
  bool _debugMode = false;
  int _debugModeLevel = 0;
  var _preCallFunction = null;

  Cameleon([this.port = 80, this.ip = "0.0.0.0"]) {
    this._routes = new List<RouteObject>();
    _printDebug("[Cameleon] Cameleon Object created.");
  }

  static void addSessionRoute(RouteObject r, HttpSession session) {
    if (session == null || r == null)
      return ;
    if (session[Cameleon.KEY_ROUTE_SESSION] == null) {
      session[Cameleon.KEY_ROUTE_SESSION] = new List<RouteObject>();
    }
    session[Cameleon.KEY_ROUTE_SESSION].add(r);
  }

  void _printDebug(data, {int level : 0}) {
    if (this._debugMode && this._debugModeLevel <= level) {
      print(data);
    }
  }

  /**
   * Transform a Route format '/one/:var/two' to '/one/(\w+)/two'
   * Return a String containing the Regexp's pattern
   */
  static String transformToRegexp(String s) {
    return s.replaceAll(new RegExp(r":+(\w:)?\w+"), '(\\w+)');
  }

  List<RouteObject> _getMatchedObject(HttpRequest request, List<RouteObject> _routes) {
    _printDebug("[Cameleon] HttpResquest: ${request.method} - [${request.uri.toString()}] (${request.requestedUri.host} on port ${request.requestedUri.port})");
    String m = request.method;
    String url = request.uri.toString();
    HttpResponse res = request.response;
    List<RouteObject> _lRouteObject = new List<RouteObject>();
    List<RouteObject> _lInterceptor = new List<RouteObject>();

    bool have_found = false;
    int idx = -1;
    int max_length = 0;
    for (int i = 0; i < _routes.length; i++) {

      Iterable<Match> matches = _routes[i].url.allMatches(url);
      for (Match reg_match in matches) {
        String match = reg_match.group(0);
        if (_routes[i].isInterceptor) {
          _lInterceptor.insert(0, _routes[i]);
        } else if (_routes[i].method.split(Cameleon.KEY_ROUTE_SESSION).contains(m) && match.length > 0 && match.length > max_length) {
          idx = i;
          max_length = match.length;
          _lRouteObject.insert(0, _routes[i]);
        }
      }
    }
    _lRouteObject.insertAll(0, _lInterceptor);
    return _lRouteObject;
  }

  HttpResponse _setHttpResponse(HttpResponse res) {
    res.headers.set(HttpHeaders.SERVER, "Cameleon/" + this._version);
    res.headers.date = new DateTime.now();
    return res;
  }

  void _writeValue(var value, HttpResponse res) {
    if (value is Future) {
       value.then((e) {
         try {
         ContentType c = ContentType.parse(e);
         res.headers.set(HttpHeaders.CONTENT_TYPE, c.mimeType);
         res.headers.set(HttpHeaders.CONTENT_ENCODING, c.charset);
         } catch(e) {
         } finally {
           res.write(e);
         }
       });
    } else {
      try {
        ContentType c = ContentType.parse(value);
        res.headers.set(HttpHeaders.CONTENT_TYPE, c.mimeType);
        res.headers.set(HttpHeaders.CONTENT_ENCODING, c.charset);
      } catch(e) {

      } finally {
        res.write(value);
      }
    }
    res.close();
  }

  void _routeTreatment(HttpRequest request, HttpResponse res, List<RouteObject> listObj) {
    if (listObj.length == 0) {
      this._onHttpHandleNotFound(res);
      return ;
    }
    RouteObject obj = listObj.removeAt(0);
    Iterable<Match> l = obj.url.allMatches((request.uri.toString()));
    //print("Match : ${m.groups}");
    obj(l, request, res, this)
      ..then((value) {
        if (value is RouteTools || value == null) {
          if (value is Next || obj.isInterceptor) {
            _routeTreatment(request, res, listObj);
          } else if (value is Redirect) {
            value.redirect(res, this._serv);
            this._writeValue("Redirect", res);
          }
        } else {
          this._writeValue(value, res);
        }
      })
      //..whenComplete()
      ..catchError((Error) => this._onHttpHandleNotFound(res));
  }

  void _onHttpDataRequest(HttpRequest request) {
    _printDebug("HttpRequest receive", level: 1);
    _printDebug("request: ${request}", level: 2);
    HttpResponse res = this._setHttpResponse(request.response);
    void _onComplete() {
        HttpSession session = request.session;
        List<RouteObject> listObj = null;
        if (session[Cameleon.KEY_ROUTE_SESSION] != null) {
          listObj = _getMatchedObject(request, session[Cameleon.KEY_ROUTE_SESSION]);
        }
        if (listObj == null || listObj.length == 0) {
          listObj = _getMatchedObject(request, this._routes);
        }
        _routeTreatment(request, res, listObj);
        return ;
    }
    new Future(() =>_onComplete());
    return;
  }

  void _onHttpError() {
    _printDebug("[Cameleon] HttpError!");
  }

  void _onHttpHandleNotFound(HttpResponse response) {
    _printDebug("[Cameleon] HttpNotFound !");
    response.statusCode = HttpStatus.NOT_FOUND;
    this._writeValue(this.handleNotFound(response), response);
  }

  /**
   * Define the function used when the route is not found
   */
  void  setNotFoundhandler(NotFoundHandler f) {
    this.handleNotFound = f;
  }

  void _addRouteIn(RouteObject r, HttpSession session) {
    if (session != null) {
      Cameleon.addSessionRoute(r, session);
    } else {
      this._routes.add(r);
    }
  }

  /**
   * Bind a function or a class to [routePath] route
   * The route object can be a function ([addFunctionRoute] will be call) or a class instance ([addClassRoute] will be call)
   * [base_url] will be concat with [routePath]
   * A route can be add only for a session by passing a [Session] in [session] parameter
   *
   * ##Note
   * If [routePath] is not provide, the annotion [Route] will be used to create the routing. if it is provide, it will erase the route provide by the annotation
   */
  void addRoute(var route, {HttpSession session : null, String routePath : null, String base_url: "", String method : null, String other_param: "", bool isInterceptor : false}) {
    InstanceMirror im = reflect(route);

    if (im.type is FunctionTypeMirror || route is Symbol) {
      _addFunctionRoute(route, session : session, routePath: routePath, base_url: base_url, method : method);
    } else if (im.type is ClassMirror) {
      _addClassRoute(route, session : session, routePath: routePath, base_url: base_url, method : method);
    }
  }

  void _addFunctionRoute(var route, {HttpSession session : null, String routePath : null, String base_url: "", String method : null, String other_param: "", bool isInterceptor : false}) {
    MethodMirror m = null;
    RouteObject r = null;
    if (route is Symbol) {
      currentMirrorSystem().libraries.forEach((k, v) => v.declarations.forEach((k2, v2) {
        if (v2.simpleName == route) {
          m = v2;
        }
      }));
    } else {
        InstanceMirror im = reflect(route);
        FunctionTypeMirror fn = im.type;
        m = fn.callMethod;
    }
    bool have_found_route = false;

    if (m is MethodMirror) {
      m.metadata.forEach((metadata) {
        if (metadata.reflectee is Route) {
          have_found_route = true;
          String path = routePath;
          if (path == null) {
            path = metadata.reflectee.url.toString();
          }
          String met = method;
          if (met == null) {
            met = metadata.reflectee.method.toString();
          }
          if (m.owner is FunctionTypeMirror) {
            r = new RouteObject.function(new RegExp(transformToRegexp(base_url + path)), met,
                                                      metadata.reflectee.others_param,
                                                      route);
            if (metadata.reflectee.isInterceptor || isInterceptor) {
              r.isInterceptor = true;
            }
          } else {
            r = new RouteObject(new RegExp(transformToRegexp(base_url + path)), met,
                                          metadata.reflectee.others_param,
                                          null, m);
            if (metadata.reflectee.isInterceptor || isInterceptor) {
              r.isInterceptor = true;
            }
          }
          this._addRouteIn(r, session);
        }
      });
      if (have_found_route == false) {
        if (m.owner is FunctionTypeMirror) {
          r = new RouteObject.function(new RegExp(transformToRegexp(base_url + routePath)), method,
                                                            "",
                                                            route);
          if (isInterceptor) {
            r.isInterceptor = true;
          }
        } else {
          r = new RouteObject(new RegExp(transformToRegexp(base_url + routePath)), method,
                                                  "",
                                                  null, m);
          if (isInterceptor) {
            r.isInterceptor = true;
          }
        }
        this._addRouteIn(r, session);
      }
    }
  }

  void _addClassRoute(var route, {HttpSession session : null, String routePath : null, String base_url: "", String method : null, String other_param: ""}) {
    InstanceMirror im = reflect(route);
    ClassMirror classMirror = im.type;
    RouteObject r = null;

    classMirror.metadata.forEach((metadata) {
      if (metadata.reflectee is Route) {
        base_url += metadata.reflectee.url.toString();
      }
    });

    // Getting Route Method
    Iterable decls =
        classMirror.declarations.values.where(
                                      (dm) => dm is MethodMirror && dm.isRegularMethod);
    decls.forEach((MethodMirror method) {
      for (var mdata in method.metadata) {
        if (mdata.reflectee is Route) {
          r = new RouteObject(new RegExp(transformToRegexp(base_url + mdata.reflectee.url.toString())),
                                      mdata.reflectee.method.toString(),
                                      mdata.reflectee.others_param,
                                      im, method);
          if (mdata.reflectee.isInterceptor) {
            r.isInterceptor = true;
          }
          this._addRouteIn(r, session);
        }
      }
    });
  }

  RouteObject _addRouteFile(String route, String file_name, {String base_path: "", String method: "GET", String other_param: "", FileCallback function: null, Encoding encoding: null, HttpSession session : null}) {
      String r = (base_path + route).replaceAll("\\", "/");
      RouteObject ro = new RouteObject.function(new RegExp(r), method, "HttpRequest,HttpResponse", new RouteFileObject(base_path + file_name, function, encoding));
      return ro;
    }

  /**
   * Bind a route to a file.
   * The FileCallBack param is a function that will be call when the entire file has been read, and the content will be pass to the function.
   * Note : the entire file will be send
   */
  void addRouteFile(String route, String file_name, {String base_path: "", String method: "GET", String other_param: "", FileCallback function: null, Encoding encoding: null, HttpSession session : null}) {
    route = route.replaceAll(new RegExp(r'\\'), "\/");
    file_name = file_name.replaceAll(new RegExp(r"\\"), "\/");
    RouteObject ro = _addRouteFile(route, file_name, base_path: base_path, method: method, other_param: other_param, function: function, encoding: encoding, session: session);
    this._addRouteIn(ro, session);
  }

  /**
   * Bind all the file content in a directory.
   * The [addRouteDir] will call [addRouteFile] on each file present in the directory
   */
  void addRouteDir(String route, String dir_path, {String base_path: "", bool recursive : true, String method: "GET", String other_param: "", FileCallback function: null, Encoding encoding: null, HttpSession session : null}) {
    Directory dir = new Directory(base_path + dir_path);

    List<FileSystemEntity> l = dir.listSync(recursive : recursive);
    for (FileSystemEntity f in l) {
        if (f is File) {
          this.addRouteFile(route + f.path.substring(dir.path.length), f.path, method : method , function : function, encoding: encoding);
        }
    }
  }

  /**
   * Remove the route which match with the given parameter
   */
  void removeRoute(String route, {HttpSession session: null}) {
    if (session != null && session[Cameleon.KEY_ROUTE_SESSION] != null) {
      session[Cameleon.KEY_ROUTE_SESSION].removeWhere((RouteObject r) {
        return r.url.hasMatch(route);
      });
    }
    this._routes.removeWhere((RouteObject r) {
      return r.url.hasMatch(route);
    });
  }

  /**
   * Define if Debug message are displayed and the level of debug displayed. 0 is the lower.
   */
  void setDebug(bool s, {int level: 0}) {
    this._debugMode = s;
    this._debugModeLevel = level;
  }

  /**
   * Start the HttpServer
   * ## Note :
   * If no server are passed, a HttpServer will be create.
   * # Important :
   * To work, the server must be a BroadcastServer. if it isn't, it will cause issue.
   *
   * This work will allow to chain route definition and handling.
   */
  Future<HttpServer> run({HttpServer server : null}) {
    _printDebug("Run HttpServer");
    Completer c = new Completer();
    if (server == null) {
      HttpServer.bind(this.ip, this.port).then((HttpServer server) {
        this._serv = server;
        _printDebug("Bind HttpServer.listen.");
        var m = server.asBroadcastStream();
        m.listen(this._onHttpDataRequest);
        c.complete(m);
      });
    } else {
        this._serv = server;
        server.listen(this._onHttpDataRequest);
        c.complete(server);
    }
    return c.future;
  }
}