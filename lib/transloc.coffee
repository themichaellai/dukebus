_ = require('underscore')
http = require('http')
helpers = require('./helpers')
transloc = module.exports

transloc.getRouteNames = (callback) ->
  http.get 'http://api.transloc.com/1.1/routes.json?agencies=176', (res) ->
    data = []
    res.on 'data', (chunk) ->
      data.push chunk.toString()
    res.on 'end', ->
      json = JSON.parse(data.join(''))
      id_to_name = {}
      _.each(json['data']['176'], (route, i, routes) ->
        id_to_name[route['route_id']] = route['long_name']
      )

      callback(id_to_name)

transloc.getStopNames = (callback) ->
  http.get 'http://api.transloc.com/1.1/stops.json?agencies=176', (res) ->
    data = []
    res.on 'data', (chunk) ->
      data.push chunk.toString()
    res.on 'end', ->
      json = JSON.parse(data.join(''))
      id_to_name = {}
      _.each(json['data'], (stop, i, stops) ->
        id_to_name[stop['stop_id']] = stop['name']
      )

      callback(id_to_name)

transloc.getTimeData = (stop_id_to_name, route_id_to_name, callback) ->
  http.get 'http://api.transloc.com/1.1/arrival-estimates.json?agencies=176', (res) ->
    data = []
    res.on 'data', (chunk) ->
      data.push chunk.toString()
    res.on 'end', ->
      json = JSON.parse(data.join(''))

      if json['data'].length == 0
        stops = []
      else
        named_stops = {}
        #named_stops = []
        now = Date.now()
        _.each(json['data'], (stop, i, stops) ->
          # exchange route_id with route_name for all arrivals
          named_arrivals = []
          if stop['arrivals'].length > 0
            _.each(stop['arrivals'], (arrival, i, arrivals) ->
              named_arrivals.push {
                'route_name': route_id_to_name[arrival['route_id']],
                'route_id': arrival['route_id'],
                'arrival_at': arrival['arrival_at']
              }
            )

            # push arrivals and stop_name onto list of stops
            named_stops[stop['stop_id']] = {
              'arrivals': named_arrivals,
              'stop_name': stop_id_to_name[stop['stop_id']],
              'stop_id': stop['stop_id']
            }
        )
      callback(named_stops)
