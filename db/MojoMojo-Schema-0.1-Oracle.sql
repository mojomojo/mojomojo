DROP TABLE entry;
CREATE TABLE entry (
  id number NOT NULL,
  journal number NOT NULL,
  author number NOT NULL,
  title varchar2(150) NOT NULL,
  content clob NOT NULL,
  posted varchar2(100) NOT NULL,
  location varchar2(100) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_author FOREIGN KEY (author) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_journal FOREIGN KEY (journal) REFERENCES journal (pageid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE SEQUENCE sq_entry_id;
CREATE OR REPLACE TRIGGER ai_entry_id
BEFORE INSERT ON entry
FOR EACH ROW WHEN (
 new.id IS NULL OR new.id = 0
)
BEGIN
 SELECT sq_entry_id.nextval
 INTO :new.id
 FROM dual;
END;
/

DROP TABLE preference;
CREATE TABLE preference (
  prefkey varchar2(100) NOT NULL,
  prefvalue varchar2(100),
  PRIMARY KEY (prefkey)
);

DROP TABLE wanted_page;
CREATE TABLE wanted_page (
  id number NOT NULL,
  from_page number NOT NULL,
  to_path clob NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_from_page FOREIGN KEY (from_page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE SEQUENCE sq_wanted_page_id;
CREATE OR REPLACE TRIGGER ai_wanted_page_id
BEFORE INSERT ON wanted_page
FOR EACH ROW WHEN (
 new.id IS NULL OR new.id = 0
)
BEGIN
 SELECT sq_wanted_page_id.nextval
 INTO :new.id
 FROM dual;
END;
/

DROP TABLE page;
CREATE TABLE page (
  id number NOT NULL,
  version number NOT NULL,
  parent number NOT NULL,
  name varchar2(200) NOT NULL,
  name_orig varchar2(200) NOT NULL,
  depth number NOT NULL,
  lft number NOT NULL,
  rgt number NOT NULL,
  content_version number NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT page_unique_child_index UNIQUE (parent, name),
  CONSTRAINT fk_parent FOREIGN KEY (parent) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_content_version FOREIGN KEY (content_version, id) REFERENCES content (version, page) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_version FOREIGN KEY (version, id) REFERENCES page_version (version, page) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE SEQUENCE sq_page_id;
CREATE OR REPLACE TRIGGER ai_page_id
BEFORE INSERT ON page
FOR EACH ROW WHEN (
 new.id IS NULL OR new.id = 0
)
BEGIN
 SELECT sq_page_id.nextval
 INTO :new.id
 FROM dual;
END;
/

DROP TABLE person;
CREATE TABLE person (
  id number NOT NULL,
  active number NOT NULL,
  registered number NOT NULL,
  views number NOT NULL,
  photo number NOT NULL,
  login varchar2(100) NOT NULL,
  name varchar2(100) NOT NULL,
  email varchar2(100) NOT NULL,
  pass varchar2(100) NOT NULL,
  timezone varchar2(100) NOT NULL,
  born number NOT NULL,
  gender char(1) NOT NULL,
  occupation varchar2(100) NOT NULL,
  industry varchart(100) NOT NULL,
  interests clob NOT NULL,
  movies clob NOT NULL,
  music clob NOT NULL,
  PRIMARY KEY (id)
);

CREATE SEQUENCE sq_person_id;
CREATE OR REPLACE TRIGGER ai_person_id
BEFORE INSERT ON person
FOR EACH ROW WHEN (
 new.id IS NULL OR new.id = 0
)
BEGIN
 SELECT sq_person_id.nextval
 INTO :new.id
 FROM dual;
END;
/

DROP TABLE link;
CREATE TABLE link (
  id number NOT NULL,
  from_page number NOT NULL,
  to_page number NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_from_page FOREIGN KEY (from_page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_to_page FOREIGN KEY (to_page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE SEQUENCE sq_link_id;
CREATE OR REPLACE TRIGGER ai_link_id
BEFORE INSERT ON link
FOR EACH ROW WHEN (
 new.id IS NULL OR new.id = 0
)
BEGIN
 SELECT sq_link_id.nextval
 INTO :new.id
 FROM dual;
END;
/

DROP TABLE tag;
CREATE TABLE tag (
  id number NOT NULL,
  person number NOT NULL,
  page number NOT NULL,
  photo number NOT NULL,
  tag varchar2(100) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_page FOREIGN KEY (page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_person FOREIGN KEY (person) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_photo FOREIGN KEY (photo) REFERENCES photo (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE SEQUENCE sq_tag_id;
CREATE OR REPLACE TRIGGER ai_tag_id
BEFORE INSERT ON tag
FOR EACH ROW WHEN (
 new.id IS NULL OR new.id = 0
)
BEGIN
 SELECT sq_tag_id.nextval
 INTO :new.id
 FROM dual;
END;
/

DROP TABLE role_privilege;
CREATE TABLE role_privilege (
  page number NOT NULL,
  role number NOT NULL,
  privilege varchar2(20) NOT NULL,
  PRIMARY KEY (page, role, privilege),
  CONSTRAINT fk_page FOREIGN KEY (page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_role FOREIGN KEY (role) REFERENCES role (id) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE role;
CREATE TABLE role (
  id number NOT NULL,
  name varchar2(200) NOT NULL,
  active number NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT name_unique UNIQUE (name)
);

CREATE SEQUENCE sq_role_id;
CREATE OR REPLACE TRIGGER ai_role_id
BEFORE INSERT ON role
FOR EACH ROW WHEN (
 new.id IS NULL OR new.id = 0
)
BEGIN
 SELECT sq_role_id.nextval
 INTO :new.id
 FROM dual;
END;
/

DROP TABLE attachment;
CREATE TABLE attachment (
  id number NOT NULL,
  uploaded number NOT NULL,
  page number NOT NULL,
  name varchar2(100) NOT NULL,
  size_ number NOT NULL,
  contenttype varchar2(100) NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_page FOREIGN KEY (page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE SEQUENCE sq_attachment_id;
CREATE OR REPLACE TRIGGER ai_attachment_id
BEFORE INSERT ON attachment
FOR EACH ROW WHEN (
 new.id IS NULL OR new.id = 0
)
BEGIN
 SELECT sq_attachment_id.nextval
 INTO :new.id
 FROM dual;
END;
/

DROP TABLE comment_;
CREATE TABLE comment_ (
  id number NOT NULL,
  poster number NOT NULL,
  page number NOT NULL,
  picture number NOT NULL,
  posted number NOT NULL,
  body clob NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_page FOREIGN KEY (page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_poster FOREIGN KEY (poster) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_picture FOREIGN KEY (picture) REFERENCES photo (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE SEQUENCE sq_comment__id;
CREATE OR REPLACE TRIGGER ai_comment__id
BEFORE INSERT ON comment_
FOR EACH ROW WHEN (
 new.id IS NULL OR new.id = 0
)
BEGIN
 SELECT sq_comment__id.nextval
 INTO :new.id
 FROM dual;
END;
/

DROP TABLE photo;
CREATE TABLE photo (
  id number NOT NULL,
  title clob NOT NULL,
  description clob NOT NULL,
  camera clob NOT NULL,
  taken number NOT NULL,
  iso number NOT NULL,
  lens clob NOT NULL,
  aperture clob NOT NULL,
  flash clob NOT NULL,
  height number NOT NULL,
  width number NOT NULL,
  PRIMARY KEY (id)
);

CREATE SEQUENCE sq_photo_id;
CREATE OR REPLACE TRIGGER ai_photo_id
BEFORE INSERT ON photo
FOR EACH ROW WHEN (
 new.id IS NULL OR new.id = 0
)
BEGIN
 SELECT sq_photo_id.nextval
 INTO :new.id
 FROM dual;
END;
/

DROP TABLE role_member;
CREATE TABLE role_member (
  role number NOT NULL,
  person number NOT NULL,
  admin number NOT NULL,
  PRIMARY KEY (role, person),
  CONSTRAINT fk_person FOREIGN KEY (person) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_role FOREIGN KEY (role) REFERENCES role (id) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE page_version;
CREATE TABLE page_version (
  page number NOT NULL,
  version number NOT NULL,
  parent number NOT NULL,
  parent_version number NOT NULL,
  name varchar2(200) NOT NULL,
  name_orig varchar2(200) NOT NULL,
  depth number NOT NULL,
  creator number NOT NULL,
  created varchar2(100) NOT NULL,
  status varchar2(20) NOT NULL,
  release_date varchar2(100) NOT NULL,
  remove_date varchar2(100) NOT NULL,
  comments clob NOT NULL,
  content_version_first number NOT NULL,
  content_version_last number NOT NULL,
  PRIMARY KEY (page, version),
  CONSTRAINT fk_creator FOREIGN KEY (creator) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_page FOREIGN KEY (page) REFERENCES page (page),
  CONSTRAINT fk_content_version_last FOREIGN KEY (content_version_last, page) REFERENCES content (version, page) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_parent_version FOREIGN KEY (parent_version, parent) REFERENCES page_version (version, page) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE content;
CREATE TABLE content (
  page number NOT NULL,
  version number NOT NULL,
  creator number NOT NULL,
  created varchar2(100) NOT NULL,
  status varchar2(20) NOT NULL,
  release_date varchar2(100) NOT NULL,
  remove_date varchar2(100) NOT NULL,
  type varchar2(200) NOT NULL,
  abstract clob NOT NULL,
  comments clob NOT NULL,
  body clob NOT NULL,
  precompiled clob NOT NULL,
  PRIMARY KEY (page, version),
  CONSTRAINT fk_creator FOREIGN KEY (creator) REFERENCES person (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_page FOREIGN KEY (page) REFERENCES page (id) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE journal;
CREATE TABLE journal (
  pageid number NOT NULL,
  name varchar2(100) NOT NULL,
  dateformat varchar2(20) NOT NULL,
  defaultlocation varchar2(100) NOT NULL,
  PRIMARY KEY (pageid)
);

