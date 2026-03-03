import express from "express";
import serveStatic from "serve-static";
import path from "node:path";

const app = express()
const port = 3000

app.use('/', express.static('dist'))

app.listen(port, () => {
  console.log(`Sample app listening on port ${port}`)
})
