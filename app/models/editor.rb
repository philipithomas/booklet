# == Schema Information
#
# Table name: editors
#
#  id                 :bigint           not null, primary key
#  email              :string
#  encrypted_password :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Editor < ApplicationRecord
  devise :database_authenticatable, :timeoutable
end
