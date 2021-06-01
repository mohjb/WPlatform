const express = require("express");

const app = express();
const bodyParser = require('body-parser')//const multer = require('multer') // v1.0.5//const upload = multer() // for parsing multipart/form-data

app.use(bodyParser.json()) // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })) // for parsing application/x-www-form-urlencoded

const mariadb = require('mariadb');
const pool = mariadb.createPool({host: 'localhost', user: 'm',password:'m', database:'test'
	, connectionLimit: 5, multipleStatements: true ,rowsAsArray:true});

app.Tables=[
	['usr',     ['id','name'  ,'pw'                             ,'profile','state','creaTime','lm'],'id'],
	['bank',    ['id','name'                                    ,'profile','state','creaTime','lm']],
	['currency',['id','name'                                    ,'profile','state','creaTime','lm']],
	['rate',    ['id','sell'  ,'buy'    ,'amount'               ,'profile','state','creaTime','lm']],
	['Acc',     ['id','name'  ,'uid'    ,'bankid','currencyId'  ,'profile','state','creaTime','lm'],'uid'],
	['trans',   ['id','srcAcc','dstAcc' ,'amount'               ,'profile','state','creaTime','lm'],[{col:'srcAcc',fk:{col:'uid',tbl:'acc'}},{col:'dstAcc',fk:{col:'uid',tbl:'acc'}}]],
	['msg',     ['id','uid'   ,'toUsr'  ,'type'  ,'body'        ,'profile','state','creaTime','lm'],['uid','toUsr']],
	['at',      ['id','Tid'   ,'tbl'    ,'type'  ,'body'        ,'profile','state','creaTime','lm'],[{col:'tid',fk:{tbl:'tbl'}}]],
	['cal',     ['id','uid'   ,'name'   ,'type'  ,'dt','expire' ,'profile','state','creaTime','lm'],'uid'],
	['tmplt',   ['id','parent','name'   ,'html'                 ,'profile','state','creaTime','lm']]]

app.Tables.forEach(e=>app.Tables[e[0]]=e)//console.log('established mariadb pool:',pool);

app.sessions={timeoutPeriod:1000*60*10,f:function(sid){}}

app.use(express.static('web'));

app.post('/doLogin', function (req, res) {
	console.log('express:app.post:doLogin:0',req,res);
	let b=req.body ,sns=app.sessions
		,un=b.un,pw64=b.pw
		,pw=(new Buffer(pw64, 'base64')).toString('ascii');
	console.log('express:app.post:doLogin:1',b,un,pw64,pw);
	if(un && pw ) // ,un=1,pw=1//
		pool.getConnection()
		.then(conn =>
			conn.query("SELECT * from usr where name=? and pw=md5(?)",[un,pw])
			.then(rows => { // rows: [ {val: 1}, meta: ... ]
				if(rows){let o=rows[0],ss={sid:(new Date()).getTime(),un:un,usr:{},expire:app.sessions.timeoutPeriod};
					ss.expire+=ss.sid;
					//if(o && o.state && !o.state.active) o=0;
					if(o && o.state && ! o.state.admin )
						delete o.state;
					app.Tables.usr[1].forEach((c,i)=>{if(c!='pw')ss.usr[c]=o[i];})//delete o.pw;
					app.sessions[ss.sid]=ss;
					console.log('express:app.post:doLogin:2',b,un,o);
					return res.json(ss);//conn.query("INSERT INTO myTable value (?, ?)", [1, "mariadb"]);
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

app.post(':tbl', function (req, res) {
	const str='express:post:';
	let p=req.params
		,lm=p.lm
		,m=0
		,h={}
		,tbl=app.Tables.find(e=>e[0]==p.tbl)
	if(! tbl)return res.json({error:'invalid operation:'+p.tbl});

	conn.query("replace `'+tbl[0]+'` set ``=? where `id`=?",[p.id])
		.then(rows =>
			res.json(rows)
		)
		.then(res => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }
			conn.release();
		})
		.catch(err => {//console.log(str,'3',err);
			conn.release();
		})
})


app.get('/lm/:lm', function (req, res) {
		const str='express:app.get:lm:';
		let now=new Date().getTime()
			,sid=req.getTime('sid')
			,ss=sid&&app.sessions[sid]
		if(ss&& ss.expire<now){//TODO: log to DB session time-out
			delete app.session[sid];
			return res.json({error:'session-timeout'});
		}
		if(!ss|| !ss.usr|| !ss.usr.state|| !ss.usr.state.active )
			return res.json({error:'invalid credintials'});
		let p=req.params
			,lm=p.lm,a={}
			,uid=ss.usr.id
			,admin=ss.usr.state.admin;
		ss.expire=now+app.sessions.timeoutPeriod;
		pool.getConnection().then(conn =>{
			function f(tbl,retFunc){
				function trns(tbl){
					let accs=a[app.Tables.acc[0]]
					,s='('+accs.join(',')+')'//,tbl=app.Tables.trans
					return conn.query("SELECT * from `"+tbl[0]+"` where `lm`>? and (srcAcc in "+s+" or dstAcc in "+s+") ",[lm])
				}
				let w=tbl[2],m=	(!w||admin)?conn.query("SELECT * from `'+tbl[0]+'` where lm>?",[lm])
				:typeof w=='string'?conn.query("SELECT * from `'+tbl[0]+'` where lm>? and `'+w+'`=?",[lm,uid])
				:tbl[0]=='at'?0//w.length==1 && w[0].fk?0// tbl attachment
				:!w[0].fk?conn.query("SELECT * from `'+tbl[0]+'` where lm>? and (`'+w[0+]'`=? or `'+w[1]+'`=?)",[lm,uid,uid])//tbl:msg
				:tbl[0]=='trans'?trns(tbl)
				:0 //
				;
				if(!m)
					return retFunc(m)
				m.then(rows =>
					retFunc(rows)//
				)
				.then(res => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }
					conn.release();
				})
				.catch(err => {//console.log(str,'3',err);
					conn.release();
				})
			}
			app.Tables.forEach(//TODO: fix conn/incomplete-Promises race-problem
				(tbl,i)=>
				f(tbl,
					r=>(
						(a[tbl[0]]=r) ,
						i >=app.Tables.length-1
						? res.json(a)
						: 0
					)
				)
			)
		})
	}
)

app.get('/:tbl/:id', function (req, res) {
		const str='express:app.get:tbl:';
		let now=new Date().getTime()
			,sid=req.getTime('sid')
			,ss=sid&&app.sessions[sid]
		if(ss&& ss.expire<now){//TODO: log to DB session time-out
			delete app.session[sid];
			return res.json({error:'session-timeout'});
		}
		if(!ss|| !ss.usr|| !ss.usr.state|| !ss.usr.state.active )
			return res.json({error:'invalid credintials'});
		let p=req.params
			,lm=p.lm,a={}
			,uid=ss.usr.id
			,admin=ss.usr.state.admin;
		ss.expire=now+app.sessions.timeoutPeriod;
		pool.getConnection().then(conn =>{
			function f(tbl,retFunc){
				function trns(tbl){
					let accs=a[app.Tables.acc[0]]
						,s='('+accs.join(',')+')'//,tbl=app.Tables.trans
					return conn.query("SELECT * from `"+tbl[0]+"` where `lm`>? and (srcAcc in "+s+" or dstAcc in "+s+") ",[lm])
				}
				let w=tbl[2],m=	(!w||admin)?conn.query("SELECT * from `'+tbl[0]+'` where lm>?",[lm])
					:typeof w=='string'?conn.query("SELECT * from `'+tbl[0]+'` where lm>? and `'+w+'`=?",[lm,uid])
						:tbl[0]=='at'?0//w.length==1 && w[0].fk?0// tbl attachment
							:!w[0].fk?conn.query("SELECT * from `'+tbl[0]+'` where lm>? and (`'+w[0+]'`=? or `'+w[1]+'`=?)",[lm,uid,uid])//tbl:msg
								:tbl[0]=='trans'?trns(tbl)
									:0 //
				;
				if(!m)
					return retFunc(m)
				m.then(rows =>
					retFunc(rows)//
				)
					.then(res => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }
						conn.release();
					})
					.catch(err => {//console.log(str,'3',err);
						conn.release();
					})
			}
			app.Tables.forEach(//TODO: fix conn/incomplete-Promises race-problem
				(tbl,i)=>
					f(tbl,
						r=>(
							(a[tbl[0]]=r) ,
								i >=app.Tables.length-1
									? res.json(a)
									: 0
						)
					)
			)
		})
	}
)

const PORT=80;
app.listen(PORT, () => {
	console.log("Server is listening on port: ",PORT);
});

