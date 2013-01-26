var socket = io.connect(window.location.hostname);
var messagesList = $('ul.buses');

socket.on('message', function (data) {
  $('li').remove();
  now = Date.now();
  for (var i = 0; i < data.closest.length; i++) {
    messagesList.append('<li>' + data.closest[i].name + ' ' + data.closest[i].delta + '</li>');
  }
});
