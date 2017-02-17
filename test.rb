require 'faraday'

data = {company: {name: 'Blah'}, token: 'TurMonLook4'}
blah = Faraday.post('http://turingmonocle-staging.herokuapp.com/api/v1/companies', data)

puts blah.body
