# frozen_string_literal: true

# API service to insert and retrive GEOJson points
class Point
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @db = PG.connect(host: 'localhost', port: 5432, user: 'gps_collector', dbname: 'gps_collector')
  end

  def response
    response = Rack::Response.new
    if @request.post?
      params = JSON.parse(@request.body.read)
      case @request.path
      when '/'
        response = insert_points(params)
      else
        return not_found
      end
    elsif @request.get?
      params = @request.params
      case @request.path
      when '/'
        response = get_points(params)
      else
        return not_found
      end
    else
      return not_found
    end
    response
  end

  def process_insert_points_params(params)
    geometries = nil
    if params.is_a?(Array)
      geometries = params
    elsif params.is_a?(Hash) && params['type'] == 'GeometryCollection'
      geometries = params['geometries']
    end
    geometries
  end

  def insert_points(params)
    response = Rack::Response.new
    geometries = process_insert_points_params(params)
    return bad_request if geometries.nil?

    values = []
    geometries.each do |geom|
      if geom['type'] == 'Point'
        coord = geom['coordinates']
        values << "('POINT(#{coord.join(' ')})')"
      end
    end

    unless values.empty?
      query = "INSERT INTO points VALUES #{values.join(',')}"
      @db.exec(query)
    end
    response
  end

  def process_get_points_params(params)
    case params['type']
    when 'Point'
      coord = params['coordinates']
      radius = params['radius'].to_i

      query = <<-SQL
        SELECT ST_AsGeoJSON(pt) FROM points WHERE ST_DWithin(
          points.pt, ST_Point(#{coord}), #{radius});
      SQL
    when 'Polygon'
      line_string = params['lineString']

      query = <<-SQL
        SELECT ST_AsGeoJSON(pt) FROM points WHERE ST_Within(
          points.pt, ST_MakePolygon('LINESTRING(#{line_string})'));
      SQL
    else
      query = nil
    end
    query
  end

  def get_points(params)
    response = Rack::Response.new
    query = process_get_points_params(params)

    result = []
    @db.exec(query) do |res|
      res.each do |row|
        result << JSON.parse(row['st_asgeojson'])
      end
    end
    response.write(result.to_json)
    response
  end

  def not_found
    Rack::Response.new('Not Found', 404)
  end

  def bad_request
    Rack::Response.new('Bad Request', 400)
  end
end
