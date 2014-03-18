part of restlib;

class Route {
  final String url;
  final String method;
  final String others_param;

  const Route(this.url, {this.method: "GET", this.others_param: ""});

  String toString() => "${this.method} : [${this.url}]";
}