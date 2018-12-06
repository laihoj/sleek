var bodyParser 				= require("body-parser"),
	mongoose 				= require("mongoose"),
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

var login = require('./login.js');

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

var url = process.env.DATABASEURL;
mongoose.connect(url, { useNewUrlParser: true });

var domain = process.env.DOMAIN || "localhost:3000";

const db = require('./db.js');


app.get("/", function(req, res) {
	res.render("index");
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

app.post("/users", function(req,res){
	var newUser = {
		username: req.body.username
	};
	User.register(new User(newUser), req.body.password, function(err, user) {
		if(err) {
			console.log(err);
			res.redirect("/");
		} else {
			passport.authenticate("local")(req, res, function() {
				res.redirect(req.session.redirectTo || '/users/' +req.user.username);
				delete req.session.redirectTo;
			}
		)}
	});
});

app.get("/users/:user", login.isAuthenticated, async function(req,res){
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