#!/usr/bin/env ruby
require 'json'
require 'logger'
require 'net/http'
require 'uri'

@token = ENV['SLACK_TOKEN']
@days  = 10

def log
  Logger.new(STDOUT)
end

def list_files
  params = {
    token: @token,
    ts_to: (Time.now - @days * 24 * 60 * 60).to_i,
    count: 1000
  }
  uri = URI.parse('https://slack.com/api/files.list')
  uri.query = URI.encode_www_form(params)
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)['files']
end

def delete_files(file_ids)
  file_ids.each do |file_id|
    params = {
      token: @token,
      file: file_id
    }
    uri = URI.parse('https://slack.com/api/files.delete')
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    log.info "#{file_id}: #{JSON.parse(response.body)['ok']}"
  end
end

if __FILE__ == $0
  raise "No SLACK_TOKEN specified" unless @token
  log.info 'Deleting files...'
  files = list_files
  file_ids = files.map { |f| f['id'] }
  delete_files(file_ids)
  log.info 'Done!'
end
