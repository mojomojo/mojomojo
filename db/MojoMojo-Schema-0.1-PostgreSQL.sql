DROP TABLE "entry";
CREATE TABLE "entry" (
  "id" serial NOT NULL,
  "journal" integer NOT NULL,
  "author" integer NOT NULL,
  "title" character varying(150) NOT NULL,
  "content" text NOT NULL,
  "posted" character varying(100) NOT NULL,
  "location" character varying(100) NOT NULL,
  PRIMARY KEY ("id")
);



DROP TABLE "preference";
CREATE TABLE "preference" (
  "prefkey" character varying(100) NOT NULL,
  "prefvalue" character varying(100),
  PRIMARY KEY ("prefkey")
);



DROP TABLE "wanted_page";
CREATE TABLE "wanted_page" (
  "id" serial NOT NULL,
  "from_page" integer NOT NULL,
  "to_path" text NOT NULL,
  PRIMARY KEY ("id")
);



DROP TABLE "page";
CREATE TABLE "page" (
  "id" serial NOT NULL,
  "version" integer NOT NULL,
  "parent" integer NOT NULL,
  "name" character varying(200) NOT NULL,
  "name_orig" character varying(200) NOT NULL,
  "depth" integer NOT NULL,
  "lft" integer NOT NULL,
  "rgt" integer NOT NULL,
  "content_version" integer NOT NULL,
  PRIMARY KEY ("id"),
  Constraint "page_unique_child_index" UNIQUE ("parent", "name")
);



DROP TABLE "person";
CREATE TABLE "person" (
  "id" serial NOT NULL,
  "active" integer NOT NULL,
  "registered" bigint NOT NULL,
  "views" integer NOT NULL,
  "photo" integer NOT NULL,
  "login" character varying(100) NOT NULL,
  "name" character varying(100) NOT NULL,
  "email" character varying(100) NOT NULL,
  "pass" character varying(100) NOT NULL,
  "timezone" character varying(100) NOT NULL,
  "born" bigint NOT NULL,
  "gender" character(1) NOT NULL,
  "occupation" character varying(100) NOT NULL,
  "industry" varchart(100) NOT NULL,
  "interests" text NOT NULL,
  "movies" text NOT NULL,
  "music" text NOT NULL,
  PRIMARY KEY ("id")
);



DROP TABLE "link";
CREATE TABLE "link" (
  "id" serial NOT NULL,
  "from_page" integer NOT NULL,
  "to_page" integer NOT NULL,
  PRIMARY KEY ("id")
);



DROP TABLE "tag";
CREATE TABLE "tag" (
  "id" serial NOT NULL,
  "person" integer NOT NULL,
  "page" integer NOT NULL,
  "photo" integer NOT NULL,
  "tag" character varying(100) NOT NULL,
  PRIMARY KEY ("id")
);



DROP TABLE "role_privilege";
CREATE TABLE "role_privilege" (
  "page" integer NOT NULL,
  "role" integer NOT NULL,
  "privilege" character varying(20) NOT NULL,
  PRIMARY KEY ("page", "role", "privilege")
);



DROP TABLE "role";
CREATE TABLE "role" (
  "id" serial NOT NULL,
  "name" character varying(200) NOT NULL,
  "active" integer NOT NULL,
  PRIMARY KEY ("id"),
  Constraint "name_unique" UNIQUE ("name")
);



DROP TABLE "attachment";
CREATE TABLE "attachment" (
  "id" serial NOT NULL,
  "uploaded" bigint NOT NULL,
  "page" integer NOT NULL,
  "name" character varying(100) NOT NULL,
  "size" integer NOT NULL,
  "contenttype" character varying(100) NOT NULL,
  PRIMARY KEY ("id")
);



DROP TABLE "comment";
CREATE TABLE "comment" (
  "id" serial NOT NULL,
  "poster" integer NOT NULL,
  "page" integer NOT NULL,
  "picture" integer NOT NULL,
  "posted" bigint NOT NULL,
  "body" text NOT NULL,
  PRIMARY KEY ("id")
);



DROP TABLE "photo";
CREATE TABLE "photo" (
  "id" serial NOT NULL,
  "title" text NOT NULL,
  "description" text NOT NULL,
  "camera" text NOT NULL,
  "taken" integer NOT NULL,
  "iso" integer NOT NULL,
  "lens" text NOT NULL,
  "aperture" text NOT NULL,
  "flash" text NOT NULL,
  "height" integer NOT NULL,
  "width" integer NOT NULL,
  PRIMARY KEY ("id")
);



DROP TABLE "role_member";
CREATE TABLE "role_member" (
  "role" integer NOT NULL,
  "person" integer NOT NULL,
  "admin" integer NOT NULL,
  PRIMARY KEY ("role", "person")
);



DROP TABLE "page_version";
CREATE TABLE "page_version" (
  "page" integer NOT NULL,
  "version" integer NOT NULL,
  "parent" integer NOT NULL,
  "parent_version" integer NOT NULL,
  "name" character varying(200) NOT NULL,
  "name_orig" character varying(200) NOT NULL,
  "depth" integer NOT NULL,
  "creator" integer NOT NULL,
  "created" character varying(100) NOT NULL,
  "status" character varying(20) NOT NULL,
  "release_date" character varying(100) NOT NULL,
  "remove_date" character varying(100) NOT NULL,
  "comments" text NOT NULL,
  "content_version_first" integer NOT NULL,
  "content_version_last" integer NOT NULL,
  PRIMARY KEY ("page", "version")
);



DROP TABLE "content";
CREATE TABLE "content" (
  "page" integer NOT NULL,
  "version" integer NOT NULL,
  "creator" integer NOT NULL,
  "created" character varying(100) NOT NULL,
  "status" character varying(20) NOT NULL,
  "release_date" character varying(100) NOT NULL,
  "remove_date" character varying(100) NOT NULL,
  "type" character varying(200) NOT NULL,
  "abstract" text NOT NULL,
  "comments" text NOT NULL,
  "body" text NOT NULL,
  "precompiled" text NOT NULL,
  PRIMARY KEY ("page", "version")
);



DROP TABLE "journal";
CREATE TABLE "journal" (
  "pageid" integer NOT NULL,
  "name" character varying(100) NOT NULL,
  "dateformat" character varying(20) NOT NULL,
  "defaultlocation" character varying(100) NOT NULL,
  PRIMARY KEY ("pageid")
);

ALTER TABLE "entry" ADD FOREIGN KEY ("author")
  REFERENCES "person" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "entry" ADD FOREIGN KEY ("journal")
  REFERENCES "journal" ("pageid") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "wanted_page" ADD FOREIGN KEY ("from_page")
  REFERENCES "page" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "page" ADD FOREIGN KEY ("parent")
  REFERENCES "page" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "page" ADD FOREIGN KEY ("content_version", "id")
  REFERENCES "content" ("version", "page") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "page" ADD FOREIGN KEY ("version", "id")
  REFERENCES "page_version" ("version", "page") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "link" ADD FOREIGN KEY ("from_page")
  REFERENCES "page" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "link" ADD FOREIGN KEY ("to_page")
  REFERENCES "page" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "tag" ADD FOREIGN KEY ("page")
  REFERENCES "page" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "tag" ADD FOREIGN KEY ("person")
  REFERENCES "person" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "tag" ADD FOREIGN KEY ("photo")
  REFERENCES "photo" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "role_privilege" ADD FOREIGN KEY ("page")
  REFERENCES "page" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "role_privilege" ADD FOREIGN KEY ("role")
  REFERENCES "role" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "attachment" ADD FOREIGN KEY ("page")
  REFERENCES "page" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "comment" ADD FOREIGN KEY ("page")
  REFERENCES "page" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "comment" ADD FOREIGN KEY ("poster")
  REFERENCES "person" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "comment" ADD FOREIGN KEY ("picture")
  REFERENCES "photo" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "role_member" ADD FOREIGN KEY ("person")
  REFERENCES "person" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "role_member" ADD FOREIGN KEY ("role")
  REFERENCES "role" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "page_version" ADD FOREIGN KEY ("creator")
  REFERENCES "person" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "page_version" ADD FOREIGN KEY ("page")
  REFERENCES "page" ("page");

ALTER TABLE "page_version" ADD FOREIGN KEY ("content_version_last", "page")
  REFERENCES "content" ("version", "page") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "page_version" ADD FOREIGN KEY ("parent_version", "parent")
  REFERENCES "page_version" ("version", "page") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "content" ADD FOREIGN KEY ("creator")
  REFERENCES "person" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "content" ADD FOREIGN KEY ("page")
  REFERENCES "page" ("id") ON DELETE CASCADE ON UPDATE CASCADE;