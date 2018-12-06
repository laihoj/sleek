
//didnt work
function connectToBTDeviceByUUID(uuid) {
  let options = {
    filters: [
      {services: ['74278BDA-B644-4520-8F0C-720EAF059935']}, //default uuid fo hc13
      {name: 'Sleek0001'}
    ]
  }

  navigator.bluetooth.requestDevice(options).then(function(device) {
    console.log('Name: ' + device.name);
    // Do something with the device.
  })
}


//does work
navigator.bluetooth.requestDevice({filters: [{name:'HMSoft'}]}).then(function(device) {
    console.log('Name: ' + device.name);
    // Do something with the device.
  })