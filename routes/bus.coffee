bus = module.exports
redis = require('redis').createClient()

bus.index = (req, res) ->
  res.render 'index', {
  }

bus.stop = (req, res) ->
  redis.get('stop:'+req.params.id, (err, val) ->
    res.send(val)
  )

bus.stop_data = (req, res) ->
  redis.get('stop_data', (err, val) ->
    res.send(val)
  )
