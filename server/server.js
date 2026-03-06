import express from "express";
import serveStatic from "serve-static";
import path from "node:path";

const app = express()
const port = process.env.PORT === undefined ? 3000 : process.env.PORT

app.use('/', express.static('dist'))

app.listen(port, () => {
  console.log(`Sample app listening on port ${port}`)
})
