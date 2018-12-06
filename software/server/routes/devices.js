var express = require("express"),
	router	= express();

var Device = require("../models/device");
const db = require('./db.js');

router.get("/", function(req,res) {
	res.locals.devices = await db.devices();
	res.render("devices");
});

module.exports = router;