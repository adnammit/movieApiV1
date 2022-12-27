const { pool } = require('../config/config')

exports.getUserTvs = (request, response, next) => {
	const id = parseInt(request.params.id)
	pool.query('select * from tv.getUserTvs($1)', [id])
		.then((results) => {
			response.status(200).json(results.rows)
		})
		.catch((err) => {
			next(err)
		})
}

exports.getUserTv = (request, response, next) => {
	const userId = parseInt(request.params.id)
	const tvId = parseInt(request.params.tv_id)
	pool.query('select * from tv.getUserTv($1,$2)', [userId, tvId])
		.then((results) => {
			response.status(200).json(results.rows)
		})
		.catch((err) => {
			next(err)
		})
}

exports.updateUserTv = (request, response, next) => {
	const userId = parseInt(request.params.id)
	const tv = request.body
	const tvId = parseInt(tv.id)

	pool.query('select tv.updateUserTv($1, $2, $3, $4, $5, $6)', [userId, tvId, tv.rating, tv.watched, tv.favorite, tv.queued])
		.then((results) => {
			response.status(200).json(results.rows)
		})
		.catch((err) => {
			next(err)
		})
}

exports.addUserTv = (request, response, next) => {
	const userId = parseInt(request.params.id)
	const tv = request.body
	const tvId = parseInt(tv.movieDbId)
	pool.query('select tv.addUserTv($1, $2, $3, $4, $5, $6, $7)', [userId, tvId, tv.imdbId, tv.rating, tv.watched, tv.favorite, tv.queued])
		.then((results) => {
			response.status(200).json(results.rows)
		})
		.catch((err) => {
			next(err)
		})
}

exports.deleteUserTv = (request, response, next) => {
	const userId = parseInt(request.params.id)
	const tvId = parseInt(request.params.tv_id)
	pool.query('select tv.deleteUserTv($1, $2)', [userId, tvId])
		.then((results) => {
			response.status(200).json(results.rows)
		})
		.catch((err) => {
			next(err)
		})
}


