var express = require('express');
var app = express();
var fs = require('fs');
var https = require('https');
//var io = require("socket.io")(2112);
var port = process.env.PORT || 5000;

console.log("QUQUQUQU!");

var options = {
    key: fs.readFileSync('./file.pem'),
    cert: fs.readFileSync('./file.crt')
  };

var server = https.createServer(options, app);
var io = require('socket.io')(server);

//app.use(express.static(__dirname + '/'));
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
  });

app.use(express.static(__dirname + '/'));
  

server.listen(port, function() {
    console.log("Server is running on https://localhost:" + port);
});


io.on('connection', function(socket) {
    socket.on("connect-client-son", function() {
        console.log("New client-son: " + socket.id);
    });
    socket.on("connect-client-speech", function() {
        console.log("New client-speech: " + socket.id);
    });
    socket.on("disconnect", () => {
        console.log("Disconnected: " + socket.id);
    });
    socket.on('presence',
        function(data) {
            if (data >= 10) {
                io.emit('dark-mode', 0);
                console.log("dark-modeis off" + " presence: " + data);
            } else {
                io.emit('dark-mode', 1);
                console.log("dark-modeis on" + " presence: " + data);
            }
            
        }
    );
    socket.on("reset-bg", function() {
        io.emit('reset-bg');
        console.log("resetbg");
    });
    /*
    socket.on('chat message', function(msg) {
        io.emit('chat message', msg);
    });
    
    socket.on('mouse',
        function(data) {
            io.emit('mouses', data);
        }
    );
     */

});