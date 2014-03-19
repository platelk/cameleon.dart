part of restlib;

typedef String FileCallBack(String fileContent);

class RouteFileObject {
  String file_path;
  File _file;
  Encoding _encod;
  var _completer;
  FileCallBack _function = null;
  HttpResponse _response;

  RouteFileObject(this.file_path, [this._function, this._encod = ASCII]) {
    this._file = new File(this.file_path);
  }

  String onReadFile(String file_content) {
    if (this._function != null) {
      this._completer.complete(this._function(file_content));
    }
    this._completer.complete(file_content);
    return file_content;
  }

  void _onFileError(var e) {
    this._response.statusCode = HttpStatus.NOT_FOUND;
    this._completer.complete("404 not Found");
  }

  Future<String> call(Iterable<Match> l, HttpRequest r, HttpResponse response) {
    this._completer = new Completer();
    this._response = response;
    this._file.readAsString(encoding: this._encod).then(this.onReadFile).catchError(this._onFileError);
    return this._completer.future;
  }
}