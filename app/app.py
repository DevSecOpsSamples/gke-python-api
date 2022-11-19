from flask import Flask
from flask import request
from flask import json
from werkzeug.exceptions import HTTPException

app = Flask(__name__)

@app.route("/")
def ping_root():
    return ping()

@app.route("/<string:path1>")
def ping_path1(path1):
    return ping()

def ping():
    return {
        "host": request.host,
        "url": request.url,
        "method": request.method,
        "message": "ping-api"
    }

@app.errorhandler(HTTPException)
def handle_exception(e):
    response = e.get_response()
    response.data = json.dumps({
        "code": e.code,
        "name": e.name,
        "description": e.description,
    })
    response.content_type = "application/json"
    return response

if __name__ == '__main__':
    app.debug = True
    app.run(host='0.0.0.0', port=8000)
