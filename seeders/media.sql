/* -- SEEDING THE DATABASE -------------------------------------------------------

login to heroku psql (use powershell):
      heroku pg:psql postgresql-rugged-34339 --app intense-castle-24661
populate your prod db
        cat .\seeders\media.sql | heroku pg:psql postgresql-rugged-34339 --app intense-castle-24661
*/


/* -- LOCAL DEPLOY -- MAKE SURE YOU'RE CONNECTED TO MEDIA DB!!! -----------------------------------------
    psql -d media -U <username>
    # copy/paste script into shell
*/
do $$

begin

    create schema if not exists movie;
    create schema if not exists tv;

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

    drop table if exists tv.title cascade;
    create table tv.title(
        id              serial primary key  not null,
        moviedbid       int                 not null unique,
        imdbid          text                not null,
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
        queued          boolean             not null default false,
        active          boolean             not null default true,
        datecreated     timestamptz         not null default NOW(),
        unique (userid, movieid)
    );

    drop table if exists tv.usertv cascade;
    create table tv.usertv(
        id              serial primary key  not null,
        userid          int                 not null references public.user(id),
        tvid            int                 not null references tv.title(id),
        rating          int                 check(rating >= 0 AND rating <= 5),
        watched         boolean             not null default false,
        favorite        boolean             not null default false,
        queued          boolean             not null default false,
        active          boolean             not null default true,
        datecreated     timestamptz         not null default NOW(),
        unique (userid, tvid)
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
    _favorite in boolean DEFAULT false,
    _queued in boolean DEFAULT false)
returns void as $$
declare _movieid int;
begin

    _movieid := movie.addMovie(_moviedbid, _imdbid);

    if exists (select from movie.usermovie where movieid = _movieid and userid = _userid)
    then
        update movie.usermovie
        set
            active = true
            -- **START HERE***
            ---- set watched, rating, favorite, queued if values are provided
        where movieid = _movieid and userid = _userid;
    else
        insert into movie.usermovie(userid, movieid, rating, watched, favorite, queued)
        values (_userid, _movieid, _rating, _watched, _favorite, _queued);
    end if;

end;
$$ language plpgsql;

drop function if exists movie.updateUserMovie;
create function movie.updateUserMovie(
    _userid in int,
    _movieid in int,
    _rating in int DEFAULT null,
    _watched in boolean DEFAULT false,
    _favorite in boolean DEFAULT false,
    _queued in boolean DEFAULT false)
returns void as $$
begin

    update movie.usermovie
    set
        rating = _rating,
        watched = _watched,
        favorite = _favorite,
        queued = _queued
    WHERE userid = _userid AND movieid = _movieid;

end;
$$ language plpgsql;

drop function if exists movie.getUserMovies;
create function movie.getUserMovies(
    _userid in int)
returns table (
    userid int,
    id int,
    moviedbid int,
    imdbid text,
    rating int,
    watched boolean,
    favorite boolean,
    queued boolean
) as $$
begin

    return query
    select
        um.userid as "userid",
        t.id as "id",
        t.moviedbid as "moviedbid",
        t.imdbid as "imdbid",
        um.rating as "rating",
        um.watched as "watched",
        um.favorite as "favorite",
        um.queued as "queued"
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
    id int,
    moviedbid int,
    imdbid text,
    rating int,
    watched boolean,
    favorite boolean,
    queued boolean
) as $$
begin

    return query
    select
        um.userid as "userid",
        t.id as "id",
        t.moviedbid as "moviedbid",
        t.imdbid as "imdbid",
        um.rating as "rating",
        um.watched as "watched",
        um.favorite as "favorite",
        um.queued as "queued"
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

drop function if exists tv.addTv;
create function tv.addTv(
    _moviedbid in int,
    _imdbid in text)
returns int as $$
begin

    if not exists(select from tv.title where moviedbid = _moviedbid)
    then
        insert into tv.title(moviedbid, imdbid)
        values (_moviedbid, _imdbid);
    end if;

    return (select id from tv.title where moviedbid = _moviedbid);

end;
$$ language plpgsql;

drop function if exists tv.addUserTv;
create function tv.addUserTv(
    _userid in int,
    _moviedbid in int,
    _imdbid in text,
    _rating in int DEFAULT null,
    _watched in boolean DEFAULT false,
    _favorite in boolean DEFAULT false,
    _queued in boolean DEFAULT false)
returns void as $$
declare _tvid int;
begin

    _tvid := tv.addTv(_moviedbid, _imdbid);

    if exists (select from tv.usertv where tvid = _tvid and userid = _userid)
    then
        update tv.usertv
        set
            active = true
            -- **START HERE***
            ---- set watched, rating, favorite, queued if values are provided
        where tvid = _tvid and userid = _userid;
    else
        insert into tv.usertv(userid, tvid, rating, watched, favorite, queued)
        values (_userid, _tvid, _rating, _watched, _favorite, _queued);
    end if;

end;
$$ language plpgsql;

drop function if exists tv.updateUserTv;
create function tv.updateUserTv(
    _userid in int,
    _tvid in int,
    _rating in int DEFAULT null,
    _watched in boolean DEFAULT false,
    _favorite in boolean DEFAULT false,
    _queued in boolean DEFAULT false)
returns void as $$
begin

    update tv.usertv
    set
        rating = _rating,
        watched = _watched,
        favorite = _favorite,
        queued = _queued
    WHERE userid = _userid AND tvid = _tvid;

end;
$$ language plpgsql;

drop function if exists tv.getUserTvs;
create function tv.getUserTvs(
    _userid in int)
returns table (
    userid int,
    id int,
    moviedbid int,
    imdbid text,
    rating int,
    watched boolean,
    favorite boolean,
    queued boolean
) as $$
begin

    return query
    select
        ut.userid as "userid",
        t.id as "id",
        t.moviedbid as "moviedbid",
        t.imdbid as "imdbid",
        ut.rating as "rating",
        ut.watched as "watched",
        ut.favorite as "favorite",
        ut.queued as "queued"
    from tv.usertv ut
        inner join tv.title t on t.id = ut.tvid
    where ut.userid = _userid and ut.active;

end;
$$ language plpgsql;

drop function if exists tv.getUserTv;
create function tv.getUserTv(
    _userid in int,
    _tvid in int)
returns table (
    userid int,
    id int,
    moviedbid int,
    imdbid text,
    rating int,
    watched boolean,
    favorite boolean,
    queued boolean
) as $$
begin

    return query
    select
        ut.userid as "userid",
        t.id as "id",
        t.moviedbid as "moviedbid",
        t.imdbid as "imdbid",
        ut.rating as "rating",
        ut.watched as "watched",
        ut.favorite as "favorite",
        ut.queued as "queued"
    from tv.usertv ut
        inner join tv.title t on t.id = ut.tvid
    where ut.userid = _userid
        and ut.tvid = _tvid
        and ut.active;

end;
$$ language plpgsql;

drop function if exists tv.deleteUserTv;
create function tv.deleteUserTv(
    _userid in int,
    _tvid in int)
returns void as $$
begin

    update tv.usertv
    set
        active = false
    where _userid = userid and _tvid = tvid;

end;
$$ language plpgsql;


drop function if exists public.getUserMedia;
create function public.getUserMedia(
    _userid in int)
returns table (
    userid int,
    id int,
    moviedbid int,
    imdbid text,
    rating int,
    watched boolean,
    favorite boolean,
    queued boolean
) as $$
begin

    return query
    select
        ut.userid as "userid",
        t.id as "id",
        t.moviedbid as "moviedbid",
        t.imdbid as "imdbid",
        ut.rating as "rating",
        ut.watched as "watched",
        ut.favorite as "favorite",
        ut.queued as "queued"
    from tv.usertv ut
        inner join tv.title t on t.id = ut.tvid
    where ut.userid = _userid and ut.active
    union all
    select
        um.userid as "userid",
        t.id as "id",
        t.moviedbid as "moviedbid",
        t.imdbid as "imdbid",
        um.rating as "rating",
        um.watched as "watched",
        um.favorite as "favorite",
        um.queued as "queued"
    from movie.usermovie um
        inner join movie.title t on t.id = um.movieid
    where um.userid = _userid and um.active;

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
select movie.addUserMovie(1, 299536, 'tt4154756', 3, true, false, false);
select movie.addUserMovie(1, 280, 'tt0103064', 3, true, false, true);
select movie.addUserMovie(1, 541305, 'tt8143990', 5, true, true, false);
select movie.addUserMovie(1, 2108, 'tt0088847', 0, false, false, false);
select tv.addUserTv(1, 95, 'tt0118276', 5, true, true, false);
select tv.addUserTv(1, 115004, 'tt10155688', 0, false, false, true);
--     perform movie.addUserMovie(1, 8392, 'tt0096283');
--     perform movie.addUserMovie(2, 8392, 'tt0096283');
--     perform movie.updateUserMovie(1, 1, null, false, false);

select * from movie.getUserMovies(1);
select * from movie.getUserMovie(1,1);
select * from tv.getUserTvs(1);
