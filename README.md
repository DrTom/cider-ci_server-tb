Cider-CI Server-TB
==================

Part of [Cider-CI](https://github.com/DrTom/cider-ci). 
This component runs in the application server under the 
[TorqueBox](http://torquebox.org/) stack.


## Developing the frontend only

It is possible to run this part of Cider-CI in development mode without
connecting it to the other Cider-CI services. It is also possible to use MRI
ruby (instead of JRuby, or the whole Torquebox stack even) in development mode. 

There will be no real interaction, e.g. creating or even running an execution.
It is therefore generally helpful to load some data into the database, e.g.
from a dump of your production server. 


## License

Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
Licensed under the terms of the GNU Affero General Public License v3.
See the LICENSE.txt file provided with this software.

