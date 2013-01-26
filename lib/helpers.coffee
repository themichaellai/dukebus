helpers = module.exports

helpers.prettyDelta = (time_str, now) ->
  time = new Date(time_str)
  seconds = (time - now) / 1000
  minutes = (seconds / 60).toFixed(1)
  console.log 'min: ' + minutes + ' seconds: ' + seconds
  if (minutes >= 1)
    return minutes + ' minutes'
  else
    return '< 1 minutes'
