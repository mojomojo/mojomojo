CREATE TABLE content (
    id INTEGER PRIMARY KEY,
    modified_by INTEGER REFERENCES user,
    modified_date VARCHAR(100),
    type VARCHAR(200),
    content TEXT
);

CREATE TABLE revision (
    id INTEGER,
    version INTEGER,
    parent INTEGER,
    parent_version INTEGER,
    depth INTEGER,
    name VARCHAR(200),
    name_orig VARCHAR(200),
    owner INTEGER REFERENCES user,
    modified_by INTEGER REFERENCES user,
    modified_date VARCHAR(100),
    content INTEGER REFERENCES content,
    PRIMARY KEY (id, version),
    FOREIGN KEY (parent, parent_version) REFERENCES revision
);

CREATE TABLE page (
    id  INTEGER PRIMARY KEY,
    version INTEGER,
    parent INTEGER REFERENCES page,
    depth INTEGER,
    name VARCHAR(200),
    name_orig VARCHAR(200),
    owner INTEGER REFERENCES user,
    modified_by INTEGER REFERENCES user,
    modified_date VARCHAR(100),
    content INTEGER REFERENCES content,
    FOREIGN KEY (id, version) REFERENCES revision
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
    size int,
    contenttype varchar(100)
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
INSERT INTO content (modified_by,modified_date,content) VALUES(1,'1970-01-01T00:00:00','testing testing, hello, is this thing on?');
INSERT INTO revision (version,content,modified_by,modified_date) VALUES(1,1,1,'1970-01-01T00:00:00');
INSERT INTO page (owner,name,content) VALUES ( 1,'FrontPage',1);

