# == Schema Information
#
# Table name: ckeditor_assets
#
#  id                :integer          not null, primary key
#  data_file_name    :string(255)      not null
#  data_content_type :string(255)
#  data_file_size    :integer
#  assetable_id      :integer
#  assetable_type    :string(30)
#  type              :string(30)
#  width             :integer
#  height            :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  idx_ckeditor_assetable       (assetable_type,assetable_id)
#  idx_ckeditor_assetable_type  (assetable_type,type,assetable_id)
#

class Ckeditor::AttachmentFile < Ckeditor::Asset
  has_attached_file :data,
                    #:url => "/ckeditor_assets/attachments/:id/:filename",
                    #:path => ":rails_root/public/ckeditor_assets/attachments/:id/:filename",
                    storage: Settings.ckeditor_assets.storage,
                    fog_credentials: "#{Rails.root}/config/fog.yml",
                    fog_directory: (Settings.fog.directory rescue nil),
                    fog_host: (Settings.fog.host rescue nil),
                    path: Settings.fog.ck_attachment_path,
                    url: Settings.fog.ck_attachment_path

  validates_attachment_presence :data
  validates_attachment_size :data, :less_than => 100.megabytes
  do_not_validate_attachment_file_type :data

  def url_thumb
    @url_thumb ||= Ckeditor::Utils.filethumb(filename)
  end
end
