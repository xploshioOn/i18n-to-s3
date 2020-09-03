class TranslationsController < ApplicationController
  before_action :init
  class_managed_iam_policy(
    'service-role/AWSLambdaBasicExecutionRole'
  )

  def new
    if file_modified?
      @base_file = get_base_file
      S3Job.perform_later(:upload_base_file, set_event('en'))
      @languages.each do |language|
        # run job to generate/update file
        # you need to have permission to run
        # another lambda
        S3Job.perform_later(:run_translation, set_event(language))
      end
    end
    render json: { statusCode: 200 }
  end

  private

  # all the initial data needed
  def init
    @payload = params # payload from github webhook
    @file_path = params[:path] # the file that we are listening for changes
    @branches = ENV['BRANCHES'].split(':') # the branches we listen for changes
    @branch = @payload['ref'].split('/').last # take the branch from payload webhook
    @github_token = ENV['GITHUB_TOKEN'] # github personal token to access repo with role of admin:repo_hook
    @repository = @payload['repository']['full_name'] # the repository where the file is
    @languages = ENV['LANGUAGES'].split(':') # all languages to be generated
    @file_type = @file_path.split('.').last # get the file type from path
  end

  # we verify the branches we need
  # and if the translation file was updated
  def file_modified?
    if @branches.include? @branch
      if @payload['commits'].size > 0
        @payload['commits'].each do |commit|
          all_files = (commit['added'] || []) + (commit['modified'] || [])
          return true if all_files.include? @file_path
        end
      else
        all_files = (@payload['head_commit']['added'] || []) + (@payload['head_commit']['modified'] || [])
        return true if all_files.include? @file_path
      end
    end
    false
  end

  # we get the base file from github
  def get_base_file
    gh_client = Octokit::Client.new(access_token: @github_token)
    file = gh_client.contents(@repository, path: @file_path, query: { ref: @branch })
    Base64.decode64(file.content)
  end

  # set event values to the job
  def set_event(language)
    {
      path: "#{@repository}/#{@branch}/#{language}.#{@file_type}",
      base_file: @base_file,
      file_type: @file_type
    }
  end
end
