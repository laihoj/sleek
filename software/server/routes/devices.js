var express = require("express"),
	router	= express();

var Device = require("../models/device");
const db = require('../db.js');
router.set('views', __dirname + '/views/');
router.get("/", async function(req,res) {
	let devices = await db.devices();
	if(devices) {
		res.locals.devices = devices;
	}
	res.render("devices");
});

module.exports = router;