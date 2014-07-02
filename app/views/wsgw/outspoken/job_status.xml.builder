xml.instruct!
xml.tag! "job-status-report" do
  xml.tag! "job-request-id", @job_request_id
  xml.tag! "mqube-id", "00n7dno3068i3020pnpqh4ptcpju"
  xml.tag! "recipient-count", @recipient_count
  xml.nodeid(1)
  xml.status('COMPLETE')
  xml.recipients do
    (1..@recipient_count).each do |i|
      xml.recipient do
        xml.destination(5555555555 + i)
        xml.msgid(SecureRandom.hex)
        xml.status("SENT")
      end
    end
  end
end