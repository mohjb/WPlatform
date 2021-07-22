const express = require("express");

const app = express();
const bodyParser = require('body-parser')//const multer = require('multer') // v1.0.5//const upload = multer() // for parsing multipart/form-data

app.use(bodyParser.json()) // for parsing application/json
app.use(bodyParser.urlencoded({ extended: true })) // for parsing application/x-www-form-urlencoded

const mariadb = require('mariadb');
const pool = mariadb.createPool({host: 'localhost', user: 'm',password:'m', database:'test'
	, connectionLimit: 5, multipleStatements: true ,rowsAsArray:true });

app.Tables=[// array of tables, each table is an array:: item0:tableName , item1:arrayof colName , item2: forgein-key/ ownership columns
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

app.Tables.forEach(e=>(app.Tables[e[0]]=e)[1].forEach((c,i,a)=>a[c]=i))//console.log('established mariadb pool:',pool);

app.sessions={timeoutPeriod:1000*60*10}//,f:function(sid){}

app.use(express.static('web'));

app.post('/doLogin', function (req, res) {
	console.log('express:app.post:doLogin:0',req,res);
	let b=req.body ,sns=app.sessions
		,un=b.un,pw64=b.pw
		,pw=(new Buffer(pw64, 'base64')).toString('ascii');
	console.log('express:app.post:doLogin:1',b,un,pw64,pw);
	if(un && pw ) pool.getConnection().then(conn =>
			conn.query("SELECT * from usr where name=? and pw=md5(?)",[un,pw])
			.then(rows => { // rows: [ {val: 1}, meta: ... ]
				if(rows){let dbUsr=rows[0]
					,ss={sid:(new Date()).getTime(),un:un,usr:{},expire:app.sessions.timeoutPeriod};
					ss.expire+=ss.sid;//if(dbUsr && dbUsr.state && !dbUsr.state.active) dbUsr=0;
					if(dbUsr && dbUsr.state && ! dbUsr.state.admin )
						delete dbUsr.state;
					app.Tables.usr[1].forEach((c,i)=>{if(c!='pw')ss.usr[c]=dbUsr[i];})//delete dbUsr.pw;
					app.sessions[ss.sid]=ss; console.log('express:app.post:doLogin:2',b,un,dbUsr);
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

app.post(':tbl/:id', function (req, res) {
	const str='express:post:',Mode={AdminOrOwner:1,AdminOnly:2,OnlyCreate:3}
	,TblMode={usr		: Mode.AdminOrOwner //2cases: case1:newUser by admin ; case2: same user edit
		, bank		:Mode.AdminOnly
		, currency	:Mode.AdminOnly
		, rate		:Mode.AdminOnly
		, Acc		:Mode.AdminOrOwner
		, trans		:Mode.OnlyCreate
		, msg		:Mode.AdminOrOwner
		, at		:Mode.AdminOrOwner
		, cal		:Mode.AdminOrOwner
		, tmplt		:Mode.AdminOnly
	};
	let lm=new Date().getTime()
		,p=req.params
		,tbl=app.Tables[p.tbl]
		,sid=req.get('sid')
		,ss=sid&&app.sessions[sid]
	if(! tbl)
		return res.json({error:'invalid operation:'+p.tbl});
	if(ss&& ss.expire<now){//TODO: log to DB session time-out
		if(app&&app.session&& app.session[sid])
			delete app.session[sid];
		return res.json({error:'session-timeout'});
	}
	if(!ss|| !ss.usr|| !ss.usr.state|| !ss.usr.state.active )
		return res.json({error:'invalid credintials'});
	let uid=ss.usr.id,admin=ss.usr.state.admin;//try{lm=(new Date(+lm)).toISOString()}catch (x){console.warn(x);}
	ss.expire=now+app.sessions.timeoutPeriod;
	let cols=[],cv=[],vals=req.body.vals||0,v,ok=admin; //tbl[1].forEach(c=>(v=vals[c])!=undefined?(cols.push("`"+c+"`=?"),cv.push(v)):0);
	if(cv.length){cv.push(p.id)
		pool.getConnection().then(conn => {
			let authMode=TblMode[tbl[0]] //,authCase=tbl && (tbl!=app.Tables.trans || 0 ) && ! ! admin
				,m//	,checkOwner=! admin && authMode==Mode.AdminOrOwner
			//Authorization-cases:
			//  AdminOrOwner: case 1:admin ;else; case2: check-owner ;else; no-go
			// ,AdminOnly	: case 1:admin ;else; no-go
			// ,OnlyCreate	: case 1:admin ;else; case2: check-owner both srcAcc & dstAcc ;else; no-go

			//check db cases: OnlyCreate ;xor; checkOwner cases:
			// case 1:if [usr Acc msg at cal].includes(tbl)
			if (!admin ){

				function trns(w){const a=app.Tables.Acc,au=a[1][a[1].uid];
					conn.query("SELECT count(*) from `"+a[0]+"` where  `"+au+"`=? and id=?)",[uid,vals.srcAcc])//tbl:msg
				}

				let w=tbl[2]
				m=	!w&&authMode!=Mode.AdminOnly?((ok=1),0)
				:typeof w=="string"?conn.query("SELECT * from `"+tbl[0]+"` where `"+w+"`=?",[uid])
				:tbl==app.Tables.at?0//w.length==1 && w[0].fk?0// tbl attachment
				:!w[0].fk?conn.query("SELECT * from `"+tbl[0]+"` where lm>? and (`"+w[0]+"`=? or `"+w[1]+"`=?)",[lm,uid,uid])//tbl:msg
				:tbl==app.Tables.trans?trns(tbl)
				:0
				;
			}else if(admin && authMode==Mode.OnlyCreate)
				id=null
			tbl[1].forEach(c=>(v=vals[c])!=undefined?(cols.push("`"+c+"`=?"),cv.push(v)):0);

			function f(r){if( r&&r .length)
				conn.query("replace `" + tbl[0] + "` set " + cols.join(',') + " where `id`=?", cv)
				.then(rows =>
					res.json({result: rows})
				)else
				res.json({error:'!ok'})
			}

			if(m)
				m.then(r=>f(r))
			else
				f(ok&&[1])

		}).catch(err => {//console.log(str,'3',err);
			res.json({err: err})//conn.release();
		})
		.finally(res => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }
			conn.release();
		})
	}
})

app.get('/lm/:lm', function (req, res) {
	const str='express:app.get:lm:';
	let now=new Date().getTime()
		,sid=req.get('sid')
		,ss=sid&&app.sessions[sid]
	if(ss&& ss.expire<now){//TODO: log to DB session time-out
		if(app&&app.session&& app.session[sid])
			delete app.session[sid];
		return res.json({error:'session-timeout'});
	}
	if(!ss|| !ss.usr|| !ss.usr.state|| !ss.usr.state.active )
		return res.json({error:'invalid credintials'});
	let lm=req.params.lm
		,uid=ss.usr.id,a={}
		,admin=ss.usr.state.admin;
	try{lm=(new Date(+lm)).toISOString()}catch (x){
		console.warn(x);
	}
	ss.expire=now+app.sessions.timeoutPeriod;
	pool.getConnection().then(conn =>{

		function f(tbl,retFunc){
			function trns(tbl){
				let accs=a[app.Tables.acc[0]]
				,s='('+accs.join(',')+')'//,tbl=app.Tables.trans
				return conn.query("SELECT * from `"+tbl[0]+"` where `lm`>? and (srcAcc in "+s+" or dstAcc in "+s+") ",[lm])
			}
			let w=tbl[2],m=	(!w||admin)?conn.query("SELECT * from `"+tbl[0]+"` where lm>?",[lm])
			:typeof w=="string"?conn.query("SELECT * from `"+tbl[0]+"` where lm>? and `"+w+"`=?",[lm,uid])
			:tbl[0]=="at"?0//w.length==1 && w[0].fk?0// tbl attachment
			:!w[0].fk?conn.query("SELECT * from `"+tbl[0]+"` where lm>? and (`"+w[0]+"`=? or `"+w[1]+"`=?)",[lm,uid,uid])//tbl:msg
			:tbl[0]=='trans'?trns(tbl)
			:0 //
			;
			if(!m)
				return retFunc(m)
			m.then(rows =>
				retFunc(rows)//
			)//.then(res => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }//conn.release();})
			.catch(err => {//console.log(str,'3',err);
				conn.release();
			})
		}

		function filtrCols(tbl,rows){
			const Dates=['dt','expire', 'creaTime','lm' ]
			let cols=[]
			Dates.forEach(c=>{
				let i=tbl[1].indexOf(c)
				if(i>=0)cols.push(i)})
			rows.forEach(r=>cols.forEach(ci=>{
				let v=r[ci];
				r[ci]=v?(v.getTime?v:new Date(v)).getTime():v;}
			))
			if(app.Tables.usr[0]!=tbl[0])return rows;
			rows.forEach(i=>(i.splice(2,1),i))
			return rows;
		} // function filtrCols

		app.Tables.forEach(//TODO: fix conn/incomplete-Promises race-problem
			(tbl,i)=>
			f(tbl,
				r=>(
					(a[tbl[0]]=filtrCols(tbl,r)) ,
					i >=app.Tables.length-1
					? res.json(a)
					: 0
				)
			)
		)
	}).then(res => { // res: { affectedRows: 1, insertId: 1, warningStatus: 0 }
		conn.release();
	})
})

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
	console.log(`Server is listening on port: ${PORT} ,v202106141711`);
});
