# Simplest Dart Http Server 0.1.5
## Introduction
sdhs is a simple http server that provide function to easy create a RESTfull API or a web site.
This library use the more possible standard API to have the less possible dependancy and use the power of dart.

## Goal
The goal of this library is to provide the easyest way to create a HTTP service with dart.
This library use [Mirror API](https://api.dartlang.org/apidocs/channels/stable/#dart-mirrors.Mirror) and [Annotation](https://api.dartlang.org/apidocs/channels/stable/#analyzer/analyzer.Annotation) to provide the less constraint.

## Warning
This library is actually under developpment, please do not use for prodution

## Features

Actualy the library provide :
  * Routing
    * Creating route with `Regexp` dart modul
    * Creating route bind to a file
    * Creating route tree bind to a class
    * Creating route tree bind to a directory
    * Deleting route
  * Callback
    * Get url parameter with `Regexp` group
    * Get contextual paramater
```dart
  // Regexp Param
  @Route(r'apps/(\w+)')
  String putWordApps(String w)

  // Regexp Param and contextual param
  @Route(r'login/(\w+)/(\w+)', others_param: "Session")
  String login(String login, String pass, HttpSession session) 
```
  * Http
    * Handle GET / PUT / DELETE http request
    * Http Server
    
## Usage
The goal of the library is to be easy to use. you can define your route in many way, depend of what you want.
```dart
import 'packages/sdhs/Sdhs.dart';

@Route("/test") String my_function() {
  return "Test, test, this is a test.";
}

@Route("/nope")
String other_func() {
  return "Nope, is not here";
}

class R {
    @Route(r'class')
    String login() {
      return "Hi ! i'm glad to see you";
    }
}

void main() {
  Sdhs r = new Sdhs(8080);

  r.addRouteFile("/index", "../assets/index.html", method: "GET");
  r.addRoute(my_function);
  r.addRoute(() => "Salut", session: null, routePath: "/other", base_url: "", method : "GET");
  r.addRoute(#other_func);
  r.addRoute(new R());
  r.run();
}

```
  
## Future
In the future, more feature will be add
  * Getting GET / PUT argument
  * HTTPS
  * Route depending of a session
  * HTML template motor
  * ...

### Author

A young software developper, who loved dart.
  
### Information
Acutaly this library is developped by myself, if you have any idea, amelioration, bug, ... do not hesitate to contact me.
G+ : [+Kevin PLATEL](https://plus.google.com/+KévinPlatel)
Mail : [Kevin PLATEL](platel.kevin@gmail.com)
