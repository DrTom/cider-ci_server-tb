class CreateServerSettings < ActiveRecord::Migration
  def up
    create_table :server_settings, id: false  do |t|
      t.integer :id

      t.boolean :server_ssl, default: false
      t.string :server_host, default: 'localhost'
      t.integer :server_port, default: 8080
      
      t.string :ui_context, default: '/cider-ci-dev'
      t.string :api_context, default: '/cider-ci-api'

      t.string "repositories_path", null: false, default: '/git/repositories'

    end
    execute "ALTER TABLE server_settings ADD PRIMARY KEY (id)"
    execute "ALTER TABLE server_settings ADD CONSTRAINT one_and_only_one CHECK (id = 0)"
  end

  def down
    drop_table :server_settings
  end


end
