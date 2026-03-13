import express from "express";

const app = express()
const port = process.env.PORT === undefined ? 3000 : process.env.PORT

app.use('/', express.static('dist'))

app.listen(port, () => {
  console.log(`Sample app listening on port ${port}`)
})
