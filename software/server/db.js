/********************************************************
Mongoose.js and MongoDB
********************************************************/
const mongoose = require('mongoose')

var url = process.env.DATABASEURL;
mongoose.connect(url, { useNewUrlParser: true });

const Device = require("./models/device");

exports.devices = async function() {
	return Device.find({}).exec();
}

exports.device = async function(address) {
	return Device.find({address: address}).exec();
}

exports.users = async function() {
	return User.find({}).exec();
}

exports.user = async function(name) {
	return User.find({username: name}).exec();
}