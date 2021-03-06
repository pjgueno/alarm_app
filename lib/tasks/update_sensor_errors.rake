require 'uri'
require 'yajl/http_stream'
namespace :update do
  desc "update sensor errors"
  task sensor_errors: :environment do
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE #no good idea, but working
    url = URI.parse("https://feinstaub.rexfue.de/api/getprobdata")
    answer = Net::HTTP.get_response(url)
    if answer.code == "200"
      results = JSON.parse(answer.body).values.last
      OwnSensor.update_all(problem: nil)
    end
    results.each do |hash|
      extern_id = hash["_id"]
      problem = hash["problemTxt"]
      sensor = OwnSensor.find_by(extern_db_id: extern_id)
      sensor.update_attributes(problem: problem) unless sensor.blank?
    end
  end
end