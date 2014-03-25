import 'dart:convert';
import 'packages/sdhs/Sdhs.dart';

/*
 * This example show how to launch a simple site from a directory
 */

void main(List<String> arg) {

  // Creation of a Sdhs server just by passing the desired port
  Sdhs r = new Sdhs(int.parse(arg[1]));

  /* Add the root directory
    ""        : Concat this string with all path
    arg[2]    : Will go recursivly get all file from this dir
    encoding  : Encoding politics
  */
  r.addRouteDir("", arg[2], encoding: null);

  // Launch the server
  r.run();
}