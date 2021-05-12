const express = require("express");

const app = express();
const mariadb = require('mariadb');
const pool = mariadb.createPool({host: 'localhost', user: 'm',password:'m', database:'test', connectionLimit: 5});

console.log('established mariadb pool:',pool);

app.use(express.static('web'))

function showtables(){
	let o={starttime:new Date()}
	console.log('function showtables:1',o)
	pool.getConnection()
		.then(conn =>
			conn.query("show tables")
				.then(rows => { // rows: [ {val: 1}, meta: ... ]
					o.time=new Date()
					o.rows=rows
					console.log('function showtables:2',o, o&&o.meta)
				})
				.then(res => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }
					//console.log('function showtables:3',o)
					conn.release(); // release to pool
				})
				.catch(err => {
					console.log('function showtables:4',o,err)
					conn.release(); // release to pool
				})
		).catch(err => {
		//not connected
		console.log('function showtables:5',o,err)
	});
	console.log('function showtables:end',o)
}

showtables()

app.post('/doLogin/', function (req, res) {
	let b=req.body,un=b.un,pw64=b.pw
		,pw=(new Buffer(pw64, 'base64')).toString('ascii');
	console.log('express:app.post:doLogin:1',b,un,pw64,pw);
	if(un && pw )
	pool.getConnection()
		.then(conn => {

			conn.query("SELECT * from user where name=? and pw=md5(?)",un,pw)
				.then(rows => { // rows: [ {val: 1}, meta: ... ]
					if(rows){let o=rows[0];
					if(o && o.state && !o.state.active)
						o=0;
					if(o && o.state && ! o.state.admin )
						delete o.state;
					console.log('express:app.post:doLogin:2',b,un,o);
					return res.json(o)
					//conn.query("INSERT INTO myTable value (?, ?)", [1, "mariadb"]);
				}})
				.then(res => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }
					conn.release(); // release to pool
				})
				.catch(err => {
					console.log('express:app.post:doLogin:3',err);
					conn.release(); // release to pool
				})

		}).catch(err => {
		//not connected
	});
	console.log('express:app.post:doLogin:4');
})


app.get('/test/', function (req, res) {
	let o={b:req.body,d0:new Date()}//,un=b.un,pw64=b.pw,pw=(new Buffer(pw64, 'base64')).toString('ascii');
	console.log('express:app.get:test:',o);
	return res.json(o)
})

app.get('/showtables/:p', function (req, res) {
	let o={b:req.params,d0:new Date()}//,un=b.un,pw64=b.pw,pw=(new Buffer(pw64, 'base64')).toString('ascii');
	//if(un && pw )
	console.log('express.get:showtables:',o);
	pool.getConnection()
	.then(conn =>
		conn.query("show tables")
		.then(rows => { // rows: [ {val: 1}, meta: ... ]
			o.d1=new Date()
			o.rows=rows
			return res.json(o)
				//conn.query("INSERT INTO myTable value (?, ?)", [1, "mariadb"]);
		})
		.then(res => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }
			conn.release(); // release to pool
		})
		.catch(err => {
			conn.release(); // release to pool
		})
	).catch(err => {
	//not connected
	});
})

app.listen(1234, () => {
	console.log("Server is listening on port: 1234");
});


