/* WARNING : THIS FILE IS SEVERELY OUT OF DATE */

create table Person
(
 id varchar2(30) primary key, 
 active    smallint default 1 not null /* fake boolean */
);

create table Role
(
 id integer primary key,
 name    varchar2(200) unique not null,
 active  smallint default 1 not null /* fake boolean */
);

create sequence RoleIdSeq start with 1;

create table Content (
 id          integer primary key,
 author      integer,
 updated     date not null,
 type        varchar2(200),
 abstract    varchar2(4000),
 body        blob,
 foreign key (author) references Person
);

-- Includes approval_status so that we don't need
-- to re-calculate it for every query.

create table Revision
(
 id              integer not null,
 version         integer default 1 not null,
 parent          integer null,
 parent_version  integer /*not null*/,
 name            varchar2(200),
 name_orig       varchar2(200),
 depth           integer /*not null*/,
 owner           integer not null,
 agent           varchar2(8) not null,
 updated         date default null,
 publish_date    date default null,
 expire_date     date default null,
 approval        varchar2(10),
 content         integer null,
 primary key (id, version),
 foreign key (parent_id, parent_version) references Revision(id, version),
 foreign key (owner) references Role,
 foreign key (agent) references Person,
 foreign key (content) references Content
);

-- For performance reasons, we denormalized current,
-- approved versions into this separate table.
-- (Maybe create a view instead? May be too slow for full-text search.)
-- Note: Names of a node's children must be unique!!!

create table Page
(
 id           integer primary key,
 version      integer default 1 not null,
 parent       integer null,
 name         varchar2(200),
 name_orig    varchar2(200),
 depth        integer /*not null*/,
 owner        integer not null,
 agent        varchar2(8) not null,
 updated      date not null,
 content      integer null,
 foreign key (parent_id) references Page,
 foreign key (owner) references Role,
 foreign key (modified_by) references Person,
 foreign key (content) references Content,
 foreign key (id, version) references Revision
);

create sequence NodeIdSeq start with 1;

-- Refers only to current, approved nodes. If link_to node does
-- not exist, link_to_id will be null and link_to_path must not be null.

create table InternalLink
(
 from_node_id   integer not null,
 to_node_id     integer default null,
 to_node_path   varchar2(2000) default null,
 foreign key (from_node_id) references Node
);

create index InternalLinkIndex on InternalLink (from_node_id);

create table Metadata
(
 node_id integer not null,
 type    varchar2(200) not null,
 value   varchar2(300) not null,
 foreign key (node_id) references Node(node_id)
);

create index MetadataIndex on Metadata (node_id,type,value);

create table MetadataVersion
(
 node_id      integer not null,
 node_version integer default 0 not null,
 type         varchar2(200) not null,
 value        varchar2(300) not null,
 foreign key (node_id,node_version) references NodeVersion(node_id,version)
);

create index MetadataVersionIndex on MetadataVersion (node_id,node_version,type,value);

create table RoleMember
(
 role_id integer,
 person_id  varchar2(8),
 admin    smallint default 0 not null,
 foreign key (role_id) references Role,
 foreign key (person_id) references Person,
 primary key (role_id,person_id)
);

create table RoleRights
(
 role         integer,
 page_id      integer,
 page_version integer,
 read         smallint default 0 not null,
 write        smallint default 0 not null,
 admin        smallint default 0 not null,
 foreign key (role) references Role,
 foreign key (page_id,page_version) references Revision(id,version),
 primary key (role,page_id,page_version)
);

-- Only possible sequences are: 'submitted'-'rejected'?-'approved'

create table NodeApproval
(
 node_id      integer,
 node_version integer,
 status       varchar2(10) not null,
 status_date  date,
 primary key (node_id,node_version,status),
 foreign key (node_id,node_version) references NodeVersion(node_id,version)
);

create table PersonNodeApproval
(
 node_id      integer,
 node_version integer,
 person_id    varchar2(8),
 status       varchar2(10) not null,
 status_date  date,
 primary key (node_id,node_version,status,person_id),
 foreign key (node_id,node_version) references NodeVersion(node_id,version),
 foreign key (person_id) references Person
);

create table RoleNodeApproval
(
 node_id      integer,
 node_version integer,
 role_id      integer,
 status       varchar2(10) not null,
 status_date  date,
 primary key (node_id,node_version,status,role_id),
 foreign key (node_id,node_version) references NodeVersion(node_id,version),
 foreign key (role_id) references Role
);

--the following lines were added so that we can insert nodes without violating table integrity constraints

-- Create a person:
INSERT INTO Person (person_id, active) VALUES ('naughton', 1);

-- Create an admin role:
INSERT INTO Role (role_id, name, active) VALUES ((select RoleIdSeq.nextval from dual), 'admin', 1);

-- Add a person to the admin role:
INSERT INTO RoleMember (role_id, person_id) VALUES (1,'naughton');

-- Create a root node:
INSERT INTO Node (node_id, name, search_name, depth, version, owner_role_id, modified_by, content, modified_date)
  VALUES ( (select NodeIdSeq.nextval from dual), '/', '/', 0, 1, 1, 'naughton', rawtohex('Welcome to MojoMojo!'), to_date('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') );

INSERT INTO NodeVersion (node_id, name, search_name, depth, version, owner_role_id, modified_by, content, modified_date)
  VALUES ( 1, '/', '/', 0, 1, 1, 'naughton', rawtohex('Welcome to MojoMojo!'), to_date('1970-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS') );







