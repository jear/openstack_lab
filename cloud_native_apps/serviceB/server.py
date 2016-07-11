#! /usr/bin/python
# -*- coding:utf-8 -*-

from flask import Flask
app = Flask(__name__)

# This route is supposed to lauch the game
# There is few step in this demo that the handler of this route will do :
# 1. Run the game which is supposed to be slow on an external service (HTTP request)
# 2. Change the status of the player in our internal database by querying (HTTP) serviceS
# 3. Generate the corresponding image (thanks to the response of the HTTP gaming request)
# 4. Send an message using rabbitMQ on a service that will listen to this queue for the purpose of notifying the user by mail.
@app.route('/play')
def index():
    return "This is supposed to play."

if __name__ == '__main__':
    app.run(debug=True)
