express = require 'express'
child_process = require 'child_process'
config = require "config"
Twitter = require "twitter"
randomstring = require 'randomstring'
fs = require "fs"
app = express()

twtr = new Twitter config.get "twitter-sunrisegen"

# Boot up an express server to host the sunrise generator so phantom can read it
app.get '/', (req, res) ->
  res.sendFile __dirname + '/sunrise.htm'

app.listen 1234, ->
  console.log 'Sunrise generator server ready!'
  getSunrise().then (sunrise) ->
    twtr.post 'media/upload', {media: sunrise}, (error, media, response) ->
      if (error) then throw error

      post = {
        status: 'sunrise',
        media_ids: media.media_id_string
      }

      twtr.post 'statuses/update', post, (error, tweet, response) ->
        if (error) then throw error
        process.exit()


# Generate a sunrise by using phantom to take a screenshot of the hosted html
getSunrise = ->
  return new Promise (resolve, reject) ->
    name = randomstring.generate()
    child_process.exec '"./node_modules/.bin/phantomjs" sunrise_phantom.js ' + name, (error) ->
      if (error) then reject error
      sunrise = fs.readFileSync name + '.png'
      resolve sunrise
