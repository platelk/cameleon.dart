library restlib;

import "dart:io";
import "dart:async";
import "dart:mirrors";
import 'dart:convert';

part 'src/Route.dart';
part 'src/RouteObject.dart';
part 'src/RouteFileObject.dart';

class Sdhs {
  int port;
  String ip = "0.0.0.0";
  List<RouteObject> _routes;
  var handleNotFound = null;

  Sdhs([this.port = 80, this.ip = "0.0.0.0"]) {
    this._routes = new List<RouteObject>();
    print("[Sdhs] Sdhs Object created.");
    this.handleNotFound = this._onHttpHandleNotFound;
  }

  static RouteObject _getMatchedObject(HttpRequest request, List<RouteObject> _routes) {
    print("[Sdhs] HttpResquest: ${request.method} - [${request.uri.toString()}] (${request.requestedUri.host} on port ${request.requestedUri.port})");
    String m = request.method;
    String url = request.uri.toString();
    HttpResponse res = request.response;

    bool have_found = false;
    int idx = -1;
    int max_length = 0;
    for (int i = 0; i < _routes.length; i++) {

      Iterable<Match> matches = _routes[i].url.allMatches(url);
      for (Match reg_match in matches) {
        String match = reg_match.group(0);
        // TODO : change "," by a class member value
        if (_routes[i].method.split(",").contains(m) && match.length > 0 && match.length > max_length) {
          idx = i;
          max_length = match.length;
        }
      }
    }
    if (idx > -1) {
      return _routes[idx];
    } else {
      return null;
    }
  }

  void _onHttpDataRequest(HttpRequest request) {
    HttpResponse res = request.response;
    void _onComplete() {
        RouteObject obj = _getMatchedObject(request, this._routes);
        print(obj);
        if (obj == null)
          this.handleNotFound(res);
        else {
          Iterable<Match> l = obj.url.allMatches((request.uri.toString()));
          //print("Match : ${m.groups}");
          obj(l, request, res)
            ..then((value) {
                if (value is Future) {
                  value.then((e) => res.write(e));
                } else {
                  res.write(value);
                }
              })
            ..whenComplete(() => res.close())
            ..catchError((Error) => this.handleNotFound(res));
          //(new Future(() => print("ok"))).catchError(onError)
        }
        return ;
    }
    new Future(() =>_onComplete());
    return;
  }

  void _onHttpError() {
    print("[Sdhs] HttpError!");
  }

  void _onHttpHandleNotFound(HttpResponse response) {
    print("[Sdhs] HttpNotFound !");
    response.statusCode = HttpStatus.NOT_FOUND;
    response.write("404 Not Found.");
    response.close();
  }

  void addRoute(var route, {Session session : null, String routePath : null, String base_url: "", String method : null}) {
    InstanceMirror im = reflect(route);

    if (im.type is FunctionTypeMirror || route is Symbol) {
      this.addFunctionRoute(route, session : session, routePath: routePath, base_url: base_url, method : method);
    } else if (im.type is ClassMirror) {
      this.addClassRoute(route, session : session, routePath: routePath, base_url: base_url, method : method);
    }
  }

  void addFunctionRoute(var route, {Session session : null, String routePath : null, String base_url: "", String method : null}) {
    MethodMirror m = null;
    print("Route : ${route}");
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

    print(m.metadata);
    if (m is MethodMirror) {
      print("m is methodMirror");
      m.metadata.forEach((metadata) {
        print(metadata);
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
          RouteObject r = null;
          if (m.owner is FunctionTypeMirror) {
            r = new RouteObject.function(new RegExp(base_url + path), met,
                                                      metadata.reflectee.others_param,
                                                      route);
          } else {
            r = new RouteObject(new RegExp(base_url + path), met,
                                          metadata.reflectee.others_param,
                                          null, m);
          }
          print("Add route [${r}]");
          this._routes.add(r);
        }
      });
      if (have_found_route == false) {
        RouteObject r = null;
        print(m.owner);
        if (m.owner is FunctionTypeMirror) {
          r = new RouteObject.function(new RegExp(base_url + routePath), method,
                                                            "",
                                                            route);
        } else {
          r = new RouteObject(new RegExp(base_url + routePath), method,
                                                  "",
                                                  null, m);
        }
        print("Add route [${r}]");
        this._routes.add(r);
      }
    }
    print("Adding...");
  }

  void addClassRoute(var route, {Session session : null, String routePath : null, String base_url: "", String method : null}) {
    InstanceMirror im = reflect(route);
    ClassMirror classMirror = im.type;


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
          RouteObject r = new RouteObject(new RegExp(base_url + mdata.reflectee.url.toString()),
                                      mdata.reflectee.method.toString(),
                                      mdata.reflectee.others_param,
                                      im, method);
          print("Add route [${r}]");
          this._routes.add(r);
        }
      }
    });
  }

  void addRouteFile(String route, String file_name, {String base_path: "", String method: "GET", FileCallback function: null, Encoding encoding: ASCII, Session session : null}) {
    print("Add route [${route}]");
    String r = (base_path + route).replaceAll("\\", "/");
    this._routes.add(new RouteObject.function(new RegExp(r), method, "HttpRequest,HttpResponse", new RouteFileObject(base_path + file_name, function, encoding)));
  }

  void addRouteDir(String route, String dir_path, {String base_path: "", String method: "GET", FileCallback function: null, Encoding encoding: ASCII, Session session : null}) {
    Directory dir = new Directory(base_path + dir_path);

    List<FileSystemEntity> l = dir.listSync(recursive : true);
    for (FileSystemEntity f in l) {
        if (f is File) {
          this.addRouteFile(route + f.path.substring(dir.path.length), f.path, method : method , function : function, encoding: encoding);
        }
    }
  }

  void removeRoute(String route) {
    this._routes.removeWhere((RouteObject r) {
      return r.url.hasMatch(route);
    });
  }

  void run() {
    print("[Sdhs] HttpServer listen on ${this.ip}:${this.port}");
    HttpServer.bind(this.ip, this.port).then((HttpServer server) {
      print("Start.");
      server.listen(this._onHttpDataRequest);
      print("End.");
    });
  }
}