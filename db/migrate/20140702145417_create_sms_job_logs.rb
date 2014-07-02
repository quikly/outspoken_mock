class CreateSmsJobLogs < ActiveRecord::Migration
  def change
    create_table :sms_job_logs do |t|
      t.string        :job_request_id
      t.float         :duration
      t.integer       :status_code
      t.integer       :num_destinations
      t.text          :job_xml
      t.timestamps
    end

    add_index :sms_job_logs, :job_request_id
  end
end
