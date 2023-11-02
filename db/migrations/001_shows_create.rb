# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:shows) do
      primary_key :id
      String :description
      String :origin_id, unique: true
      Array :images
      String :name
      String :publisher
      String :type
      # Hash :episodes

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
