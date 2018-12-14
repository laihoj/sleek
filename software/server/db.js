/********************************************************
Mongoose.js and MongoDB
********************************************************/
const mongoose = require('mongoose')

var url = process.env.DATABASEURL;
mongoose.connect(url, { useNewUrlParser: true });

const User = require("./models/user");
const Device = require("./models/device");
const Datapoint = require("./models/datapoint");
const Gesture = require("./models/gesture");


exports.datapoints = async function(latest_N) {
	if(arguments.length == 0) {
		return Datapoint.find({}).exec();
	}
	//not used anywhere?
	if(arguments.length == 1) {
		return Datapoint.find({})
						.skip(db.collection.count() - N)
						.exec();
	}
}


exports.datapointsInTimeSpan = async function(start, end) {
	return Datapoint.find({
		timestamp:{$gt: start, $lt: end}}).exec();
}

exports.saveDatapoint = async function(device_address, timestamp, data) {
	var datapoint = new Datapoint({
		device_address: device_address,
		timestamp: timestamp,
		data: data
	});
 	return datapoint.save();
}

exports.devices = async function() {
	return Device.find({}).exec();
}

exports.gestures = async function() {
	return Gesture.find({}).exec();
}

exports.getGesturesByLabel = async function(label) {
	return Gesture.find({label: label}).exec();
}

exports.getDeviceByAddress = async function(address) {
	return Device.findOne({address: address}).exec();
}

exports.getDevicesByUser = async function(user) {
	return Device.find({user: user}).exec();
}

// exports.getDeviceByAddress = async function(device_address) {
// 	return Device.find({device_address: device_address}).exec();
// }

exports.saveDevice = async function(device_label, device_address, device_uuid, device_name, device_user) {
	var device = new Device({
		label: device_label,
		address: device_address,
		uuid: device_uuid,
		name: device_name,
		user: device_user
	});
 	return device.save();
}

exports.saveGesture = async function(start_timestamp, end_timestamp, label, user) {
	var gesture = new Gesture({
		start_timestamp: start_timestamp,
		end_timestamp: end_timestamp,
		label: label,
		user: user
	});
 	return gesture.save();
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