#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

module CiderCI
  module Cache
    class << self

      if defined? TorqueBox

        def cache
          @cache ||= \
            TorqueBox::Infinispan::Cache.new(
              name: 'cider-ci', 
              encoding: :edn,
              locking_mode: :optimistic,
              transaction_mode: :non_transactional)
        end

        def get key
          cache.get key 
        end

      else

        def get key
          nil
        end

      end

    end
  end
end
