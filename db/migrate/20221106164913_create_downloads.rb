class CreateDownloads < ActiveRecord::Migration[7.0]
  def change
    create_table :downloads do |t|
      t.belongs_to :ai_waifu
      t.timestamps
    end
  end
end
