require 'bunny'
require 'pry'
require 'faraday'
require 'json'

connection = Bunny.new(
  :host => 'monocle.turing.io',
  :port => '5672',
  :user => 'monocle',
  :pass => 'RzoCoV7GR2wGAb'
)

connection.start

channel = connection.create_channel

jobs_for_lookingfor_queue = channel.queue('scrapers.to.lookingfor')

jobs_for_lookingfor_queue.subscribe do |delivery_info, metadata, payload|
	response = JSON.parse(payload)
	puts response
end

loop do
end
