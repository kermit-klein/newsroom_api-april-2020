class AddInternationalToArticle < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :international, :boolean, default: true
  end
end
