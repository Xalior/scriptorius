var static = require('node-static');

var fileServer = new static.Server('./build');

require('http').createServer(function (request, response) {
	console.log(request.url);
    request.addListener('end', function () {
        fileServer.serve(request, response);
    }).resume();
}).listen(5555);
