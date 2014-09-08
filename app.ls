require! <[ express cors ./routes/api ]>
port = process.env.PORT || 3000
app = express!


app.use cors!
app.use '/v1', api


app.listen port, -> console.log "Server Listen on #{port}"