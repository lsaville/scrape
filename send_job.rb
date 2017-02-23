require 'bunny'
require 'json'

connection = Bunny.new(
  :host => 'experiments.turing.io',
  :port => '5672',
  :user => 'student',
  :pass => 'PLDa{g7t4Fy@47H'
)

connection.start
channel = connection.create_channel
queue = channel.queue('scrapers.to.lookingfor')

job = {
  title: 'Fake',
  company: 'Great Company',
  company_url: 'example.com',
  description: 'fantastic'
}

queue.publish(job.to_json)
