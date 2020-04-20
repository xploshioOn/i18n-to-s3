class S3Job < ApplicationJob

  def run_translation
    # set default values
    init(event)
    # verify if output file exist 
    # to create or update existent
    if @s3_bucket.object(@path).exists?
      file_content("update")
    else
      file_content("create")
    end
    # upload file
    upload_file
  end

  def upload_base_file
    # set default values
    init(event)
    @new_file = @base_file
    # upload file
    upload_file(base = true)
  end

  private

  # default values
  def init(event)
    @bucket_name = ENV["S3_BUCKET"]
    @path = event[:path]
    @base_file = event[:base_file]
    @s3_bucket = Aws::S3::Resource.new().bucket(@bucket_name)
    @language = @path.split("/").last.split(".").first
    @file_type = event[:file_type]
  end

  # take file content
  def get_file
    @s3_bucket.object(@path).get().body.read
  end

  # content for new file
  def file_content(action)
    options = {
      source: @base_file,
      language: @language,
      file_type: @file_type
    }
    if action == "update"
      options[:target] = get_file
      @new_file = FileContent.new(options).update_file 
    else
      @new_file = FileContent.new(options).generate_file
    end
  end

  def upload_file(base = false)
    resource = @s3_bucket.object(@path)
    new_file = @new_file
    # base file comes with correct format so 
    # we don't need to convert it to the type
    unless base
      if @file_type == "json"
        new_file = @new_file.to_json
      else
        new_file = @new_file.to_yaml
      end
    end
    # you need to have write access on the bucket
    resource.put(
      body: StringIO.new(new_file), 
      acl: 'bucket-owner-full-control',
      content_type: "#{mime_types(@file_type)}; charset=utf-8"
    )
  end

  # get myme type of file
  def mime_types(type)
    mime_types = {
      yaml: "application/x-yaml",
      json: "application/json"
    }
    mime_types[type.to_sym]
  end
  
end
