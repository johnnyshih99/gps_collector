# README

This is a simple Ruby/Rack application backed by a Postgres/PostGIS database.  
For the time being, the database must run on `localhost:5432`  
The app runs on default `localhost:9292`  

The app has a POST endpoint to accept GeoJSON point(s) to be inserted into the database table.  
The points inserted are of type GEOMETRY(POINT) which can be thought of points on a cartesian plane having (x, y) values. The points are made unique so a new point cannot be inserted if there already exists a point at the same location. Using type GEOMETRY made testing a bit simpler because we can quickly draw points on a x-y plane and check the output of our functions.  

The app has a GET endpoint to get GeoJSON point(s) within a radius around a point or within a geometric polygon, depending on the params.  

Parameter validation/handling is minimal at best. I'm not sure how far into it I should be doing, so I left it for now. The kind of input params the system is expecting are shown in the test section.  

* Ruby version
ruby 2.5.3  
bundler 1.17.1

* System dependencies
docker
docker-compose

* Configuration
First run `bundle install`  
Set up the database described below
run `bundle exec rackup -Ilib` to start the server

* Database
To stand up the database image  
run `docker-compose up -d db`  
For database initialization  
run `bundle exec ruby lib/db.rb`  

* Linting
run `bundle exec rubocop`

* Testing
Manual testing. Using javascript to send requests (I used the browser console)  
There really should be automated tests.

```javascript
// insert an array of GeoJSON points via POST
// expect 11 rows inserted
inp = [
  {
    "type": "Point",
    "coordinates": [0, 4]
  },{
    "type": "Point",
    "coordinates": [1, 1]
  },{
    "type": "Point",
    "coordinates": [2, 3]
  },{
    "type": "Point",
    "coordinates": [2, 6]
  },{
    "type": "Point",
    "coordinates": [3, 1]
  },{
    "type": "Point",
    "coordinates": [3, 8]
  },{
    "type": "Point",
    "coordinates": [4, 2]
  },{
    "type": "Point",
    "coordinates": [4, 4]
  },{
    "type": "Point",
    "coordinates": [4, 5]
  },{
    "type": "Point",
    "coordinates": [5, 4]
  },{
    "type": "Point",
    "coordinates": [7, 0]
  }
]
fetch('http://localhost:9292', {
    method: 'POST',
    body: JSON.stringify(inp),
}).then(res => res).then(console.log)
```

```javascript
// Retrieve points around point(4,4) with a radius 2
// expect 4 points (4,2), (4,4), (4,5), (5,4)
let url = new URL('http://localhost:9292')
inp = {
  "type": "Point",
  "coordinates": [4, 4],
  "radius": 2
}
url.search = new URLSearchParams(inp)

fetch(url).then(res => res.json()).then(console.log)
```

```javascript
// Retrieve points inside an polygon
// Note that a lineString must be constructed
// since nested objects don't do well in get params
// expect 7 points (1, 1), (2, 3), (3, 1), (4, 2), 
//                 (4, 4), (4, 5), (5, 4), 
let url = new URL('http://localhost:9292')
inp = {
  "type": "Polygon",
  "coordinates": [
    [
      [0, 0],
      [6, 0],
      [6, 6],
      [1, 5],
      [0, 0]
    ]
  ]
}
inp["lineString"] = [];
inp["coordinates"][0].forEach(function(e) {
  inp["lineString"].push(e.join(" "));
});
url.search = new URLSearchParams(inp)
fetch(url).then(res => res.json()).then(console.log)
```
