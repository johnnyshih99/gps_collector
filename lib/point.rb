class Point
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @db = PG.connect(host:"localhost", port:5432, user: "gps_collector", dbname: "gps_collector")
  end

  def response
    response = Rack::Response.new
    if @request.post?
      case @request.path
      when "/"
        response.write("post")
      else
        response = not_found
      end
    elsif @request.get?
      case @request.path
      when "/"
        response.write("root")
      when "/test"
        response.write("test")
      else
        response = not_found
      end
    else
      response = not_found
    end
    response
  end

  def not_found
    Rack::Response.new("Not Found", 404)
  end
end