bundle exec rackup -Ilib

testing
inp = [{
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
     }]
fetch('http://localhost:9292', {
    method: 'POST',
    body: JSON.stringify(inp),
}).then(res => res).then(console.log)


let url = new URL('http://localhost:9292')
inp = {
   "type": "Point",
   "coordinates": [4, 4],
   "radius":2
}
url.search = new URLSearchParams(inp)

fetch(url).then(res => res.json()).then(console.log)

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