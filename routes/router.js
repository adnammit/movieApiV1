const express = require('express')
const User = require('../data/user.js')
const UserMovie = require('../data/userMovie.js')
const UserTv = require('../data/userTv.js')

const router = express.Router()

router
	.route('/')
	.get(User.getUsers)
	.post(User.addUser)

router
	.route('/:id')
	.get(User.getUserByUserId)
	// .post(User.updateUser) // maybe idk

router
	.route('/:id/movies')
	.get(UserMovie.getUserMovies)
	.put((req, res) => {
		UserMovie.updateUserMovie(req, res)
	})
	.post((req, res) => {
		UserMovie.addUserMovie(req, res)
	})

router
	.route('/:id/movies/:movie_id')
	.get(UserMovie.getUserMovie)
	.delete((req, res) => {
		UserMovie.deleteUserMovie(req, res)
	})

router
	.route('/:id/tv')
	.get(UserTv.getUserTvs)
	.put((req, res) => {
		UserTv.updateUserTv(req, res)
	})
	.post((req, res) => {
		UserTv.addUserTv(req, res)
	})

router
	.route('/:id/tv/:tv_id')
	.get(UserTv.getUserTv)
	.delete((req, res) => {
		UserTv.deleteUserTv(req, res)
	})

module.exports = router

