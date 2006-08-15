SET foreign_key_checks=0;

DROP TABLE IF EXISTS entry;
CREATE TABLE entry (
  id INTEGER NOT NULL auto_increment,
  journal INTEGER NOT NULL,
  author INTEGER NOT NULL,
  title VARCHAR(150) NOT NULL,
  content text NOT NULL,
  posted VARCHAR(100) NOT NULL,
  location VARCHAR(100) NOT NULL,
  INDEX (id),
  INDEX (author),
  INDEX (journal),
  PRIMARY KEY (id),
  CONSTRAINT entry_fk_author FOREIGN KEY (author) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT entry_fk_journal FOREIGN KEY (journal) REFERENCES journal (pageid) ON DELETE CASCADE ON UPDATE CASCADE
) Type=InnoDB;

DROP TABLE IF EXISTS preference;
CREATE TABLE preference (
  prefkey VARCHAR(100) NOT NULL,
  prefvalue VARCHAR(100),
  INDEX (prefkey),
  PRIMARY KEY (prefkey)
);

DROP TABLE IF EXISTS wanted_page;
CREATE TABLE wanted_page (
  id INTEGER NOT NULL auto_increment,
  from_page INTEGER NOT NULL,
  to_path text NOT NULL,
  INDEX (id),
  INDEX (from_page),
  PRIMARY KEY (id),
  CONSTRAINT wanted_page_fk_from_page FOREIGN KEY (from_page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE
) Type=InnoDB;

DROP TABLE IF EXISTS page;
CREATE TABLE page (
  id INTEGER NOT NULL auto_increment,
  version INTEGER NOT NULL,
  parent INTEGER NOT NULL,
  name VARCHAR(200) NOT NULL,
  name_orig VARCHAR(200) NOT NULL,
  depth INTEGER NOT NULL,
  lft INTEGER NOT NULL,
  rgt INTEGER NOT NULL,
  content_version INTEGER NOT NULL,
  INDEX (id),
  INDEX (parent),
  INDEX (content_version),
  INDEX (version),
  PRIMARY KEY (id),
  UNIQUE page_unique_child_index (parent, name),
  CONSTRAINT page_fk_parent FOREIGN KEY (parent) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT page_fk_content_version FOREIGN KEY (content_version, id) REFERENCES content (version, page) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT page_fk_version FOREIGN KEY (version, id) REFERENCES page_version (version, page) ON DELETE CASCADE ON UPDATE CASCADE
) Type=InnoDB;

DROP TABLE IF EXISTS person;
CREATE TABLE person (
  id INTEGER NOT NULL auto_increment,
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
  interests text NOT NULL,
  movies text NOT NULL,
  music text NOT NULL,
  INDEX (id),
  PRIMARY KEY (id)
) Type=InnoDB;

DROP TABLE IF EXISTS link;
CREATE TABLE link (
  id INTEGER NOT NULL auto_increment,
  from_page INTEGER NOT NULL,
  to_page INTEGER NOT NULL,
  INDEX (id),
  INDEX (from_page),
  INDEX (to_page),
  PRIMARY KEY (id),
  CONSTRAINT link_fk_from_page FOREIGN KEY (from_page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT link_fk_to_page FOREIGN KEY (to_page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE
) Type=InnoDB;

DROP TABLE IF EXISTS tag;
CREATE TABLE tag (
  id INTEGER NOT NULL auto_increment,
  person INTEGER NOT NULL,
  page INTEGER NOT NULL,
  photo INTEGER NOT NULL,
  tag VARCHAR(100) NOT NULL,
  INDEX (id),
  INDEX (page),
  INDEX (person),
  INDEX (photo),
  PRIMARY KEY (id),
  CONSTRAINT tag_fk_page FOREIGN KEY (page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT tag_fk_person FOREIGN KEY (person) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT tag_fk_photo FOREIGN KEY (photo) REFERENCES photo (id) ON DELETE CASCADE ON UPDATE CASCADE
) Type=InnoDB;

DROP TABLE IF EXISTS role_privilege;
CREATE TABLE role_privilege (
  page INTEGER NOT NULL,
  role INTEGER NOT NULL,
  privilege VARCHAR(20) NOT NULL,
  INDEX (page),
  INDEX (role),
  PRIMARY KEY (page, role, privilege),
  CONSTRAINT role_privilege_fk_page FOREIGN KEY (page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT role_privilege_fk_role FOREIGN KEY (role) REFERENCES role (id) ON DELETE CASCADE ON UPDATE CASCADE
) Type=InnoDB;

DROP TABLE IF EXISTS role;
CREATE TABLE role (
  id INTEGER NOT NULL auto_increment,
  name VARCHAR(200) NOT NULL,
  active INTEGER NOT NULL,
  INDEX (id),
  INDEX (name),
  PRIMARY KEY (id),
  UNIQUE name_unique (name)
) Type=InnoDB;

DROP TABLE IF EXISTS attachment;
CREATE TABLE attachment (
  id INTEGER NOT NULL auto_increment,
  uploaded BIGINT NOT NULL,
  page INTEGER NOT NULL,
  name VARCHAR(100) NOT NULL,
  size INTEGER NOT NULL,
  contenttype VARCHAR(100) NOT NULL,
  INDEX (id),
  INDEX (page),
  PRIMARY KEY (id),
  CONSTRAINT attachment_fk_page FOREIGN KEY (page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE
) Type=InnoDB;

DROP TABLE IF EXISTS comment;
CREATE TABLE comment (
  id INTEGER NOT NULL auto_increment,
  poster INTEGER NOT NULL,
  page INTEGER NOT NULL,
  picture INTEGER NOT NULL,
  posted BIGINT NOT NULL,
  body text NOT NULL,
  INDEX (id),
  INDEX (page),
  INDEX (poster),
  INDEX (picture),
  PRIMARY KEY (id),
  CONSTRAINT comment_fk_page FOREIGN KEY (page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT comment_fk_poster FOREIGN KEY (poster) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT comment_fk_picture FOREIGN KEY (picture) REFERENCES photo (id) ON DELETE CASCADE ON UPDATE CASCADE
) Type=InnoDB;

DROP TABLE IF EXISTS photo;
CREATE TABLE photo (
  id INTEGER NOT NULL auto_increment,
  title text NOT NULL,
  description text NOT NULL,
  camera text NOT NULL,
  taken INTEGER NOT NULL,
  iso INTEGER NOT NULL,
  lens text NOT NULL,
  aperture text NOT NULL,
  flash text NOT NULL,
  height integer NOT NULL,
  width integer NOT NULL,
  INDEX (id),
  PRIMARY KEY (id)
) Type=InnoDB;

DROP TABLE IF EXISTS role_member;
CREATE TABLE role_member (
  role INTEGER NOT NULL,
  person INTEGER NOT NULL,
  admin INTEGER NOT NULL,
  INDEX (role),
  INDEX (person),
  PRIMARY KEY (role, person),
  CONSTRAINT role_member_fk_person FOREIGN KEY (person) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT role_member_fk_role FOREIGN KEY (role) REFERENCES role (id) ON DELETE CASCADE ON UPDATE CASCADE
) Type=InnoDB;

DROP TABLE IF EXISTS page_version;
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
  comments text NOT NULL,
  content_version_first INTEGER NOT NULL,
  content_version_last INTEGER NOT NULL,
  INDEX (page),
  INDEX (creator),
  INDEX (content_version_last),
  INDEX (parent_version),
  PRIMARY KEY (page, version),
  CONSTRAINT page_version_fk_creator FOREIGN KEY (creator) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT page_version_fk_page FOREIGN KEY (page) REFERENCES page (page),
  CONSTRAINT page_version_fk_content_version_last FOREIGN KEY (content_version_last, page) REFERENCES content (version, page) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT page_version_fk_parent_version FOREIGN KEY (parent_version, parent) REFERENCES page_version (version, page) ON DELETE CASCADE ON UPDATE CASCADE
) Type=InnoDB;

DROP TABLE IF EXISTS content;
CREATE TABLE content (
  page INTEGER NOT NULL,
  version INTEGER NOT NULL,
  creator INTEGER NOT NULL,
  created VARCHAR(100) NOT NULL,
  status VARCHAR(20) NOT NULL,
  release_date VARCHAR(100) NOT NULL,
  remove_date VARCHAR(100) NOT NULL,
  type VARCHAR(200) NOT NULL,
  abstract text NOT NULL,
  comments text NOT NULL,
  body text NOT NULL,
  precompiled text NOT NULL,
  INDEX (page),
  INDEX (creator),
  PRIMARY KEY (page, version),
  CONSTRAINT content_fk_creator FOREIGN KEY (creator) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT content_fk_page FOREIGN KEY (page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE
) Type=InnoDB;

DROP TABLE IF EXISTS journal;
CREATE TABLE journal (
  pageid INTEGER NOT NULL,
  name VARCHAR(100) NOT NULL,
  dateformat VARCHAR(20) NOT NULL,
  defaultlocation VARCHAR(100) NOT NULL,
  INDEX (pageid),
  PRIMARY KEY (pageid)
) Type=InnoDB;

SET foreign_key_checks=1;

