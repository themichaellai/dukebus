var socket = io.connect(window.location.hostname);

socket.on('message', function (data) {
  var messagesList = $('tbody');
  messagesList.find('tr').remove();
  now = Date.now();
  $('h1').text(data.coming);
  console.log(data.closest);
  for (var i = 0; i < data.closest.length; i++) {
    messagesList.append('<tr><td>' + data.closest[i].name + '</td><td>' + data.closest[i].delta + '</td></tr></li>');
  }
});
