CREATE TABLE page (
    id  INTEGER PRIMARY KEY,
    owner INTEGER REFERENCES user,
    node VARCHAR(30),
    revision INTEGER REFERENCES revision,
    read text, write text, admin text
);

CREATE TABLE revision (
    id INTEGER PRIMARY KEY,
    revnum INTEGER,
    page INTEGER REFERENCES page,
    user INTEGER REFERENCES user,
    previous INTEGER REFERENCES revision,
    content TEXT,
    updated varchar(100)
);

CREATE TABLE link (
    id INTEGER PRIMARY KEY,
    from_page INTEGER,
    to_page INTEGER
);

CREATE TABLE user (
    id INTEGER PRIMARY KEY,
    login VARCHAR(100),
    name VARCHAR(100),
    pass VARCHAR(100),
    can_lock INT,
    can_upload INT 
);

CREATE TABLE wanted_page (
    id INTEGER PRIMARY KEY,
    page int REFERENCES page,
    node varchar(100)
);

CREATE TABLE preference (
    prefkey varchar(100) PRIMARY KEY,
    prefvalue varchar(100)
);

CREATE TABLE tag (
    id INTEGER PRIMARY KEY,
    user int REFERENCES user,
    page int REFERENCES page,
    tag varchar(100)
);

CREATE TABLE attachment (
    id INTEGER PRIMARY KEY,
    page int REFERENCES page,
    name varchar(100),
    contenttype varchar(100),
    content text
);

CREATE TABLE journal (
    pageid INTEGER PRIMARY KEY REFERENCES page,
    name varchar(100),
    dateformat varchar(20) DEFAULT '%F',
    defaultlocation varchar(100)
);

CREATE TABLE entry (
    id INTEGER PRIMARY KEY,
    journal int REFERENCES journal,
    author int REFERENCES user,
    title varchar(150),
    content TEXT,
    posted varchar(100),
    location varchar(100)
);


INSERT INTO user (login, name) VALUES ('AnonymousCoward','Anonymous Coward');
insert into user (login,name,pass) values ('marcus','Marcus Ramberg','secret');
INSERT INTO preference (prefkey, prefvalue) VALUES ('home_node','FrontPage');
INSERT INTO preference (prefkey, prefvalue) VALUES ('name','The Feed');
INSERT INTO page (owner,node,revision) VALUES ( 1,'FrontPage',1);
INSERT INTO page (owner,node,revision) VALUES ( 2,'marcus',2);
INSERT INTO revision (page,user,revnum,content,updated) VALUES(1,1,1,'testing testing, hello, is this thing on?','1970-01-01T00:00:00');
INSERT INTO revision (page,user,revnum,content,updated) VALUES(2,2,1,'h1. %{color:#555}marcus%

!>http://thefeed.no/img/pixel_me.gif!
This is my home. I like it here in cyberspace.

I''ve got some stuff online. Wanna publish them with the RSS formatter later.

* "some pictures.":http://thefeed.no/gallery/marcus
* "books I''m reading":http://marcusramberg.tadalist.com/lists/public/5200
* "stuff I want":http://marcusramberg.tadalist.com/lists/public/9629

h2. About me

I''m strange, I know. I guess you could say I''m a cyberpioneer :p I like to live my life online. I know there are many like me, but there are lots of other people out there too. 

If your interest is professional, I have a [[/marcus/CV]]. If your interest is related to open source, I have a "development project site":http://dev.thefeed.no. I also host the "maypole.perl.org":http://maypole.perl.org site.','2005-03-11T01:03:44');
