Rails.application.routes.draw do
  namespace :wsgw do
    match "sendJob",        to: "outspoken#send_job", via: [:get, :post]
    get "checkJobStatus",   to: "outspoken#check_job_status"
  end
end
