class CreateWelcomePageSettings < ActiveRecord::Migration
  def change

    create_table :welcome_page_settings, id: false do |t|
      t.integer :id

      t.text :welcome_message
      t.text :radiator_config

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute "ALTER TABLE welcome_page_settings ADD PRIMARY KEY (id)"
        execute "ALTER TABLE welcome_page_settings ADD CONSTRAINT one_and_only_one CHECK (id = 0)"
      end
    end

  end

end
