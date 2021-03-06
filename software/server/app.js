var bodyParser 				= require("body-parser"),
	express 				= require("express"),
	request					= require("request"),
	flash					= require("connect-flash"),
	passport 				= require("passport"),
	LocalStrategy 			= require("passport-local"),
	passportLocalMongoose 	= require("passport-local-mongoose"),
	methodOverride			= require("method-override"),
	app						= express();

var User = require("./models/user");
var Device = require("./models/device");

var auth = require('./auth.js');

app.use(require("express-session")({
	secret: process.env.SECRET || "salaisuus",
	resave: false,
	saveUninitialized: false
}));

app.use(passport.initialize());
app.use(passport.session());
app.set("view engine", "ejs");
app.set('views', __dirname + '/views/');
app.use(express.static("public"));
app.use(bodyParser.urlencoded({extended:true}));
app.use(methodOverride("_method"));
app.use(flash());

app.use(function(req, res, next){
	res.locals.currentUser = req.user;
	res.locals.error = req.flash("error");
	res.locals.success = req.flash("success");
	res.header("Access-Control-Allow-Origin", "*");
  	res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
	next();
});

passport.use(new LocalStrategy(User.authenticate()));
passport.serializeUser(User.serializeUser());
passport.deserializeUser(User.deserializeUser());

var domain = process.env.DOMAIN || "localhost:3000";

const db = require('./db.js');


app.get("/", function(req, res) {
	res.render("index");
});

app.get("/api/datapoints", async function(req, res) {
	let datapoints;
	if(req.query.start && req.query.end) {
		datapoints = await db.datapointsInTimeSpan(req.query.start, req.query.end);
	} else if(req.query.start) {
		datapoints = await db.datapointsInTimeSpan(req.query.start, Date.now());
	} else if(req.query.end) {
		datapoints = await db.datapointsInTimeSpan(0, req.query.end);
	} else {
		datapoints = await db.datapoints();
	}
	
	res.send(datapoints);
});

app.post("/api/datapoints", async function(req, res) {
	let datapoint = await db.saveDatapoint(
		req.body.device_address,
		req.body.timestamp, 
		req.body.data);
	res.send(datapoint);
});

app.get("/api/devices", async function(req,res) {
	let devices = await db.devices();
	res.send(devices);
});

app.get("/api/devices/user/:user", async function(req,res) {
	let devices = await db.getDevicesByUser(req.params.user);
	res.send(devices);
});

app.get("/api/devices/address/:address", async function(req,res) {
	let devices = await db.getDeviceByAddress(req.params.address);
	res.send(devices);
});

app.post("/api/devices", async function(req,res) {
	let device = await db.saveDevice(
		req.body.device_label, 
		req.body.device_address, 
		req.body.device_UUID, 
		req.body.device_name, 
		req.body.device_user);
	res.send(device);
});

app.post("/api/gestures", async function(req,res) {
	let gesture = await db.saveGesture(
		req.body.start_timestamp, 
		req.body.end_timestamp, 
		req.body.label, 
		req.body.user);
	res.send(gesture);
});

// app.get("/api/gestures", async function(req,res) {
// 	let gestures = await db.gestures();
// 	res.send(gestures);
// });

// app.get("/api/gestures/label/:label", async function(req,res) {
// 	let gestures = await db.getGesturesByLabel(req.params.label);
// 	res.send(gestures);
// });

app.get("/api/gestures", async function(req, res) {
	let gestures;
	if(req.query.label) {
		gestures = await db.getGesturesByLabel(req.query.label);
	} else {
		gestures = await db.gestures();
	}
	res.send(gestures);
});

app.get("/api/devices/:username", async function(req,res) {
	let devices = await db.getDevicesByUser(req.params.username);
	res.send(devices);
});

app.get("/api", function(req, res) {
	res.render("api");
});

//makes different query per supplied query parameters
app.get("/datapoints", async function(req, res) {
	let datapoints;
	if(req.query.start && req.query.end) {
		datapoints = await db.datapointsInTimeSpan(req.query.start, req.query.end);
	} else if(req.query.start) {
		datapoints = await db.datapointsInTimeSpan(req.query.start, Date.now());
	} else if(req.query.end) {
		datapoints = await db.datapointsInTimeSpan(0, req.query.end);
	}
	res.render("datapoints", {datapoints: datapoints});
});

//recent means in the latest 15 seconds
app.get("/datapoints/recent", async function(req, res) {
	const now = Date.now();	//TODO: consider time zone stuff
	let firstDatapoint;
	let lastDatapoint;
	let datapoints = await db.datapointsInTimeSpan(now - 15 * 1000, now);
	if(datapoints.length > 0) {
		firstDatapoint = datapoints[0].timestamp.getTime();
		lastDatapoint = datapoints[datapoints.length - 1].timestamp.getTime();
	}
	res.render("datapointsrecent", {datapoints: datapoints, start_timestamp:firstDatapoint, end_timestamp:lastDatapoint});
});

// app.get("/datapoints/recent", async function(req, res) {
// 	res.redirect("/datapoints/recent/seconds/15")
// });
// app.get("/datapoints/recent/seconds/:seconds", async function(req, res) {
// 	const now = Date.now();	//TODO: consider time zone stuff
// 	const seconds = req.params.seconds;
// 	let datapoints;
// 	if(seconds) {
// 		datapoints = await db.datapoints(now - seconds * 60, now); 
// 	}
// 	res.render("datapointsrecent", {datapoints: datapoints});
// });

app.get("/devices", function(req,res) {
	res.render("devices");
});

app.post("/devices", async function(req,res) {
	let device = await db.saveDevice(
		req.body.device_address, 
		req.body.device_UUID, 
		req.body.device_name, 
		req.body.device_user);
	//todo? error handling
	res.redirect("/devices");
});

app.post("/users", async function(req,res){
	let user = await db.saveUser(req.body.username, req.body.password);
	if(user) {
		passport.authenticate("local")(req, res, function() {
			res.redirect(req.session.redirectTo || '/users/' +req.user.username);
			delete req.session.redirectTo;
		});
	} else {
		res.redirect("/");
	}
});

app.get("/users/:user", auth.isAuthenticated, async function(req,res){
	let devices = await db.getDevicesByUser(req.user.username);
	if(devices) {
		res.locals.devices = devices;
	}
	res.render("profile");
});

app.post("/login", passport.authenticate("local", {failureRedirect: "/login", failureFlash: true}), function(req, res) {
	if(!req.user) {
		req.flash("error", "Issue signing up");
		res.redirect("/login");
	} else {
		req.flash("success", "Logged in");
		res.redirect(req.session.redirectTo || '/users/' +req.user.username);
		delete req.session.redirectTo;
	}
});

app.get("/login", function(req, res) {
	res.render('login');
});

app.get("/register", function(req, res) {
	res.render('register');
});

app.get("/logout",function(req, res){
	req.logout();
	req.flash("success", "Logged out");
	res.redirect("/");
});

app.listen(process.env.PORT || 3000, function() {
	console.log("Sleek");
});