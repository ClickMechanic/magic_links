class CreateMagicLinksMagicTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :magic_links_magic_tokens do |t|
      t.string :token, null: false
      t.string :target_path, null: false
      t.json :action_scope, null: false
      t.datetime :expires_at
      t.references :magic_token_authenticatable, polymorphic: true, index: {name: 'index_magic_tokens_on_magic_token_authenticatable'}

      t.timestamps
    end

    add_index :magic_links_magic_tokens, :token, unique: true
  end
end
