class CreateLikedAiWaifus < ActiveRecord::Migration[7.0]
  def change
    create_table :liked_ai_waifus do |t|
      t.belongs_to :ai_waifu
      t.timestamps
    end
  end
end
