class SmsJobLog < ActiveRecord::Base
  STATUS_MESSAGES = {
    0 => 'Job Accepted',
    2 => 'invalid parameter value',
    3 => 'XML Parsing Error',
    4 => 'Duplicate Job ID',
    5 => 'Job processing error, look to max-retries for retry policy',
    6 => 'Node not accepting, look to max-retries for retry policy'
  }

  def status_details
    STATUS_MESSAGES[status_code]
  end
end
