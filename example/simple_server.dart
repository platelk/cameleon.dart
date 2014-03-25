import 'packages/sdhs/Sdhs.dart';
import "dart:io";

void main() {
  Sdhs r = new Sdhs(8080);

  r.addRouteFile("/index", "../assets/index.html", method: "GET");
  r.run();
}
