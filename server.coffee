config = require('./config')
http = require('http')
express = require('express')
app = require('express').createServer()
redis = require('redis')
client = redis.createClient()
helpers = require('./lib/helpers')
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
app.listen port, '0.0.0.0', ->
  console.log 'Listening on ' + port

genRouteDict = (route_list) ->
  dict = {}
  i = 0

  while i < route_list.length
    dict[route_list[i]['route_id']] = route_list[i]['long_name']
    i++
  dict
getBus = ->
  http.get('http://api.transloc.com/1.1/arrival-estimates.json?agencies=176&stops=4117202,4110166', (res) ->
    arrivals = []
    res.on 'data', (chunk) ->
      arrivals.push chunk.toString()

    res.on 'end', ->
      http.get 'http://api.transloc.com/1.1/routes.json?agencies=176', (res2) ->
        routes = []
        res2.on 'data', (chunk) ->
          routes.push chunk.toString()

        res2.on 'end', ->

          arrivals_json = JSON.parse(arrivals.join(''))
          routes_json = JSON.parse(routes.join(''))
          id_to_name = genRouteDict(routes_json['data']['176'])
          console.log id_to_name

          if arrivals_json['data'].length == 0
            closest = []
          else
            console.log arrivals_json['data'][0]['arrivals']
            closest = []
            now = Date.now()
            seen_buses = []
            closest = arrivals_json['data'][0]['arrivals'].map( (arrival) ->
              {
                name: id_to_name[ arrival['route_id'] ],
                arrival: arrival['arrival_at'],
                delta: helpers.prettyDelta(arrival['arrival_at'], now),
                within: helpers.within(arrival['arrival_at'], now, 10)
              }
            )

          closest.sort( (a, b) ->
            a['arrival'] > b['arrival']
          )

          coming = closest[0]['within']
          client.set(['coming', if coming then 'YES' else 'NO'], (err, reply) ->
            client.expire('coming', (config.ttl + config.ttl_offset)/1000)
          )

          console.log closest
          io.sockets.volatile.emit('message', {
            closest: closest,
            coming: if coming then 'YES' else 'NO'
          })

  ).on 'error', (e) ->
    console.log e

app.get '/', (req, res) ->
  client.get('coming', (err, reply) ->
    res.render 'index', {
      coming: reply
    }
  )

setInterval getBus, config.ttl
