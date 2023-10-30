# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:episodes) do
      primary_key :id
      foreign_key :show_id, :shows

      String :description
      String :origin_id, unique: true
      Array :images
      String :language
      String :name
      String :release_date
      String :type

      DateTime :created_at
      DateTime :updated_at
    end
  end
end