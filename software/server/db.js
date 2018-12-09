/********************************************************
Mongoose.js and MongoDB
********************************************************/
const mongoose = require('mongoose')

var url = process.env.DATABASEURL;
mongoose.connect(url, { useNewUrlParser: true });

const User = require("./models/user");
const Device = require("./models/device");


exports.devices = async function() {
	return Device.find({}).exec();
}

// exports.getDeviceByAddress = async function(address) {
// 	return Device.find({address: address}).exec();
// }

exports.getDevicesByUser = async function(user) {
	return Device.find({user: user}).exec();
}

// exports.getDeviceByAddress = async function(device_address) {
// 	return Device.find({device_address: device_address}).exec();
// }

exports.saveDevice = async function(device_address, device_uuid, device_name, device_user) {
	var device = new Device({
		address: device_address,
		uuid: device_uuid,
		name: device_name,
		user: device_user
	});
 	return device.save();
}

exports.saveUser = async function(username, password) {
	const newUser = new User({username:username});
	await newUser.setPassword(password);
	return newUser.save();
}

// exports.users = async function() {
// 	return User.find({}).exec();
// }

// exports.user = async function(name) {
// 	return User.find({username: name}).exec();
// }