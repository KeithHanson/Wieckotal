require 'rubygems'
require 'ruby-debug' if ENV["DEBUG"]
require 'sinatra'
require 'sinatra/base'
require 'pivotal-tracker'
require 'active_support'
require 'rdiscount'


class Wieckotal < Sinatra::Base
  set :environment, :production
  set :static, true
  set :root, File.dirname(__FILE__)

  before do
    if session[:api_key].nil? || session[:project_id].nil?
      redirect '/login' unless env["REQUEST_URI"] == "/login"
    else
      begin
        @pt = PivotalTracker.new(session[:project_id], session[:api_key])
      rescue
        redirect '/login' unless env["REQUEST_URI"] == "/login"
      end
    end
  end

  helpers do
    def cleanup_html(string)
      string.gsub("\342\200\224", "-").gsub("\342\200\246", "...").gsub("\342\200\230", "'").gsub("\342\200\231", "'")
    end
  end

  get '/' do
    debugger if ENV["DEBUG"]

    @all_stories = @pt.current_iteration.stories

    @stories = @all_stories.select {|s| s.current_state != "accepted" && s.story_type != "release"}
    
    @accepted = @all_stories.select {|s| s.current_state == "accepted"}
    
    haml :index
  end

  get '/stats' do
    @all_stories = @pt.current_iteration.stories

    @done_stories = @all_stories.select {|s| s.current_state == "accepted"}

    @done_stories_points = {}
    @done_stories_points_ams = {}

    @done_stories.each do |story|
      story.labels.split(",").each do |label|
        unless ["newsroom", "production ready"].include?(label.downcase)
          @done_stories_points[label] ||= 0
          @done_stories_points[label] += story.estimate.to_i 
        end
      end unless story.labels.nil?

      if story.labels && ["Scott Schwartz", "Lindsay Hamm", "Todd Colston"].include?(story.requested_by)
        @done_stories_points_ams[story.requested_by] ||= 0
        @done_stories_points_ams[story.requested_by] += story.estimate.to_i
      end
    end

    @done_stories_points = @done_stories_points.to_json
    @done_stories_points_ams = @done_stories_points_ams.to_json
    @done_stories = @done_stories.to_json

    @finished_stories = @all_stories.select {|s| s.current_state == "finished"}

    @finished_stories_points = {}
    @finished_stories_points_ams = {}
    @finished_stories_points_devs = {}

    @finished_stories.each do |story|
      story.labels.split(",").each do |label|
        unless ["newsroom", "production ready"].include?(label.downcase)
          @finished_stories_points[label] ||= 0
          @finished_stories_points[label] += story.estimate.to_i 
        end
      end unless story.labels.nil? || story.labels.include?("production ready")

      if story.labels && !story.labels.include?("production ready") && ["Scott Schwartz", "Lindsay Hamm", "Todd Colston"].include?(story.owned_by)
        @finished_stories_points_ams[story.owned_by] ||= 0
        @finished_stories_points_ams[story.owned_by] += story.estimate.to_i 
      end

      if story.labels && !story.labels.include?("production ready") && !["Scott Schwartz", "Lindsay Hamm", "Todd Colston"].include?(story.owned_by)
        @finished_stories_points_devs[story.owned_by] ||= 0
        @finished_stories_points_devs[story.owned_by] += story.estimate.to_i 
      end
    end

    @finished_stories = @finished_stories.to_json
    @finished_stories_points = @finished_stories_points.to_json
    @finished_stories_points_ams = @finished_stories_points_ams.to_json
    @finished_stories_points_devs = @finished_stories_points_devs.to_json

    @delivered_stories = @all_stories.select {|s| s.current_state == "delivered"}
    @delivered_stories_points = {}
    @delivered_stories_points_ams = {}

    @delivered_stories.each do |story|
      story.labels.split(",").each do |label|
        unless ["newsroom", "production ready"].include?(label.downcase)
          @delivered_stories_points[label] ||= 0
          @delivered_stories_points[label] += story.estimate.to_i 
        end
      end unless story.labels.nil?

      if story.labels && story.labels.include?("production ready") && ["Scott Schwartz", "Lindsay Hamm", "Todd Colston"].include?(story.owned_by)
        @delivered_stories_points_ams[story.requested_by] ||= 0
        @delivered_stories_points_ams[story.requested_by] += story.estimate.to_i
      end
    end

    @delivered_stories = @delivered_stories.to_json
    @delivered_stories_points = @delivered_stories_points.to_json
    @delivered_stories_points_ams = @delivered_stories_points_ams.to_json
    
    haml :stats
  end

  get '/login' do
    haml :login
  end

  post '/login' do

    unless params["api_key"].blank? || params["project_id"].blank?
      
      begin
        PivotalTracker.new(params["project_id"], params["api_key"]).project
        session[:api_key] = params["api_key"]
        session[:project_id] = params["project_id"]

        redirect "/"
      rescue
        flash[:error] = "Credentials Incorrect. Please try again"
      end

    else
      flash[:error] = "You must provide a project_id and your API Key."
    end

    haml :login
  end

  get '/comments/:id' do
    @comments = @pt.notes(params[:id])
    haml :comments, :layout => false
  end
end

