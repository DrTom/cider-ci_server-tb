export RAILS_ENV=test
export DISPLAY=":$DOMINA_TRIAL_INT"
export PGPIDNAME=pid 
mkdir tmp/html
load_rbenv 
rbenv shell $RUBY_VERSION
