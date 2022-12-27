# node-js-getting-started

A barebones Node.js app using [Express 4](http://expressjs.com/).

This application supports the [Getting Started on Heroku with Node.js](https://devcenter.heroku.com/articles/getting-started-with-nodejs) article - check it out.

## Running Locally

Make sure you have [Node.js](http://nodejs.org/) and the [Heroku CLI](https://cli.heroku.com/) installed.

```sh
$ git clone https://github.com/heroku/node-js-getting-started.git # or clone your own fork
$ cd node-js-getting-started
$ npm install
$ npm start
# with nodemon hot-loading
$ npm run start:dev
```

Your app should now be running on [localhost:5000](http://localhost:5000/).

## Deploying to Heroku

```
$ heroku create
$ git push heroku master
$ heroku open
```
or

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)


## DATABASE
* to deploy to prod:
	- scripts to init data are in /seeders
	```shell
		# use powershell for the following

		# login to your postgres app
		heroku pg:psql postgresql-rugged-34339 --app intense-castle-24661

		# populate your prod db
		cat .\seeders\media.sql | heroku pg:psql postgresql-rugged-34339 --app intense-castle-24661

		# deploy app
		git push heroku master
	```

## Curls
```shell
	# USER
	## GET
	curl http://localhost:5000/user
	curl http://localhost:5000/user/1

	## POST new
	curl --header "Content-Type: application/json" --request POST --data '{"username":"foo","email":"foo@bar.com","firstname":"johnny","lastname":"sixpack"}' http://localhost:5000/user/

	# USER MOVIES
	## GET
	curl http://localhost:5000/user/1/movies
	curl http://localhost:5000/user/1/movies/8392
	## PUT existing
	curl --header "Content-Type: application/json" --request PUT --data '{"id":"8392","watched":"true","favorite":"false"}' http://localhost:5000/user/1/movies
	## POST new
	curl --header "Content-Type: application/json" --request POST --data '{"id":"83", "imdbId":"tt41556","watched":"false","favorite":"false"}' http://localhost:5000/user/1/movies
```


## Documentation

For more information about using Node.js on Heroku, see these Dev Center articles:

- [Getting Started on Heroku with Node.js](https://devcenter.heroku.com/articles/getting-started-with-nodejs)
- [Heroku Node.js Support](https://devcenter.heroku.com/articles/nodejs-support)
- [Node.js on Heroku](https://devcenter.heroku.com/categories/nodejs)
- [Best Practices for Node.js Development](https://devcenter.heroku.com/articles/node-best-practices)
- [Using WebSockets on Heroku with Node.js](https://devcenter.heroku.com/articles/node-websockets)
* [Remember how psql do](https://www.tutorialspoint.com/postgresql/postgresql_insert_query.htm)


## to do
* REASSESS DB STRUCTURE - put movies and tv into one table with a reference table for type unless there's a strong reason not to
* better error handling so our server doesn't crash
* authentication
* request validation
* do prod tips in article
* add some logging perhaps

