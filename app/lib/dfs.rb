#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

# Traverses a nested hash/array/some_value structure in DFS
# manner and returns the (potentially) modified structure
class DFS

  # callable1 is invoked on singular values
  # callable2 is invoked on a key/value pair,  
  #   it must return an array of exactly two elements 
  # either can be nil which defaults to the identity function
  def initialize callable1, callable2
    @callable1 = callable1 or lambda{|s| s}
    @callable2 = callable2 or lambda{|k,v| [k,v]}
  end


  def traverse d
    case 
    when d.is_a?(Array)
      handle_array d
    when d.is_a?(Hash)
      handle_hash d
    else
      res = @callable1.call(d)
      if res != d # has been processed and so we recurse 
        traverse(res)
      else
        res
      end
    end
  end

  def handle_array a
    a.map{|x| traverse(x)}
  end

  def handle_hash h
    Hash[h.map do |k,v| 
      res = @callable2.call(k,v)
      [res[0], traverse(res[1])]
    end]
  end

end
