class Wsgw::OutspokenController < ApplicationController
  require "rexml/document"
  skip_before_filter :verify_authenticity_token

  def send_job
    job_xml = ''

    t = Benchmark.realtime do
      job_xml = parse_xml_request(params[:JobXML])
      @job_request_id = job_xml.root.elements["job-request-id"].try(:text) or raise Outspoken::MissingJobRequestId
      @num_destinations = (job_xml.root.elements["recipient-count"].try(:text) || 1).to_i
      # Block process for given delay or for random seconds between 0.5 and 2.5
      response_delay = params[:delay] =~ /^\d{1,2}$/ ? params[:delay].to_i : (rand(20) + 5).to_f / 10
      sleep(response_delay) if response_delay > 0
    end

    status_code = (params[:random_failure] && rand(params[:random_failure].to_i) < 1) ? [2,3,5,6].sample : 0

    puts "Processing Job #{@job_request_id}" if @job_request_id

    if @sms_job_log = SmsJobLog.where(job_request_id: @job_request_id).order('created_at DESC').first
      # If job already exists, return this error code
      @sms_job_log.status_code = 4
    else
      @sms_job_log = SmsJobLog.create(job_request_id: @job_request_id, duration: t, status_code: status_code, num_destinations: @num_destinations, job_xml: job_xml.to_s)
    end

    render :template => 'wsgw/outspoken/job_status.txt.erb', :layout => false
  end

  def check_job_status
    @job_request_id = params[:JobRequestID] or raise Outspoken::MissingJobRequestId
    @sms_job_log = SmsJobLog.where(job_request_id: @job_request_id).order('created_at DESC').first
    if @sms_job_log
      render :template => 'wsgw/outspoken/job_status.txt.erb', :layout => false
    else
      render :text => 'INVALID'
    end
  end

  private

  def parse_xml_request(request)
    begin
      doc = REXML::Document.new request
      root = doc.root
    rescue => e
      logger.info e.inspect
      raise Outspoken::XMLError
    end
    logger.info root.inspect
    root
  end
end
