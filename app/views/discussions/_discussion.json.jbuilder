json.extract! discussion, :id, :name, :description, :issue_id, :user_id, :created_at, :updated_at
json.url discussion_url(discussion, format: :json)