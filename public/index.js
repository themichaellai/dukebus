var socket = io.connect(window.location.hostname);
var messagesList = $('tbody');

socket.on('message', function (data) {
  $('tr').remove();
  now = Date.now();
  $('h1').text(data.coming);
  for (var i = 0; i < data.closest.length; i++) {
    messagesList.append('<tr><td>' + data.closest[i].name + '</td><td>' + data.closest[i].delta + '</td></tr></li>');
  }
});
