part of cameleon;

typedef String FileCallBack(String fileContent);

/**
 * [RouteFileObject] is a create by a call to [Sdhs.addFileRoute]
 */
class RouteFileObject {
  static Map<String, String> _mimeTypeMap = {
                                             "html": "text/html",
                                             "js": "application/javascript",
                                             "css": "text/css",
                                             "dart": "application/dart"
                                             };
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
    this._response.statusCode = HttpStatus.NOT_FOUND;
    this._completer.complete("404 not Found");
  }

  static String getFileContent(String file_path, {Encoding encod: null}) {
    return new RouteFileObject(file_path, null, encod).getFile();
  }

  /**
   * Return all the file in string format.
   */
  String getFile() {
    if (this._encod != null) {
      return this.onReadFile(this._file.readAsStringSync(encoding: this._encod));
    } else {
      return this.onReadBytesFile(this._file.readAsBytesSync());
    }
  }

  String getMimeType() {
    List<String> l = this.file_path.split(".");

    if (_mimeTypeMap.containsKey(l.last)) {
      return _mimeTypeMap[l.last];
    } else {
      return "text/plain";
    }
  }

  Future<String> call(HttpRequest r, HttpResponse response) {
    this._completer = new Completer();
    this._response = response;
    response.headers.set(HttpHeaders.CONTENT_TYPE, this.getMimeType());
    if (this._encod != null) {
      this._file.readAsString(encoding: this._encod).then(this.onReadFile).catchError(this._onFileError);
    } else {
      this._file.readAsBytes().then(this.onReadBytesFile).catchError(this._onFileError);
    }
    return this._completer.future;
  }
}