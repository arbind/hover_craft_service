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
    entry.update_attributes job: job
    entry
  end

  def self.any_jobs_for_group?(group)
    !!peek_at_group(group)
  end

  def self.any?(key)
    !!peek(key)
  end

  def self.dequeue(key)
    entry = peek(key)
    return nil unless entry
    entry.delete
    entry
  end

  def self.dequeue_from_group(group)
    entry = peek_at_group(group)
    return nil unless entry
    entry.delete
    entry
  end

  def self.peek(key)
    JobQueue.where(key: key).asc(:created_at).limit(1).first
  end

  def self.peek_at_group(group)
    JobQueue.where(group: group).asc(:created_at).limit(1).first
  end

  def job
    HashObject.new self[:job]
  end
end