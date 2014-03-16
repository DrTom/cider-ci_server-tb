#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.


$ -> 

  split= (val)-> val.split /,\s*/ 
  extractLast= (term)-> split(term).pop()

  $("input[data-autocomplete-path]").toArray().map((e)->$(e)).forEach ($input)->

    $input.bind "keydown", (event) -> 
      if event.keyCode == $.ui.keyCode.TAB and $input.data("ui-autocomplete").menu.active
        event.preventDefault()

    $input.autocomplete
      minlength: 0
      delay: 200
      source: (request,response) ->
        $.getJSON( $input.attr("data-autocomplete-path"), { term: extractLast(request.term) }, response )
      search: -> extractLast @value 
      focus: -> false         
      select: (event,ui) ->
        terms = split @value 
        terms.pop();
        terms.push( ui.item.value );
        @value = terms.join( ", " )
        false 
