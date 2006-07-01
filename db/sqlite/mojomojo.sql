-- changed "user" to "person" because "user"
-- is a reserved word in Oracle. 8-(
CREATE TABLE person (
 id         INTEGER PRIMARY KEY,
 active     INTEGER, -- boolean
 registered INTEGER,
 views	    INTEGER,
 photo	    INTEGER references PHOTO,
 login      VARCHAR(100),
 name       VARCHAR(100),
 email      VARCHAR(100),
 pass       VARCHAR(100),
 timezone   VARCHAR(100),
 born	    INT,
 gender	    CHAR(1),
 occupation VARCHAR(100),
 industry   VARCHART(100),
 interests  TEXT,
 movies	    TEXT,
 music	    TEXT
);

-- * page-content tree * --

-- In this tree, the page records are edges and the content
-- records are nodes. Separating pages-edges from content-nodes
-- has several benefits:

-- * fast reads-searches: most page listings (e.g. nav lists)
--   don't need content. searches should be faster and more
--   efficient without bulky content in the page table. this
--   may make writes a little slower, but reads will far
--   outnumber writes

-- * the page tree structure can change independently of
--   content, and vice versa. for example, this prevents
--   duplicating content every time a page name or parent
--   changes

-- content:
-- although this table will be large, almost all searching will be
-- done on page records, which have content fks. therefore 
-- retrieval should be fast: we'll always have content pks.
-- also note that content records are versioned separately from
-- the page tree structure. that way we don't have to perform
-- version updates on whole subtrees when only the content changes

CREATE TABLE content (
 page         INTEGER,
 version      INTEGER,
 creator      INTEGER REFERENCES person,
 created      VARCHAR(100),
 status       VARCHAR(20), -- released, removed, ...
 release_date VARCHAR(100),
 remove_date  VARCHAR(100),
 type         VARCHAR(200),
 abstract     VARCHAR(4000),
 comments     VARCHAR(4000),
 body         TEXT,
 precompiled   TEXT,
 PRIMARY KEY (page, version)
);

-- * page-page_version * --

-- we further separate pages from page versions.
-- the page table contains only "live" pages, which also has
-- several benefits:

-- * we can use single-column pks. most page metadata
-- can be left out of the page table. all this should
-- make for even faster reads

-- * we can enforce the constraint that all children of 
--   a parent page must have unique names

-- also, we could have made the page name the pk,
-- but then, for page renames, all child records would
-- have to be updated with the new name. therefore,
-- we define a separate page id instead 

-- also, the content fks really only exist in the table
-- to record the content version at the time of the
-- page structure change

CREATE TABLE page_version (
 page            INTEGER,
 version         INTEGER,
 parent          INTEGER,
 parent_version  INTEGER,
 name            VARCHAR(200),
 name_orig       VARCHAR(200),
 depth           INTEGER,
 creator         INTEGER REFERENCES person,
 created         VARCHAR(100),
 status          VARCHAR(20), -- released, removed, ...
 release_date    VARCHAR(100),
 remove_date     VARCHAR(100),
 comments        VARCHAR(4000),
 content_version_first INTEGER,
 content_version_last  INTEGER,
 PRIMARY KEY (page, version),
 FOREIGN KEY (page, content_version_first) REFERENCES content (page, version),
 FOREIGN KEY (page, content_version_last) REFERENCES content (page, version),
 FOREIGN KEY (parent, parent_version) REFERENCES page_version (page, version)
);

-- we resolve paths by searching on page name and depth:
CREATE INDEX page_version_depth_index ON page_version (depth, name);

CREATE TABLE page (
 id              INTEGER PRIMARY KEY,
 version         INTEGER,
 parent          INTEGER REFERENCES page,
 name            VARCHAR(200),
 name_orig       VARCHAR(200),
 depth           INTEGER,
 lft             INTEGER,
 rgt             INTEGER,
 content_version INTEGER,
 FOREIGN KEY (id, content_version) REFERENCES content (page, version),
 FOREIGN KEY (id, version) REFERENCES page_version (page, version)
);

-- all children of a parent must have unique names:
CREATE UNIQUE INDEX page_unique_child_index ON page (parent, name);

-- we resolve paths by searching on page name and depth:
CREATE INDEX page_depth_index ON page (depth, name);

-- we also resolve paths with nested sets:
CREATE INDEX page_lft_index ON page (lft);
CREATE INDEX page_rgt_index ON page (rgt);

-- * roles * --

-- currently unused

-- notice that all role tables and references are
-- now completely separate from the page-related
-- tables. that way we can allow for multiple
-- ownership and access plugins, role-based, 
-- tag-based, something completely different...
-- ...or even no access restrictions at all,
-- for people who want a traditional, wide-open wiki

CREATE TABLE role (
 id     INTEGER PRIMARY KEY,
 name   VARCHAR(200) UNIQUE NOT NULL,
 active INTEGER DEFAULT 1 NOT NULL -- boolean
);
 
CREATE TABLE role_member (
 role   INTEGER REFERENCES role,
 person INTEGER REFERENCES person,
 admin  INTEGER DEFAULT 0 NOT NULL, -- only admin members or "admin" role can add and remove members
 PRIMARY KEY (role, person)
); 

-- role_privilege is a relationship talbe.
-- with cascading deletes, if a page is deleted, the 
-- privilege is deleted. restores of deleted pages must
-- be done by someone with write privilege for the parent,
-- or the parent's parent, and so on, up to whatever 
-- depth in the path a parent page still exists

CREATE TABLE role_privilege (
 page      INTEGER REFERENCES page,
 role      INTEGER REFERENCES role,
 privilege VARCHAR(20), -- read, write, owner, ...
 PRIMARY KEY (page, role, privilege)
); 

-- * end of role tables so far

CREATE TABLE link (
    id        INTEGER PRIMARY KEY,
    from_page INTEGER REFERENCES page,
    to_page   INTEGER REFERENCES page
);

CREATE TABLE wanted_page (
    id        INTEGER PRIMARY KEY,
    from_page INTEGER REFERENCES page,
    to_path   VARCHAR(4000)
);

CREATE TABLE preference (
    prefkey   VARCHAR(100) PRIMARY KEY,
    prefvalue VARCHAR(100)
);

CREATE TABLE tag (
    id     INTEGER PRIMARY KEY,
    person INTEGER REFERENCES person,
    page   INTEGER REFERENCES page,
    photo  INTEGER REFERENCES photo,
    tag    VARCHAR(100)
);

CREATE TABLE attachment (
    id          INTEGER PRIMARY KEY,
    uploaded    INTEGER,
    page        INTEGER REFERENCES page,
    name        VARCHAR(100),
    size        INTEGER,
    contenttype VARCHAR(100)
);

CREATE TABLE photo (
    id          INTEGER PRIMARY KEY,
    title       TEXT,
    description TEXT,
    camera      TEXT,
    taken       INTEGER,
    iso         INTEGER,
    lens        TEXT, 
    aperture    TEXT,
    flash       TEXT,
    height      INT,
    width       INT 
);

CREATE TABLE comment (
    id       INTEGER PRIMARY KEY,
    poster   INT REFERENCES person,
    page     INT REFERENCES page,
    picture  INT REFERENCES photo,
    posted   INT,
    body     TEXT
);


CREATE TABLE journal (
    pageid          INTEGER PRIMARY KEY REFERENCES page,
    name            VARCHAR(100),
    dateformat      VARCHAR(20) DEFAULT '%F',
    defaultlocation VARCHAR(100)
);

CREATE TABLE entry (
    id       INTEGER PRIMARY KEY,
    journal  INT REFERENCES journal,
    author   INT REFERENCES person,
    title    VARCHAR(150),
    content  TEXT,
    posted   VARCHAR(100),
    location VARCHAR(100)
);

-- This needs to be fixed to work with latest schema

INSERT INTO person (login, name, active) VALUES ('AnonymousCoward','Anonymous Coward',1);
INSERT INTO person (login, name, active, pass) VALUES ('admin','Enoch Root',1,'admin');
INSERT INTO preference (prefkey, prefvalue) VALUES ('name','MojoMojo');
INSERT INTO preference (prefkey, prefvalue) VALUES ('admins','admin');
INSERT INTO page_version
(
 page,
 version,
 parent,
 parent_version,
 name,
 name_orig,
 depth,
 content_version_first,
 content_version_last,
 creator,
 created)
VALUES (1,1,NULL,NULL,'/','/',0,1,1,1,0);
INSERT INTO content (page,version,creator,created,body,status) VALUES(1,1,1,0,
'h1. Welcome to MojoMojo!

This is your front page. To start administrating your wiki, please log in with
username admin/password admin. At that point you will be able to set up your
configuration. If you want to play around a little with the wiki, just create
a NewPage or edit this one through the edit link at the bottom.

h2. Need some assistance?

Check out our [[Help]] section.','released');
INSERT INTO page (id,version,parent,name,name_orig,depth,lft,rgt,content_version) VALUES (1,1,NULL,'/','/',0,1,4,1);
INSERT INTO content (page,version,creator,created,body,status) VALUES(2,1,1,0,
'h1. Help Index.

* Editing Pages
* Formatter Syntax.
* Using Tags
* Attachments & Photos','released');

INSERT INTO page (id,version,parent,name,name_orig,depth,lft,rgt,content_version) VALUES (2,1,1,'help','Help',1,2,3,1);
