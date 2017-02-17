require 'faraday'
require 'nokogiri'
require 'json'
require 'pry'
require 'bunny'
require './setup-capybara'

class Scraper
  def initialize
    @queue = create_queue
  end

  def create_queue
    connection = Bunny.new(
      :host => 'experiments.turing.io',
      :port => '5672',
      :user => 'student',
      :pass => 'PLDa{g7t4Fy@47H'
    )

    connection.start
    channel = connection.create_channel
    channel.queque('scrapers.to.lookingfor')
  end

  def self.scrape
    scraper = Scraper.new
    scraper.scrape_and_publish_jobs_to_queue(0)
  end

  def scrape_and_publish_jobs_to_queue(page_index)
    job_urls = job_urls_from_specific_page(page_index)

    job_urls.each do |url|
      job = scrape_job_page(url)
      @queue.publish(job)
    end
  end

  #def job_urls_from_jobs_front_page
  #  front_page = Faraday.get('http://www.builtincolorado.com/jobs#/jobs')
  #  parsed_page = Nokogiri::HTML(front_page.body)
  #  links = parsed_page.css('.job-title a').map { |link| link['href'] }
  #end

  def job_urls_from_specific_page(page_index)
    url = "http://www.builtincolorado.com/jobs#/jobs"
    page = Faraday.get url, { :page => page_index}
    parsed_page = Nokogiri::HTML(page.body)
    links = parsed_page.css('.job-title a').map { |link| link['href'] }
  end

  def job_urls_through_all_pages
    all_job_urls = []
    37.times do |i|
      all_job_urls << job_urls_from_specific_page(i)
      puts "one page down, #{37 - i} to go"
    end
    all_job_urls.flatten!
    puts all_job_urls
  end

  def scrape_job_page(link)
    url = "http://www.builtincolorado.com/#{link}"
    page = Faraday.get(url)
    parsed_page = Nokogiri::HTML(page.body)
    job = {
      title: parsed_page.css('.nj-job-title').text.strip,
      company: parsed_page.css('.nc-fallback-title').text.strip,
      company_url: parsed_page.css('.nj-company-website a')[0]['href'],
      description: parsed_page.css('.nj-job-body').to_html,
      builtin_url: url,
    }
    job.to_json
  end
end

Scraper.scrape
