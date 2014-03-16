class CreateRepositories < ActiveRecord::Migration
  def up 
    enable_extension 'uuid-ossp'

    execute %[
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
         NEW.updated_at = now(); 
         RETURN NEW;
      END;
      $$ language 'plpgsql';
    ]

    create_table :repositories, id: :uuid do |t|

      t.string :origin_uri

      t.string :name
      t.index :name, unique: true

      t.integer :importance, default: 0, null: false

      t.integer :git_fetch_and_update_interval, default: 60

      t.integer :git_update_interval, default: nil

      t.uuid :transient_properties_id, default: 'uuid_generate_v4()'

      t.timestamps
      t.index :created_at

    end

  end

  def down
    drop_table :repositories
    execute %[ DROP FUNCTION IF EXISTS update_updated_at_column() ]
  end

end
