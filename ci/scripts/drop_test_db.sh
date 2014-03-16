load_rbenv \
&& rbenv shell $RUBY_VERSION \
&& rake db:drop
