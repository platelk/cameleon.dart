part of cameleon;

/**
 * [RouteObject] is a real representation of a route.
 */
class RouteObject {
  RegExp url;
  String method;
  List<String> others_param;
  var callBackFunction = null;
  InstanceMirror _objectInstance = null;
  var _function = null;
  var _argument = null;
  var _completer;
  bool isInterceptor = false;

  RouteObject(this.url, this.method, String others_params, this._objectInstance, this.callBackFunction) {
    this.others_param = others_params.split(",");
  }
  RouteObject.function(this.url, this.method, String others_params, this._function) {
    this.others_param = others_params.split(",");
    this.callBackFunction = this._function;
  }

  String toString() => "Route: ${this.method} - [${this.url}] -> ${this.callBackFunction}";

  Future _callFunction(List arg) {
    Future f = null;
    if (this._function != null) {
          f = new Future(() => Function.apply(this._function, arg));
    }
    else if (this._objectInstance == null) {
          f = new Future (() => (this.callBackFunction.owner).invoke(this.callBackFunction.simpleName, arg).reflectee);
    } else {
          f = new Future(() => this._objectInstance.invoke(this.callBackFunction.simpleName, arg).reflectee);
    }
    /* if (isInterceptor) {
      f = new Future(() => Route.next);
    }*/
    return f;
  }

  Future call(Iterable<Match> l, HttpRequest r, HttpResponse response, [Cameleon s = null]) {
    List arg = new List();
    for (Match m in l) {
      List<int> idx_list = new List<int>.generate(m.groupCount, (int i) {
        return i+1;
      });
      List<String> idx = m.pattern.pattern.split("\\");
      int i = 1;

      // Getting parameter to send to the callback
      for (String g in m.groups(idx_list)) {
        if (i < idx.length && idx[i][0] == "d") {
          arg.add(int.parse(g));
        } else {
          arg.add(g);
        }
      }
    }
   // Adding lib param
   bool asData = false;
   bool needPostData = false;
   bool needGetData = false;
   bool needRawPostData = false;
   Map post_data = new Map();
   Map get_data = new Map();
   Map data = new Map();
   List rawData = new List();
   for (String k in this.others_param) {
     if (k == "RouteObject") {
       arg.add(this);
     } else if (k == "HttpRequest") {
       arg.add(r);
     } else if (k == "HttpResponse") {
       arg.add(response);
     } else if (k == "HttpSession") {
       arg.add(r.session);
     } else if (k == "Server") {
       arg.add(s);
     } else if (k == "PostData") {
       asData = true;
       needPostData = true;
       arg.add(post_data);
     } else if (k == "RawData") {
       asData = true;
       needPostData = true;
       needRawPostData = true;
       arg.add(rawData);
     } else if (k == "GetData") {
       asData = true;
       needGetData = true;
       // TODO : getting POST and GET Data
       arg.add(get_data);
     } else if (k == "Data") {
       asData = true;
       needGetData = true;
       needPostData = true;
       // TODO : getting POST and GET Data
       arg.add(data);
     } else {
       print("Error : $k didn't match");
     }
   }
    if (asData == false) {
      return this._callFunction(arg);
    } else {
      BytesBuilder builder = new BytesBuilder();
      Completer c = new Completer();
      r.listen((buffer) {
        if (needPostData)
          builder.add(buffer);
      }).onDone(() {
        print("done");
        if (needPostData) {
          if (needRawPostData) {
            rawData = builder.takeBytes();
          } else {
            String playloadData = new String.fromCharCodes(builder.takeBytes());
            playloadData.split("&").forEach((String e) {
              List<String> l = e.split("=");
              if (l.length > 1) {
                post_data[Uri.decodeFull(l[0])] = Uri.decodeFull(l[1]);
              }
            });
          }
        }
        if (needGetData) {
          get_data = r.uri.queryParameters;
        }
        print(arg);
        this._callFunction(arg).then((d) => c.complete(d));
      });
      return c.future;
    }
  }
}
