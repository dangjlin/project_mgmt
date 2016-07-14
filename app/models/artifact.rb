class Artifact < ActiveRecord::Base
  before_save :upload_to_s3
  attr_accessor :upload
  belongs_to :project
  
  MAX_FILESIZE = 10.megabytes
  
  validates_presence_of :name, :upload
  validates_uniqueness_of :name
  
  validate :uploaded_file_size
  
  
  private
  
  def upload_to_s3
    credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    client = Aws::S3::Client.new(region: 'ap-northeast-1', credentials: credentials)
    s3 = Aws::S3::Resource.new(client: client)
    tenant_name = Tenant.find(Thread.current[:tenant_id]).name
    obj = s3.bucket(ENV['AWS_S3_BUCKET']).object("#{tenant_name}/#{upload.original_filename}")
    obj.upload_file(upload.path, acl:'public-read')
    self.key = obj.public_url
  end
  
  
  def uploaded_file_size
    if upload
    errors.add(:upload, "File size must less than #{self.class::MAX_FILESIZE}" ) unless upload.size <= self.class::MAX_FILESIZE
    end 
  end
  
end
