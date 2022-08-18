class PostmasterWorker < ActiveJob::Base
  self.queue_adapter = :sucker_punch

  def perform(params)
    Postmaster.process_payload(params).deliver_now
  end
end
