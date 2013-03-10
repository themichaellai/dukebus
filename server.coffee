config = require('./config')
_ = require('underscore')
http = require('http')
express = require('express')
app = require('express').createServer()
redis = require('redis').createClient()
helpers = require('./lib/helpers')
transloc = require('./lib/transloc')
bus = require('./routes/bus')
io = require('socket.io').listen(app,
  log: false
)
io.configure ->
  io.set 'transports', ['xhr-polling']
  io.set 'polling duration', 10

app.set 'view engine', 'ejs'
app.set 'views', __dirname + '/views'
app.use express.static(__dirname + '/public')
port = process.env.PORT or 3000


route_id_to_name = {}
stop_id_to_name = {}
stop_data = {}

getBus = ->
  transloc.getTimeData(stop_id_to_name, route_id_to_name, (stops) ->
    console.log stops
    redis.set( ['stop_data', JSON.stringify(stops)], (err, reply) ->
      if (err)
        console.log err
    )

    io.sockets.volatile.emit('bus data', {
      stops: stops,
    })
  )


app.get '/', bus.index
app.get '/stop/:id?', bus.stop
app.get '/stop_data', bus.stop_data

# Get route and stop names before starting
console.log 'mapping route names'
transloc.getRouteNames (route_id_to_name_in) ->
  route_id_to_name = route_id_to_name_in
  console.log 'mapping stop names'
  transloc.getStopNames (stop_id_to_name_in) ->
    stop_id_to_name = stop_id_to_name_in

    # store stop names for retrieval
    _.each(Object.keys(stop_id_to_name), (stop_id) ->
      redis.set( ['stop:'+stop_id, stop_id_to_name[stop_id]], (err, reply) ->
        if (err)
          console.log err
      )
    )

    app.listen port, '0.0.0.0', ->
      console.log 'Listening on ' + port

    setInterval getBus, config.ttl
