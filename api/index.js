const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors')
const router = require('../routes/router.js')

const api = express()
api
	.use(bodyParser.json())
	.use(bodyParser.urlencoded({ extended: true }))
	.use(cors())
	.use('/user', router)

module.exports = api
