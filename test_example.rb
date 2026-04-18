require 'json'
require './voiceit3.rb'
vi = voiceit3.new(ENV['VOICEIT_API_KEY'], ENV['VOICEIT_API_TOKEN'])
phrase = "Never forget tomorrow is a new day"
td = "test-data"
errors = 0

def check(step, json_str, errors_ref)
  r = JSON.parse(json_str)
  code = r['responseCode'] || '?'
  if code == 'SUCC'
    puts "PASS: #{step} (#{code})"
  else
    puts "FAIL: #{step} (#{code})"
    errors_ref[0] += 1
  end
  r
end

err = [0]
r = check("CreateUser", vi.createUser, err)
user_id = r['userId']

(1..3).each do |i|
  check("VideoEnrollment#{i}", vi.createVideoEnrollment(user_id, "en-US", phrase, "#{td}/videoEnrollmentA#{i}.mov"), err)
end

r = check("VideoVerification", vi.videoVerification(user_id, "en-US", phrase, "#{td}/videoVerificationA1.mov"), err)
puts "  Voice: #{r['voiceConfidence']}, Face: #{r['faceConfidence']}"

check("DeleteEnrollments", vi.deleteAllEnrollments(user_id), err)
check("DeleteUser", vi.deleteUser(user_id), err)

abort("\n#{err[0]} FAILURES") if err[0] > 0
puts "\nAll tests passed!"
