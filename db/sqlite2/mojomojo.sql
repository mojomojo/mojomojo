CREATE TABLE page (
    id  INTEGER PRIMARY KEY,
    owner INTEGER REFERENCES user,
    node VARCHAR(30),
    revision INTEGER REFERENCES revision
    updated varchar(100),
    read text, write text, admin text
);

CREATE TABLE revision (
    id INTEGER PRIMARY KEY,
    page INTEGER,
    user INTEGER REFERENCES user,
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

INSERT INTO user (login, name) VALUES ('AnonymousCoward','Anonymous Coward');
INSERT INTO page (user,node,content,updated) VALUES ( 1,'FrontPage','testing
testing, hello, is this thing on?','1970-01-01T00:00:00');
