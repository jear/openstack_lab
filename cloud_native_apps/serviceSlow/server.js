'use strict';

const express = require('express');
var app       = express();
const server  = require('http').Server(app);

app.set('port', process.env.PORT | 8080);

server.listen(app.get('port'), (err) => {
  if (err) throw err;
  console.log('server listening on port: ' + app.get('port'));
});
