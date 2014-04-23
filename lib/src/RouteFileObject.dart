part of restlib;

typedef String FileCallBack(String fileContent);

/**
 * [RouteFileObject] is a create by a call to [Sdhs.addFileRoute]
 */
class RouteFileObject {
  String file_path;
  File _file;
  Encoding _encod;
  var _completer;
  FileCallBack _function = null;
  HttpResponse _response;

  RouteFileObject(this.file_path, [this._function, this._encod = null]) {
    this._file = new File(this.file_path);
  }

  String onReadFile(String file_content) {
    if (this._function != null) {
      if (this._completer != null) {
        this._completer.complete(this._function(file_content));
      } else {
        return this._function(file_content);
      }
    }
    if (this._completer != null) {
      this._completer.complete(file_content);
    }
    return file_content;
  }

  String onReadBytesFile(List<int> content) {
    String file_content = new String.fromCharCodes(content);
    if (this._function != null) {
          if (this._completer != null) {
            this._completer.complete(this._function(file_content));
          } else {
            return this._function(file_content);
          }
        }
    if (this._completer != null) {
      this._completer.complete(file_content);
    }
    return file_content;
  }

  void _onFileError(var e) {
    print("RouteFileObject error ! [${e}]");
    this._response.statusCode = HttpStatus.NOT_FOUND;
    this._completer.complete("404 not Found");
  }

  String getFile() {
    print("RouteFileObject call [${this._file}]");
    if (this._encod != null) {
      return this.onReadFile(this._file.readAsStringSync(encoding: this._encod));
    } else {
      return this.onReadBytesFile(this._file.readAsBytesSync());
    }
  }

  Future<String> call(HttpRequest r, HttpResponse response) {
    print("RouteFileObject call [${this._file}]");
    this._completer = new Completer();
    this._response = response;
    if (this._encod != null) {
      this._file.readAsString(encoding: this._encod).then(this.onReadFile).catchError(this._onFileError);
    } else {
      print("Read as byte");
      this._file.readAsBytes().then(this.onReadBytesFile).catchError(this._onFileError);
    }
    return this._completer.future;
  }
}