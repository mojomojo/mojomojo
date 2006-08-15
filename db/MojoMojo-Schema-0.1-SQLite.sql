BEGIN TRANSACTION;


DROP TABLE entry;
CREATE TABLE entry (
  id INTEGER PRIMARY KEY NOT NULL,
  journal INTEGER NOT NULL,
  author INTEGER NOT NULL,
  title VARCHAR(150) NOT NULL,
  content TEXT NOT NULL,
  posted VARCHAR(100) NOT NULL,
  location VARCHAR(100) NOT NULL
);


DROP TABLE preference;
CREATE TABLE preference (
  prefkey VARCHAR(100) NOT NULL,
  prefvalue VARCHAR(100),
  PRIMARY KEY (prefkey)
);


DROP TABLE wanted_page;
CREATE TABLE wanted_page (
  id INTEGER PRIMARY KEY NOT NULL,
  from_page INTEGER NOT NULL,
  to_path TEXT NOT NULL
);


DROP TABLE page;
CREATE TABLE page (
  id INTEGER PRIMARY KEY NOT NULL,
  version INTEGER NOT NULL,
  parent INTEGER NOT NULL,
  name VARCHAR(200) NOT NULL,
  name_orig VARCHAR(200) NOT NULL,
  depth INTEGER NOT NULL,
  lft INTEGER NOT NULL,
  rgt INTEGER NOT NULL,
  content_version INTEGER NOT NULL
);
CREATE UNIQUE INDEX page_unique_child_index_page on page (parent, name);


DROP TABLE person;
CREATE TABLE person (
  id INTEGER PRIMARY KEY NOT NULL,
  active INTEGER NOT NULL,
  registered BIGINT NOT NULL,
  views INTEGER NOT NULL,
  photo INTEGER NOT NULL,
  login VARCHAR(100) NOT NULL,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  pass VARCHAR(100) NOT NULL,
  timezone VARCHAR(100) NOT NULL,
  born BIGINT NOT NULL,
  gender CHAR(1) NOT NULL,
  occupation VARCHAR(100) NOT NULL,
  industry VARCHART(100) NOT NULL,
  interests TEXT NOT NULL,
  movies TEXT NOT NULL,
  music TEXT NOT NULL
);


DROP TABLE link;
CREATE TABLE link (
  id INTEGER PRIMARY KEY NOT NULL,
  from_page INTEGER NOT NULL,
  to_page INTEGER NOT NULL
);


DROP TABLE tag;
CREATE TABLE tag (
  id INTEGER PRIMARY KEY NOT NULL,
  person INTEGER NOT NULL,
  page INTEGER NOT NULL,
  photo INTEGER NOT NULL,
  tag VARCHAR(100) NOT NULL
);


DROP TABLE role_privilege;
CREATE TABLE role_privilege (
  page INTEGER NOT NULL,
  role INTEGER NOT NULL,
  privilege VARCHAR(20) NOT NULL,
  PRIMARY KEY (page, role, privilege)
);


DROP TABLE role;
CREATE TABLE role (
  id INTEGER PRIMARY KEY NOT NULL,
  name VARCHAR(200) NOT NULL,
  active INTEGER NOT NULL
);
CREATE UNIQUE INDEX name_unique_role on role (name);


DROP TABLE attachment;
CREATE TABLE attachment (
  id INTEGER PRIMARY KEY NOT NULL,
  uploaded BIGINT NOT NULL,
  page INTEGER NOT NULL,
  name VARCHAR(100) NOT NULL,
  size INTEGER NOT NULL,
  contenttype VARCHAR(100) NOT NULL
);


DROP TABLE comment;
CREATE TABLE comment (
  id INTEGER PRIMARY KEY NOT NULL,
  poster INTEGER NOT NULL,
  page INTEGER NOT NULL,
  picture INTEGER NOT NULL,
  posted BIGINT NOT NULL,
  body TEXT NOT NULL
);


DROP TABLE photo;
CREATE TABLE photo (
  id INTEGER PRIMARY KEY NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  camera TEXT NOT NULL,
  taken INTEGER NOT NULL,
  iso INTEGER NOT NULL,
  lens TEXT NOT NULL,
  aperture TEXT NOT NULL,
  flash TEXT NOT NULL,
  height INT NOT NULL,
  width INT NOT NULL
);


DROP TABLE role_member;
CREATE TABLE role_member (
  role INTEGER NOT NULL,
  person INTEGER NOT NULL,
  admin INTEGER NOT NULL,
  PRIMARY KEY (role, person)
);


DROP TABLE page_version;
CREATE TABLE page_version (
  page INTEGER NOT NULL,
  version INTEGER NOT NULL,
  parent INTEGER NOT NULL,
  parent_version INTEGER NOT NULL,
  name VARCHAR(200) NOT NULL,
  name_orig VARCHAR(200) NOT NULL,
  depth INTEGER NOT NULL,
  creator INTEGER NOT NULL,
  created VARCHAR(100) NOT NULL,
  status VARCHAR(20) NOT NULL,
  release_date VARCHAR(100) NOT NULL,
  remove_date VARCHAR(100) NOT NULL,
  comments TEXT NOT NULL,
  content_version_first INTEGER NOT NULL,
  content_version_last INTEGER NOT NULL,
  PRIMARY KEY (page, version)
);


DROP TABLE content;
CREATE TABLE content (
  page INTEGER NOT NULL,
  version INTEGER NOT NULL,
  creator INTEGER NOT NULL,
  created VARCHAR(100) NOT NULL,
  status VARCHAR(20) NOT NULL,
  release_date VARCHAR(100) NOT NULL,
  remove_date VARCHAR(100) NOT NULL,
  type VARCHAR(200) NOT NULL,
  abstract TEXT NOT NULL,
  comments TEXT NOT NULL,
  body TEXT NOT NULL,
  precompiled TEXT NOT NULL,
  PRIMARY KEY (page, version)
);


DROP TABLE journal;
CREATE TABLE journal (
  pageid INTEGER PRIMARY KEY NOT NULL,
  name VARCHAR(100) NOT NULL,
  dateformat VARCHAR(20) NOT NULL,
  defaultlocation VARCHAR(100) NOT NULL
);


COMMIT;
