# frozen_string_literal: true

require 'pg'

db = PG.connect(host: 'localhost', port: 5432, user: 'gps_collector', dbname: 'gps_collector')

query = 'CREATE TABLE IF NOT EXISTS points (pt GEOMETRY(POINT) UNIQUE);'
db.exec(query)

db.close
