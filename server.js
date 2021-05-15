const express = require("express");

const app = express();
const bodyParser = require('body-parser')
//const multer = require('multer') // v1.0.5
//const upload = multer() // for parsing multipart/form-data

app.use(bodyParser.json()) // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })) // for parsing application/x-www-form-urlencoded
app.tblNms=['usr','bank']
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

app.post('/doLogin', function (req, res) {
	console.log('express:app.post:doLogin:0',req,res);
	let b=req.body  ,un=b.un,pw64=b.pw,pw=(new Buffer(pw64, 'base64')).toString('ascii');console.log('express:app.post:doLogin:1',b,un,pw64,pw);
	if(un && pw ) // ,un=1,pw=1//
	pool.getConnection()
		.then(conn =>
			conn.query("SELECT * from usr where name=? and pw=md5(?)",[un,pw])
				.then(rows => { // rows: [ {val: 1}, meta: ... ]
					if(rows){let o=rows[0];
					if(o && o.state && !o.state.active)
						o=0;
					if(o && o.state && ! o.state.admin )
						delete o.state;
					delete o.pw;
					console.log('express:app.post:doLogin:2',b,un,o);
					return res.json(o);//conn.query("INSERT INTO myTable value (?, ?)", [1, "mariadb"]);
				}})
				.then(res => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }
					conn.release(); // release to pool
				})
				.catch(err => {
					console.log('express:app.post:doLogin:3',err);
					conn.release(); // release to pool
				})
		).catch(err => {
		console.log('express:app.post:doLogin:4:not connected');//not connected
	});
	console.log('express:app.post:doLogin:5');
})


app.get('/test/', function (req, res) {
	let o={b:req.body,d0:new Date()}//,un=b.un,pw64=b.pw,pw=(new Buffer(pw64, 'base64')).toString('ascii');
	console.log('express:app.get:test:',o);
	return res.json(o)
})


app.get('/list/:tbl/:mostRecent', function (req, res) {
//	'id','parent','Name','html','profile','state','createdAt','updatedAt'
	const str='express:configList:';
	let plm=req.params.mostRecent,m=0,h={}
	conn.query("SELECT * from config where updatedAt>?",[plm])
	.then(rows =>
		res.json(rows)
	)
	.then(res => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }
		conn.release();
	})
	.catch(err => {//console.log(str,'3',err);
		conn.release();
	})
	/*todo:
	* get db-lm,
	* check if app has been initialized
	*
	*
	pool.getConnection().then(conn =>
		conn.query("SELECT max(updatedAt) as lm from config ")
		.then(rows => rows[0].lm )
		.then(r1 => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }
			let dblm=r1[0].lm,

			return ct;
		})
		.catch(err => {//console.log(str,'3',err);
			conn.release();
		})
	).catch(err => {
		console.log(str,'4:not connected');
	})
	.then(dblm=> {
		if (!ct || lm < ct.lm) {
			let q = [0], t = ct || {}, c = {0: t}, o = {d0: new Date(), tree: app.configTree}
			while (q) {
				let id = q.shift(), p = c[id];
				f(id, p || t)
			}
		}
		console.log(str, '5');
		return o;
	})*/
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


