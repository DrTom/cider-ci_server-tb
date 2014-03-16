class ActiveRecord::Base
  def self.collection_cache_tag &block
    if block_given?
      block.call(self)
    else
      self
    end.instance_eval {
      order(updated_at: :desc).limit(1) \
      .select("to_char(#{table_name}.updated_at,'YYYY-MM-DDThh:mm:ss.msTZ') as x").first.try(:[],:x)
    } or Time.zone.now.iso8601(4)
  end
end
