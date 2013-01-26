http = require('http')
app = require('express').createServer()
redis = require('redis')
client = redis.createClient()
io = require('socket.io').listen(app,
  log: false
)
io.configure ->
  io.set 'transports', ['xhr-polling']
  io.set 'polling duration', 10

app.set 'view engine', 'ejs'
app.set 'views', __dirname + '/views'
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
  #io.sockets.volatile.emit('message', {
  #  data: res
  #});
  http.get('http://api.transloc.com/1.1/arrival-estimates.json?agencies=176&stops=4117202,4098146', (res) ->
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
            for arrival in arrivals_json['data'][0]['arrivals']
              arrival_time = new Date(arrival['arrival_at'])
              now = new Date()
              if Math.abs(arrival_time - now) < (10 * 60 * 1000)
                #name = id_to_name[ arrival['route_id'] ]
                #bus = {}
                #bus[name] = arrival['arrival_at']
                closest.push {
                  name: id_to_name[ arrival['route_id'] ],
                  arrival: arrival['arrival_at']
                }

          console.log closest
          io.sockets.volatile.emit('message', {
            closest: closest
          })



  ).on 'error', (e) ->
    console.log e

app.get '/', (req, res) ->
  res.render 'index'

setInterval getBus, 10000