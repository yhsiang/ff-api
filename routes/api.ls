{ Router } = require 'express'

require! <[ request cheerio ]>

Api = Router!

origin = 'http://www.hearttaipei.tw'
host = process.env.HOST || 'http://localhost:3000'

Api.route '/'
  .get (req, res) ->
    res.json do
      is-success: false
      error-code: 404
      error-message: "no API found,for more detail,please reference to our docs. ( #{host}/docs/ )",
      data: null

Api.route '/category'
  .get (req, res) ->
    error, response, body <- request "#{origin}"
    res.json do
      is-success: true
      error-code: 0
      error-message: null
      data: parseMenu body

Api.route '/category/:id'
  .get (req, res) ->
    {page} = req.query
    id = req.param 'id'
    error, response, body <- request "#{origin}/?cat=#{id}&paged=#{page}"
    items = parseLists body
    res.json do
      is-success: true
      error-code: 0
      error-message: null
      data: items
      page-info:
        #total-pages: pages
        results-per-page: items.length

Api.route '/article'
  .get (req, res) ->
    {page = 1} = req.query
    error, response, body <- request "#{origin}/?paged=#{page}"
    items = parseLists body
    res.json do
      is-success: true
      error-code: 0
      error-message: null
      data: items
      page-info:
        results-per-page: items.length

Api.route '/article/:id'
  .get (req, res) ->
    id = req.param 'id'
    error, response, body <- request "#{origin}/?p=#{id}"
    res.json do
      is-success: true
      error-code: 0
      error-message: null
      data: parseArticle body

parseMenu = (body) ->
  $ = cheerio.load body

  items = $ 'a', '.nav--main__wrapper' .map (,it) ->
    link = $ it .attr 'href'
    if link.match /http.+\?cat=\d+$/
      do
        id: ~~link.split '?cat=' .1
        name: $ it .text!
  items.to-array!

parseLists = (body) ->

  $ = cheerio.load body

  items = $ 'article.post' .map (,it) ->
    do
      link: $ '.article--grid__header', it .children!attr 'href'
      title: $ '.article__title', it .text!trim!
      thumbnail: $ '.article--grid__thumb > .image-wrap > img', it .data 'src'
      content: $ '.article__content', it .text!trim!
      createdAt: $ '.xpost_date', it .text!
      comments: ~~$ '.xpost_comments', it .text!
      likes: ~~$ '.xpost_likes', it .text!
  items .= to-array!

parseArticle = (body) ->
  $ = cheerio.load body
  it = $ 'article.post-article' .0
  do
    link: $ 'link[rel="canonical"]' .attr 'href'
    title: $ '.article__title', it .text!trim!
    featured: $ '.article__featured-image > .image-wrap > img', it .data 'src'
    content: $ 'p', it .get!map -> $ it .text!trim!
    createdAt: $ '.article__time', it .text!
    likes: ~~$ '.likes-count', it .text!
    category: $ '.btn--tertiary' .get!map -> ~~$ it .attr 'href' .replace /http.*cat=/, ''

module.exports = Api
