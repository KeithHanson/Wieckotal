require 'rubygems'
require 'ruby-debug' if ENV["DEBUG"]
require 'sinatra'
require 'pivotal-tracker'
require 'active_support'
require 'rack-flash'
require 'rdiscount'

use Rack::Session::Cookie, :expire_after => 6.months.to_i

use Rack::Flash, :accessorize => [:notice, :error]

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
