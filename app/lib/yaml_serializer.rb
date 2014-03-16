#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

module YamlSerializer
  class << self

    def load(data)
      Psych.load(data) rescue {}
    end

    def dump(data)
      Psych.dump(data)
    end

    def uuid_hash(data)
      uuid_ns = UUIDTools::UUID_URL_NAMESPACE
      UUIDTools::UUID.sha1_create(uuid_ns, dump(data)).to_s
    end

  end
end
