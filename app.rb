#!/usr/bin/ruby

require 'sinatra'
require 'json'
require 'base64'

set :bind, '0.0.0.0'
set :port, 80

get '/' do
  "Ok this has been changed"
end

post '/webhook' do
  contents = request.body.read
  my_thing = JSON.parse contents

  email = my_thing["FromFull"]["Email"]
  name = my_thing["FromFull"]["Name"]

  attachments = my_thing["Attachments"]
  attachments.each do |attachment|
    file_name = attachment['Name']
    puts file_name
    File.open("./tmp/#{file_name}", 'w') { |file| file.write(Base64.decode64(attachment['Content'])) }
  end

  # Upload the file to Watson

  image = "./tmp/#{file_name}"
  classifier = "rims.json"

  config_file = File.open(classifier).read

  config_file_json = JSON.parse config_file

  classifier_id = config_file_json["classifier_ids"].first



  api_key = ENV['WATSONKEY']

  fields_hash = {}

  response = RestClient.post "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify?api_key=#{api_key}&version=2016-05-20",
    fields_hash.merge(:images_file => File.new(image), :parameters => File.new(classifier))

  puts response.body

  json_object = JSON.parse response.body

  custom_classifier = json_object["images"].first["classifiers"].select{|classifier| classifier["classifier_id"] == classifier_id}.first

  if custom_classifier
    highest_ranked = custom_classifier["classes"].sort_by{ |o| o["score"]}.first

    puts
    puts
    puts
    puts
    puts highest_ranked["class"]

    puts
    puts
    puts
    puts
    puts
    puts
    puts
    puts

  else
    puts "I don't know what this is!"
  end




  # Create a PDF


  # Insert the iamge into a PDF


  # Email the PDF




  'ok'
end

post '/test' do
  puts request.body.read
end
