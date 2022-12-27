const { pool } = require('../config/config')

exports.getUserMovies = (request, response, next) => {
	const id = parseInt(request.params.id)
	pool.query('select * from movie.getUserMovies($1)', [id])
		.then((results) => {
			response.status(200).json(results.rows)
		})
		.catch((err) => {
			next(err)
		})
}

exports.getUserMovie = (request, response, next) => {
	const userId = parseInt(request.params.id)
	const movieId = parseInt(request.params.movie_id)
	pool.query('select * from movie.getUserMovie($1,$2)', [userId, movieId])
		.then((results) => {
			response.status(200).json(results.rows)
		})
		.catch((err) => {
			next(err)
		})
}

exports.updateUserMovie = (request, response, next) => {
	const userId = parseInt(request.params.id)
	const movie = request.body
	const movieId = parseInt(movie.id)

	pool.query('select movie.updateUserMovie($1, $2, $3, $4, $5, $6)', [userId, movieId, movie.rating, movie.watched, movie.favorite, movie.queued])
		.then((results) => {
			response.status(200).json(results.rows)
		})
		.catch((err) => {
			next(err)
		})
}

exports.addUserMovie = (request, response, next) => {
	const userId = parseInt(request.params.id)
	const movie = request.body
	const movieId = parseInt(movie.movieDbId)
	pool.query('select movie.addUserMovie($1, $2, $3, $4, $5, $6, $7)',	[userId, movieId, movie.imdbId, movie.rating, movie.watched, movie.favorite, movie.queued])
		.then((results) => {
			response.status(200).json(results.rows)
		})
		.catch((err) => {
			next(err)
		})
}

exports.deleteUserMovie = (request, response, next) => {
	const userId = parseInt(request.params.id)
	const movieId = parseInt(request.params.movie_id)
	pool.query('select movie.deleteusermovie($1, $2)', [userId, movieId])
		.then((results) => {
			response.status(200).json(results.rows)
		})
		.catch((err) => {
			next(err)
		})
}


