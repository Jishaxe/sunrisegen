var system = require('system');
var args = system.args;

var page = require('webpage').create();
page.open('http://localhost:1234/', function() {
  page.render(args[1] + '.png');
  phantom.exit();
});
