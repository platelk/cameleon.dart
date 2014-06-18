# Cameleon.dart 0.3.3
## Introduction
Cameleon.dart is a simple http server that provide function to easy create Http based service like RESTfull API, web site...
This library use the more possible standard API to have the less possible dependancy and use the power of dart.

## Goal
The goal of this library is to provide the easiest way to create a HTTP service with dart.
This library use [Mirror API](https://api.dartlang.org/apidocs/channels/stable/#dart-mirrors.Mirror) and [Annotation](https://api.dartlang.org/apidocs/channels/stable/#analyzer/analyzer.Annotation) to provide the less constraint.

## Warning
This library is actually under developpment, please do not use for production

## Features

Actualy the library provide :
  * Routing
    * Creating route with `Regexp` dart module
    * Support of '/:param' syntax
```dart
    // Route definition with a [Regexp] and [:syntax]
    @Route(r"/login/(\w+)/:password")
    String login(String login, String password) {
      if (login == "admin" && password == "admin") {
        return "Ok";
      }
      return "fail";
    }
```
  * Http tools
    * Creating route bind to a file
    * Creating route tree bind to a class
    * Creating route tree bind to a directory
    * Deleting route
    * Redirect
    * Create interceptor
    * Get and Post Data
```dart
    @Route("data", method: "GET,POST", others_param: "PostData,GetData")
      String data(Map post_data, Map get_data) {
        print('request ${post_data}, ${get_data}');
        return "Post request";
      }
```
  * Session
    * use can use session
    * add route only for one session
    * Store data on session
  * Callback
    * Get url parameter with `Regexp` group
    * Get contextual paramater

```dart
  // Regexp Param
  @Route(r'apps/(\w+)')
  String putWordApps(String w)

  // Regexp Param and contextual param
  @Route(r'login/(\w+)/(\w+)', others_param: "HttpSession")
  String login(String login, String pass, HttpSession session) 
```
  * Http
    * Handle GET / PUT / DELETE http request
    * Http Server
    
## Usage
The goal of the library is to be easy to use. you can define your route in many way, depend of what you want.
### Simple example
```dart
import 'packages/cameleon/cameleon.dart';
import 'dart:io';

class WebApp {
  @Route('/')
  Object index() {
    print("Index");
    return Route.file('assets/index.html');
  }

  @Route("login/:login/:mdp", others_param: "HttpSession")
  Object adminLogin(String login, String mdp, HttpSession session) {
    print('Admin registration');
    if (login == "admin" && mdp == "admin") {
      session["isLogin"] = true;
      return Route.redirect('admin/index');
    }
    return Route.redirect('/');
  }

  @Route.Interceptor(r'admin/.*')
  void adminZone() {
    print("Admin zone");
  }

  @Route(r"admin/index", others_param: "HttpSession")
  String adminMainPage(HttpSession session) {
    if (session["isLogin"]) {
      print("AdminMainPage");
      return "Admin Zone";
    }
    return Route.redirect('/');
  }
}


void main() {
  Cameleon r = new Cameleon(4240);

  r.addRoute(new WebApp());
  r.setDebug(true, level: 3);
  r.run();
}
```

## Future
In the future, more feature will be add
  * Getting GET / PUT argument
  * HTTPS
  * HTML template motor binding depend of extension file
  * ...

### Author

A young software developper, who love dart.
  
### Information
Actualy this library is developped by myself, if you have any idea, amelioration, bug, ... do not hesitate to contact me.
G+ : [+Kevin PLATEL](https://plus.google.com/+KévinPlatel)
Mail : [Kevin PLATEL](platel.kevin@gmail.com)
