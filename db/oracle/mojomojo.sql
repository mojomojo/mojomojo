create table Person
(
 person_id varchar2(30) primary key, 
 active    smallint default 1 not null /* fake boolean */
);

create table Role
(
 role_id integer primary key,
 name    varchar2(200) unique not null,
 active  smallint default 1 not null /* fake boolean */
);

create sequence RoleIdSeq start with 1;

-- For performance reasons, we denormalized current,
-- approved versions into this separate table.
-- (Maybe create a view instead? May be too slow for full-text search.)
-- Note: Names of a node's children must be unique!!!

create table Node
(
 node_id         integer not null,
 parent_id       integer null,
 name            varchar2(200),
 search_name     varchar2(200),
 depth           integer /*not null*/,
 version         integer default 1 not null,
 owner_role_id   integer not null,
 modified_by     varchar2(8) not null,
 modified_date   date not null,
 release_date    date /*not null*/,
 expiration_date date default null,
 short_descr     varchar2(300),
 long_descr      varchar2(2000),
 mime_type	 varchar2(100) /*not null*/,
 content         clob,
 primary key (node_id),
 foreign key (parent_id) references Node,
 foreign key (owner_role_id) references Role,
 foreign key (modified_by) references Person
);

create sequence NodeIdSeq start with 1;

-- Includes approval_status so that we don't need
-- to re-calculate it for every query.

create table NodeVersion
(
 node_id         integer not null,
 parent_id       integer null,
 parent_version  integer /*not null*/,
 name            varchar2(200),
 search_name     varchar2(200),
 depth           integer /*not null*/,
 version         integer default 1 not null,
 owner_role_id   integer not null,
 modified_by     varchar2(8) not null,
 modified_date   date default null,
 release_date    date default null,
 expiration_date date default null,
 approval_status varchar2(10),
 comments        varchar2(2000) default null,
 short_descr     varchar2(300),
 long_descr      varchar2(2000),
 mime_type       varchar2(100) /*not null*/,
 content         clob,
 primary key (node_id, version),
 foreign key (parent_id,parent_version) references NodeVersion(node_id, version),
 foreign key (owner_role_id) references Role,
 foreign key (modified_by) references Person
);

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

create table RoleNodeRights
(
 role_id          integer,
 node_id          integer,
 node_version     integer,
 read_node        smallint default 0 not null,
 modify_node      smallint default 0 not null,
 create_node      smallint default 0 not null,
 rename_node      smallint default 0 not null,
 delete_node      smallint default 0 not null,
 admin_node       smallint default 0 not null,
 approve_node     smallint default 0 not null,
 approval_priority integer,
 foreign key (role_id) references Role,
 foreign key (node_id,node_version) references NodeVersion(node_id,version),
 primary key (role_id,node_id)
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







