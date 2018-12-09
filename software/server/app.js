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
	let datapoints = await db.datapoints();
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

app.post("/api/devices", async function(req,res) {
	let device = await db.saveDevice(
		req.body.device_address, 
		req.body.device_UUID, 
		req.body.device_name, 
		req.body.device_user);
	res.send(device);
});

app.get("/api/devices/:username", async function(req,res) {
	let devices = await db.getDevicesByUser(req.params.username);
	res.send(devices);
});

app.get("/api", function(req, res) {
	res.render("api");
});

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