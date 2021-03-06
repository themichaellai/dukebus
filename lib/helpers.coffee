helpers = module.exports

helpers.prettyDelta = (time_str, now) ->
  time = new Date(time_str)
  seconds = (time - now) / 1000
  minutes = (seconds / 60).toFixed(1)
  if (minutes >= 1)
    return minutes + ' minutes'
  else
    return '< 1 minutes'

helpers.within = (time_stamp, now, diff_expected = 10) ->
  arrival_time = new Date(time_stamp)
  Math.abs(arrival_time - now) < (diff_expected * 60 * 1000)

helpers.genRouteDict = (route_list) ->
  dict = {}
  i = 0

  while i < route_list.length
    dict[route_list[i]['route_id']] = route_list[i]['long_name']
    i++
  dict
