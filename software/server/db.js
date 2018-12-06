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

exports.saveDevice = async function(device_address, device_uuid, device_name, device_user) {
	var device = new Device({
		address: device_address,
		uuid: device_uuid,
		name: device_name,
		user: device_user
	});
 	return device.save();
}

exports.users = async function() {
	return User.find({}).exec();
}

exports.user = async function(name) {
	return User.find({username: name}).exec();
}