class CreatePhoneVerifications < ActiveRecord::Migration
  def change
    create_table :phone_verifications do |t|
      t.string :phone_number, null: false
      t.string :verification_token, null: false
      t.datetime :verified_at
      t.datetime :expired_at
      t.datetime :unlocked_at
      t.string :login_attempts, array: true, default: []
      t.integer :user_id

      t.timestamps null: false
    end

    add_foreign_key :phone_verifications, :users
    add_index :phone_verifications, :phone_number, unique: true
    add_index :phone_verifications, :verification_token
    add_index :phone_verifications, :user_id, unique: true
  end
end
