Cider-CI Server-TB
==================

Part of [Cider-CI](https://github.com/DrTom/cider-ci). 
This component runs in the application server under the 
[TorqueBox](http://torquebox.org/) stack.


## Simple setup for hacking on the Frontend

caveats:
- you'll need a db dump from a real production instance
- it doesn't do anything besides showing the UI

1. edit config/database.yml 

2. run this:
    ````sh
    PORT=3333
    DUMP="cider_ci_production_dump.pgbin"
    bundle
    rake db:create db:migrate
    export RAILS_RELATIVE_URL_ROOT='/ci'
    pg_restore --disable-triggers  -O -x -d cider_ci_dev "$DUMP"
    sleep 3 && open http://localhost:$PORT/ci &
    rails s -p $PORT
    ````


## License

Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
Licensed under the terms of the GNU Affero General Public License v3.
See the LICENSE.txt file provided with this software.

