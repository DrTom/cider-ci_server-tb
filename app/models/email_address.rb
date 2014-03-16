#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class EmailAddress < ActiveRecord::Base
  self.primary_key= 'email_address'
  belongs_to :user

  before_save {self.email_address= email_address.downcase}

  # NOTE searchable is a workaround: the pg parser recognizes emails and does
  # not break them apart: foo@bar.baz will only be found when the full email
  # address is searched for (and not by "foo", or "bar", or baz).
  # http://www.postgresql.org/docs/current/static/textsearch-parsers.html
  after_save do
    update_columns searchable: email_address.gsub(/[^\w]/,' ')
  end

end
