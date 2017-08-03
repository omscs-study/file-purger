#!/usr/bin/env ruby
require 'json'
require 'logger'
require 'net/http'
require 'uri'

@token   = ENV['SLACK_TOKEN']
@days    = ENV.fetch('DAYS_TO_KEEP', 10).to_i
@admin   = ENV['ADMIN_CHANNEL']
@general = ENV['GENERAL_CHANNEL']

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
  return unless options[:channel]
  params = {
    token: @token,
    text: message,
    channel: options[:channel],
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
  file_ids = list_files.map { |f| f['id'] }
  deleted_file_ids = delete_files(file_ids)
  log.info 'Done!'
  post_message "Deleted #{deleted_file_ids.length} files _(shared more than #{@days} days ago)_", channel: @general, icon_emoji: ':smile:' if deleted_file_ids.length > 0
  post_message "_NOTE: I can't delete_ *private* _files. Please make sure you delete your private files for the benefit of the whole group. Thanks!_"
rescue => exception
  post_message "File purger failed: #{exception.message}", channel: @admin, icon_emoji: ':scream:'
  raise exception
end

if __FILE__ == $0
  call
end
