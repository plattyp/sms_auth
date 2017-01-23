class CreateAuthenticationTokens < ActiveRecord::Migration
  def change
    create_table :authentication_tokens do |t|
      t.string :body
      t.integer :user_id
      t.datetime :expired_at
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_foreign_key :authentication_tokens, :users
    add_index :authentication_tokens, :user_id
    add_index :authentication_tokens, :body, unique: true
  end
end
