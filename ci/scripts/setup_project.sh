load_rbenv \
&& rbenv shell $RUBY_VERSION \
&& ci/bin/create_db_config_file.rb \
&& rake db:reset db:seed
