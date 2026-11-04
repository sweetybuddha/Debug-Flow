from backend.app import app

class StripPrefixMiddleware:
    def __init__(self, wsgi_app):
        self.app = wsgi_app

    def __call__(self, environ, start_response):
        path_info = environ.get("PATH_INFO", "")
        if path_info.startswith("/api/analyzer-service"):
            environ["PATH_INFO"] = path_info[len("/api/analyzer-service"):] or "/"
        elif path_info.startswith("/api/analyzer.py"):
            environ["PATH_INFO"] = path_info[len("/api/analyzer.py"):] or "/"
        return self.app(environ, start_response)

app.wsgi_app = StripPrefixMiddleware(app.wsgi_app)
