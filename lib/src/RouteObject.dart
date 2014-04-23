part of sdhs;

class RouteObject {
  RegExp url;
  String method;
  List<String> others_param;
  var callBackFunction = null;
  InstanceMirror _objectInstance = null;
  var _function = null;
  var _argument = null;
  var _completer;

  RouteObject(this.url, this.method, String others_params, this._objectInstance, this.callBackFunction) {
    this.others_param = others_params.split(",");
  }
  RouteObject.function(this.url, this.method, String others_params, this._function) {
    this.others_param = others_params.split(",");
    this.callBackFunction = this._function;
  }

  String toString() => "Route: ${this.method} - [${this.url}] -> ${this.callBackFunction}";

  Future _callFunction(List arg) {
    if (this._function != null) {
          return new Future(() => Function.apply(this._function, arg));
    }
    if (this._objectInstance == null) {
          return new Future (() => (this.callBackFunction.owner).invoke(this.callBackFunction.simpleName, arg).reflectee);
    }
    return new Future(() => this._objectInstance.invoke(this.callBackFunction.simpleName, arg).reflectee);
  }

  Future call(Iterable<Match> l, HttpRequest r, HttpResponse response) {
    List arg = new List();
    print(reflect(this.callBackFunction).runtimeType);
    for (Match m in l) {
      List<int> idx_list = new List<int>.generate(m.groupCount, (int i) {
        return i+1;
      });
      List<String> idx = m.pattern.pattern.split("\\");
      int i = 1;

      // Getting parameter to send to the callback
      for (String g in m.groups(idx_list)) {
        if (idx[i][0] == "d") {
          arg.add(int.parse(g));
        } else {
          arg.add(g);
        }
      }

      // Adding lib param
      for (String k in this.others_param) {
        if (k == "RouteObject") {
          arg.add(this);
        } else if (k == "HttpRequest") {
          arg.add(r);
        } else if (k == "HttpResponse") {
          arg.add(response);
        } else if (k == "Session") {
          arg.add(r.session);
        } else if (k == "Data") {
          // TODO : getting POST and GET Data
        }
      }
    }
    return this._callFunction(arg);
  }
}
