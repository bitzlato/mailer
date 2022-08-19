class PostmasterWorker < ActiveJob::Base
  self.queue_adapter = :sucker_punch

  def perform(params)
    params = JSON.parse(params.to_json, object_class: OpenStruct)
    Postmaster.process_payload(params).deliver_now
  end
end
