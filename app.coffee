express = require('express')
# env = process.env.NODE_ENV
app = express()
open = require('open')
app.use express.static 'public'
app.set 'views',__dirname+'/views/'
app.set 'view engine','jade'
app.get '*',(req,res)->
  return res.status(204).end() if req.url is '/favicon.ico'
  _file = req.url.replace(/^\//,'').split('/')[0]
  _path = if _file then _file else 'index'
  res.render _file,{title:'test'}
_port = 9100
app.listen _port
open 'http://localhost:'+_port
# console.log env