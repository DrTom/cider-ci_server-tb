class CreateExecutors < ActiveRecord::Migration
  def up

    create_table :executors, id: :uuid do |t|

      t.string :name
      t.index :name, unique: true

      t.string :host, null: false
      t.integer :port, null: false, default: 8443
      t.boolean :ssl, null: false, default: true

      t.boolean :server_overwrite, default: false
      t.boolean :server_ssl, default: true
      t.string :server_host, default: '192.168.0.1'
      t.integer :server_port, default: '8080'

      t.integer :max_load, default: 4, null: false
      t.boolean :enabled, default: true, null: false

      t.string :app
      t.string :app_version

      t.string :traits, array: true
      t.index :traits 

      t.timestamp :last_ping_at
      t.timestamps
    end

  end

  def down
    drop_table :executors
  end
end
