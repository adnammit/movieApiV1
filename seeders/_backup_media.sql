/* -- SEEDING THE DATABASE -------------------------------------------------------

login to heroku psql (use powershell):
      heroku pg:psql postgresql-rugged-34339 --app intense-castle-24661
populate your prod db
        cat .\seeders\media.sql | heroku pg:psql postgresql-rugged-34339 --app intense-castle-24661
*/


-- MAKE SURE YOU'RE CONNECTED TO MEDIA DB -----------------------------------------
do $$

begin

    create schema if not exists movie;

    drop table if exists public.user cascade;
    create table public.user(
        id              serial primary key  not null,
        username        text                not null unique,
        email           text                not null unique,
        firstname       text                not null,
        lastname        text                not null,
        active          boolean             not null default true,
        datecreated     timestamptz         not null default NOW()
    );

    drop table if exists movie.title cascade;
    create table movie.title(
        id              serial primary key  not null,
        moviedbid       int                 not null unique,
        imdbid          text                not null,
        -- title           text                not null, -- need to store this? how dependent on imdb do we want to be?
        datecreated     timestamptz         not null default NOW()
    );

    drop table if exists movie.usermovie cascade;
    create table movie.usermovie(
        id              serial primary key  not null,
        userid          int                 not null references public.user(id),
        movieid         int                 not null references movie.title(id),
        rating          int                 check(rating >= 0 AND rating <= 5),
        watched         boolean             not null default false,
        favorite        boolean             not null default false,
        active          boolean             not null default true,
        datecreated     timestamptz         not null default NOW(),
        unique (userid, movieid)
    );

end $$;

drop function if exists public.addUser;
create function public.addUser(
    _username text,
    _email text,
    _firstname text,
    _lastname text)
returns void as $$
begin

    insert into public.user(username, email, firstname, lastname)
    values (_username, _email, _firstname, _lastname);

end;
$$ language plpgsql;

drop function if exists movie.addMovie;
create function movie.addMovie(
    _moviedbid in int,
    _imdbid in text)
returns int as $$
begin

    if not exists(select from movie.title where moviedbid = _moviedbid)
    then
        insert into movie.title(moviedbid, imdbid)
        values (_moviedbid, _imdbid);
    end if;

    return (select id from movie.title where moviedbid = _moviedbid);

end;
$$ language plpgsql;

drop function if exists movie.addUserMovie;
create function movie.addUserMovie(
    _userid in int,
    _moviedbid in int,
    _imdbid in text,
    _rating in int DEFAULT null,
    _watched in boolean DEFAULT false,
    _favorite in boolean DEFAULT false)
returns void as $$
declare _movieid int;
begin

    _movieid := movie.addMovie(_moviedbid, _imdbid);

    if exists (select from movie.usermovie where movieid = _movieid and userid = _userid)
    then
        update movie.usermovie
        set
            active = true
        where movieid = _movieid and userid = _userid;
    else
        insert into movie.usermovie(userid, movieid, rating, watched, favorite)
        values (_userid, _movieid, _rating, _watched, _favorite);
    end if;

end;
$$ language plpgsql;

drop function if exists movie.updateUserMovie;
create function movie.updateUserMovie(
    _userid in int,
    _movieid in int,
    _rating in int DEFAULT null,
    _watched in boolean DEFAULT false,
    _favorite in boolean DEFAULT false)
returns void as $$
begin

    update movie.usermovie
    set
        rating = _rating,
        watched = _watched,
        favorite = _favorite
    WHERE userid = _userid AND movieid = _movieid;

end;
$$ language plpgsql;

drop function if exists movie.getUserMovies;
create function movie.getUserMovies(
    _userid in int)
returns table (
    userid int,
    movieid int,
    moviedbid int,
    imdbid text,
    rating int,
    watched boolean,
    favorite boolean
) as $$
begin

    return query
    select
        um.userid as "userid",
        t.id as "movieid",
        t.moviedbid as "moviedbid",
        t.imdbid as "imdbid",
        um.rating as "rating",
        um.watched as "watched",
        um.favorite as "favorite"
    from movie.usermovie um
        inner join movie.title t on t.id = um.movieid
    where um.userid = _userid and um.active;

end;
$$ language plpgsql;

drop function if exists movie.getUserMovie;
create function movie.getUserMovie(
    _userid in int,
    _movieid in int)
returns table (
    userid int,
    movieid int,
    moviedbid int,
    imdbid text,
    rating int,
    watched boolean,
    favorite boolean
) as $$
begin

    return query
    select
        um.userid as "userid",
        t.id as "movieid",
        t.moviedbid as "moviedbid",
        t.imdbid as "imdbid",
        um.rating as "rating",
        um.watched as "watched",
        um.favorite as "favorite"
    from movie.usermovie um
        inner join movie.title t on t.id = um.movieid
    where um.userid = _userid
        and um.movieid = _movieid
        and um.active;

end;
$$ language plpgsql;

drop function if exists movie.deleteUserMovie;
create function movie.deleteUserMovie(
    _userid in int,
    _movieid in int)
returns void as $$
begin

    update movie.usermovie
    set
        active = false
    where _userid = userid and _movieid = movieid;

end;
$$ language plpgsql;



-- TESTING -----------------------------------
-- add a usermovie with a movieid/userid that does not exist
-- delete a usermovie that does not exist
-- add a usermovie, delete it, then add it again
-- add a usermovie for a movie that does not exist
-- add a usermovie for a movie that already exists
-- add negative score
-- add score > 5

-- POPULATION -----------------------------------

select public.addUser('test','test@test.com','testy','mctesterson');
select public.addUser('mfpilot','solo@test.com','han','solo');

-- select movie.addMovie(299536, 'tt4154756');
-- select movie.addMovie(8392, 'tt0096283');
select movie.addUserMovie(1, 299536, 'tt4154756', 3, true, false);
--     perform movie.addUserMovie(1, 8392, 'tt0096283');
--     perform movie.addUserMovie(2, 8392, 'tt0096283');
--     perform movie.updateUserMovie(1, 1, null, false, false);

select * from movie.getUserMovies(1);
select * from movie.getUserMovie(1,1);
