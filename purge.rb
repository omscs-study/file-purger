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
    file_id
  end
end

def post_message(message, options = {})
  params = {
    token: @token,
    text: message,
    channel: '#admins',
    as_user: false,
    username: 'file-purger'
  }.merge(options)
  uri = URI.parse('https://slack.com/api/chat.postMessage')
  uri.query = URI.encode_www_form(params)
  Net::HTTP.get_response(uri)
end

def call
  raise 'No SLACK_TOKEN specified' unless @token
  log.info 'Deleting files...'
  post_message 'Starting file purge...'
  file_ids = list_files.map { |f| f['id'] }
  deleted_file_ids = delete_files(file_ids)
  log.info 'Done!'
  post_message "#{deleted_file_ids.length} files purged!", icon_emoji: ':smile:'
rescue => exception
  raise exception
  post_message "File purger failed: #{exception.message}", icon_emoji: ':scream:'
end

if __FILE__ == $0
  call
end
