library restlib;

import "dart:io";
import "dart:async";
import "dart:mirrors";

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

  RouteObject _getMatchedObject(HttpRequest request) {
    print("[Sdhs] HttpResquest: ${request.method} - [${request.uri.toString()}] (${request.requestedUri.host} on port ${request.requestedUri.port})");
    String m = request.method;
    String url = request.uri.toString();
    HttpResponse res = request.response;

    bool have_found = false;
    int idx = -1;
    int max_length = 0;
    for (int i = 0; i < this._routes.length; i++) {

      Iterable<Match> matches = this._routes[i].url.allMatches(url);
      for (Match reg_match in matches) {
        String match = reg_match.group(0);
        if (m == this._routes[i].method && match.length > 0 && match.length > max_length) {
          idx = i;
          max_length = match.length;
        }
      }
    }
    if (idx > -1) {
      return this._routes[idx];
    } else {
      return null;
    }
  }

  void _onHttpDataRequest(HttpRequest request) {
    HttpResponse res = request.response;
    void _onComplete() {
        RouteObject obj = this._getMatchedObject(request);
        print(obj);
        if (obj == null)
          this.handleNotFound(res);
        else {
          Iterable<Match> l = obj.url.allMatches((request.uri.toString()));
          //print("Match : ${m.groups}");
          obj(l, request, res)
            ..then((String value) => res.write(value))
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

  void addRoute(var route) {
    InstanceMirror im = reflect(route);
    ClassMirror classMirror = im.type;
    String base_url = "";


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

  void addRouteFile(String route, String file_name, {String base_path: "", String method: "GET", FileCallback function: null}) {
    print("Add route [${route}]");
    this._routes.add(new RouteObject.function(new RegExp(route), method, "", new RouteFileObject(base_path + file_name, function)));
  }

  void addRouteDir(String route, String dir_path, {String base_path: "", String method: "GET", FileCallback function: null}) {
    Directory dir = new Directory(base_path + dir_path);

    List<FileSystemEntity> l = dir.listSync(recursive : true);
    for (FileSystemEntity f in l) {
        if (f is File) {
          this.addRouteFile(route + f.path.substring(dir.path.length), f.path, method : method , function : function);
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