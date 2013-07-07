class JobQueue
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key      , type: Symbol  , default: nil
  field :uid                      , default: nil
  field :job      , type: Hash    , default: nil
  field :group    , type: Symbol  , default: nil

  index({key: 1, uid: 1}, { unique: true, sparse: true })

  def self.enqueue(key, uid, job, group=nil)
    entry = JobQueue.where(group: group, key: key, uid: uid).first_or_create
    JobQueue.update_attributes job: job
    entry
  end

  def self.any?(group)
    entry = JobQueue.where(group: group).limit(1).first
  end

  def self.dequeue(key)
    entry = peek(key)
    return nil unless entry
    entry.delete
    entry.job
  end

  def self.peek(key)
    entry = JobQueue.where(key: key).asc(:created_at).limit(1).first
    return nil if entry.nil?
    entry.job
  end
end