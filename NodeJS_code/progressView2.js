var mysql = require('mysql');

var connection = mysql.createConnection({
	host: 'localhost',
	user: 'root',
	password: 'root',
	database: 'konapp'
});

connection.connect();

function getSkills(success) {
	connection.query("call SkillHierarchy(9);", function(err, result) {
		var skills = result[0];
		success(skills);
	});

};


const http = require('http');

http.createServer((req, res) => {

	if(req.url.match('^/skills$')) {
		getSkills((skills) => {
			res.writeHead(200);
			res.end(JSON.stringify(skills))
		});
	} else {
		res.writeHead(404);
		res.end();
	}

}).listen(8080);