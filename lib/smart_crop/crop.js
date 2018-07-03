/*
var request = require('request');
var gm = require('gm').subClass({imageMagick: true});

function applySmartCrop(src, dest, width, height) {
  request(src, {encoding: null}, function process(error, response, body){
    if (error) return console.error(error);
    smartcrop.crop(body, {width: width, height: height}).then(function(result) {
      var crop = result.topCrop;
      gm(body)
        .crop(crop.width, crop.height, crop.x, crop.y)
        .resize(width, height)
        .write(dest, function(error){
            if (error) return console.error(error);
        });
    });
  });
}

function applySmartCropToFile(src, dest, width, height) {
    smartcrop.crop(src, {width: width, height: height}).then(function(result) {
      var crop = result.topCrop;
      console.log(crop.x, crop.y);
      gm(src)
        .crop(crop.width, crop.height, crop.x, crop.y)
        .resize(width, height)
        .write(dest, function(error){
            if (error) return console.error(error);
         });
    });
}
// applySmartCropToFile(args[0], args[1], 237, 224)
*/

var smartcrop = require('smartcrop-gm');
function findCropCoordsFromFile(src, width, height) {
    smartcrop.crop(src, {width: width, height: height}).then(function(result) {
      var crop = result.topCrop;
      console.log(crop.x, crop.y);
    });
}

// var src = 'https://raw.githubusercontent.com/jwagner/smartcrop-gm/master/test/flower.jpg';
// applySmartCrop(src, 'flower-square.jpg', 128, 128);
var args = process.argv.slice(2); 
if (args.length < 3) {
  console.log("Need src file, x-size, y-size");
  process.exit(1);
}
findCropCoordsFromFile(args[0], args[1], args[2])
