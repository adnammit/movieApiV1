const express = require('express')
const path = require('path')
const PORT = process.env.PORT || 5000
const api = require('./api/index.js')
const exceptionHandler = require('./middleware/exceptionHandler.js')

const app = express()
app
	.use(express.static(path.join(__dirname, 'public')))
	.set('views', path.join(__dirname, 'views'))
	.set('view engine', 'ejs')
	.get('/', (req, res) => res.render('pages/index'))

app.use('/api/v1', api)
	.use(exceptionHandler.log)
	.use(exceptionHandler.clientHandle)
	.use(exceptionHandler.handle)

app
	.listen(PORT, () => {
		console.log(`Server listening on port ${PORT}`)
	});
