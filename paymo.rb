require 'rest_client'
require 'json'
require 'uri'

class Paymo
  attr_accessor :server, :api_key, :format, :token

  def initialize(server,api_key)
	  @server = server
	  @api_key = api_key
	  @format = "json"
  end

  def login(username,password)
	  resp = self.query('paymo.auth.login',{:username=>username, :password=>password})
	  @token = resp["token"]["_content"]
  end

  def logout()
    self.query('paymo.auth.logout',{:logout=>"yes"})
  end

  def findTasksByName(name)
	  self.query('paymo.tasks.findByName',
		  {
			  :name=>URI.escape(name, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
		  }
	  )
  end

  def findProject(name)
	  self.getProjectsList.select{|i| i["name"]==name}
  end

  def getProjectsList()
	  projects = self.query('paymo.projects.getList',{:include_task_lists=>0,:include_tasks=>0})
	  projects["projects"]["project"]
  end

  def listProjectTasks(projectId)
	  tasks = self.query('paymo.tasks.findByProject',{:project_id=>projectId})
    tasks["tasks"]["task"]
  end

  def query(method,args)
  	args[:api_key] = @api_key
	  args[:format] = @format
	  args[:auth_token] = @token

	  restQuery = server + method + '?' + args.collect{|i,j| "#{i}=#{j}"}.join("&")

	  resp = RestClient.get restQuery

	  JSON.parse(resp)
  end
end


if __FILE__ == $0
  require 'yaml'

  confs = YAML::load(File.open('paymo.yaml'))
  paymo = Paymo.new(confs['serviceurl'],confs['apikey'])

  paymo.login("user","pass")

  projects = paymo.getProjectsList()
  puts projects

=begin
  projects.each do |p|
    puts p["id"]

    tasks = paymo.listProjectTasks(p["id"])
    puts tasks
  end
=end

  puts paymo.listProjectTasks(172119);
  
end

