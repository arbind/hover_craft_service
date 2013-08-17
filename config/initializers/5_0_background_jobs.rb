# launch background threads or not
ENV["LAUNCH_BACKGROUND_JOBS"] ||= (!ENV["IN_SERVER"].nil?).to_s
if ["", "no", "0", "false"].include? ENV["LAUNCH_BACKGROUND_JOBS"].downcase
  ENV.delete("LAUNCH_BACKGROUND_JOBS")
end

if ENV["LAUNCH_BACKGROUND_JOBS"]
  # wait to launch threads (seconds)
  ENV["STARTUP_DELAY_OF_BACKGROUND_THREADS"] ||= "4" # in seconds
end

PopulateFromStreamers.schedule {}