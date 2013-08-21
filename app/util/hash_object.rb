class HashObject < Hash
  def initialize(hash)
    super
    merge! hash if hash
  end

  def method_missing(m, *args, &block)
    k = m.to_s
    return self[k] if has_key?(k)
    k = m.to_sym
    return self[k] if has_key?(k)
    nil
  end
end