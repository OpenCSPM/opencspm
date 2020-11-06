const http = require('http')
const fs = require('fs')
const httpPort = 8000

http.createServer((req, res) => {
  fs.readFile('index.html', 'utf-8', (err, content) => {
    if (err) {
      console.log('OpenCSPM frontend cannot open "index.html" file.')
    }

    res.writeHead(200, {
      'Content-Type': 'text/html; charset=utf-8'
    })

    res.end(content)
  })
}).listen(httpPort, () => {
  console.log('OpenCSPM frontend server listening on: http://localhost:%s', httpPort)
})
