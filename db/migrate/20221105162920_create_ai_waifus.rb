class CreateAiWaifus < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_waifus do |t|
      t.string :name
      t.timestamps
    end
  end
end
