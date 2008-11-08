# This Makefile is for the MojoMojo extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.46 (Revision: 66493) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#
#   MakeMaker Parameters:

#     ABSTRACT => q[A Catalyst & DBIx::Class powered Wiki.]
#     AUTHOR => q[Marcus Ramberg C<marcus@nordaaker.com>]
#     DIR => []
#     DISTNAME => q[MojoMojo]
#     EXE_FILES => [q[script/hash_passwords.pl], q[script/mojomojo_cgi.pl], q[script/mojomojo_create.pl], q[script/mojomojo_fastcgi.pl], q[script/mojomojo_fcgi.pl], q[script/mojomojo_server.pl], q[script/mojomojo_spawn_db.pl], q[script/mojomojo_test.pl], q[script/search_query.pl]]
#     NAME => q[MojoMojo]
#     NO_META => q[1]
#     PL_FILES => {  }
#     PREREQ_PM => { Pod::Simple::HTML=>q[3.01], DateTime=>q[0.28], YAML=>q[0.36], Template::Plugin::JavaScript=>q[0], Image::Math::Constrain=>q[0], Archive::Zip=>q[1.14], HTML::TagCloud=>q[0], DBIx::Class::HTML::FormFu=>q[0], Catalyst::Plugin::Singleton=>q[0.02], Catalyst::Plugin::ConfigLoader=>q[0.13], Catalyst::Plugin::Session::State::Cookie=>q[0], Config::General=>q[0], Catalyst=>q[5.7000], File::MMagic=>q[1.27], Catalyst::Authentication::Store::DBIx::Class=>q[0.101], DBIx::Class::EncodedColumn=>q[0], Catalyst::View::TT=>q[0.23], ExtUtils::MakeMaker=>q[6.46], URI::Fetch=>q[0], DateTime::Format::Mail=>q[0], Catalyst::Plugin::Session::Store::File=>q[0], Text::Password::Pronounceable=>q[0], Catalyst::Model::DBIC::Schema=>q[0.01], HTML::Strip=>q[1.04], Catalyst::Plugin::FillInForm=>q[0.04], Data::FormValidator::Constraints::DateTime=>q[0], IO::Scalar=>q[0], HTML::Scrubber=>q[0], DBD::SQLite=>q[1.08], Module::Pluggable::Ordered=>q[1.4], Cache::Memory=>q[0], Catalyst::Plugin::Cache::Store::Memory=>q[0], Catalyst::Plugin::SubRequest=>q[0.09], Catalyst::Controller::HTML::FormFu=>q[0.02000], DBIx::Class=>q[0.08], Text::Context=>q[3.5], LWP::Simple=>q[0], KinoSearch=>q[0], Algorithm::Diff=>q[1.1901], Moose=>q[0], Catalyst::Plugin::Email=>q[0], Catalyst::Plugin::UploadProgress=>q[0], URI=>q[1.35], Catalyst::Plugin::Static::Simple=>q[0.07], Imager=>q[0], XML::Clean=>q[0], Catalyst::Action::RenderView=>q[0.07], Data::Page=>q[2.00], Catalyst::Plugin::Unicode=>q[0.8], String::Diff=>q[0], Image::ExifTool=>q[0], Catalyst::Plugin::I18N=>q[0], Catalyst::Plugin::Authentication=>q[0.10005], Catalyst::Plugin::FormValidator=>q[0.02], DBIx::Class::DateTime::Epoch=>q[0] }
#     VERSION => q[0.999021]
#     dist => { PREOP=>q[$(PERL) -I. "-MModule::Install::Admin" -e "dist_preop(q($(DISTVNAME)))"] }
#     test => { TESTS=>q[t/01app.t t/02pod.t t/03podcoverage.t t/formatter_comment.t t/formatter_include.t t/formatter_irclog.t t/formatter_redirect.t t/formatter_wiki.t t/schema_DBIC.t t/schema_DBIC_Attachment.t t/schema_DBIC_Content.t t/schema_DBIC_Page.t t/schema_DBIC_Person.t t/schema_DBIC_Tag.t t/selenium.t t/c/attachment.t t/c/comment.t t/c/journal.t t/c/jsrpc.t t/c/page.t t/c/page_edit.t t/c/user.t] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /System/Library/Perl/5.8.8/darwin-thread-multi-2level/Config.pm).
# They may have been overridden via Makefile.PL or on the command line.
AR = ar
CC = cc
CCCDLFLAGS =  
CCDLFLAGS =  
DLEXT = bundle
DLSRC = dl_dlopen.xs
EXE_EXT = 
FULL_AR = /usr/bin/ar
LD = cc -mmacosx-version-min=10.5
LDDLFLAGS = -arch i386 -arch ppc -bundle -undefined dynamic_lookup -L/usr/local/lib
LDFLAGS = -arch i386 -arch ppc -L/usr/local/lib
LIBC = /usr/lib/libc.dylib
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = darwin
OSVERS = 9.0
RANLIB = /usr/bin/ar ts
SITELIBEXP = /Library/Perl/5.8.8
SITEARCHEXP = /Library/Perl/5.8.8/darwin-thread-multi-2level
SO = dylib
VENDORARCHEXP = /Network/Library/Perl/5.8.8/darwin-thread-multi-2level
VENDORLIBEXP = /Network/Library/Perl/5.8.8


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = MojoMojo
NAME_SYM = MojoMojo
VERSION = 0.999021
VERSION_MACRO = VERSION
VERSION_SYM = 0_999021
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.999021
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1
MAN3EXT = 3pm
INSTALLDIRS = site
INSTALL_BASE = /Users/marcus/perl5
DESTDIR = 
PREFIX = $(INSTALL_BASE)
INSTALLPRIVLIB = $(INSTALL_BASE)/lib/perl5
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = $(INSTALL_BASE)/lib/perl5
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = $(INSTALL_BASE)/lib/perl5
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = $(INSTALL_BASE)/lib/perl5/darwin-thread-multi-2level
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = $(INSTALL_BASE)/lib/perl5/darwin-thread-multi-2level
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = $(INSTALL_BASE)/lib/perl5/darwin-thread-multi-2level
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = $(INSTALL_BASE)/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = $(INSTALL_BASE)/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = $(INSTALL_BASE)/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = $(INSTALL_BASE)/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLSITESCRIPT = $(INSTALL_BASE)/bin
DESTINSTALLSITESCRIPT = $(DESTDIR)$(INSTALLSITESCRIPT)
INSTALLVENDORSCRIPT = $(INSTALL_BASE)/bin
DESTINSTALLVENDORSCRIPT = $(DESTDIR)$(INSTALLVENDORSCRIPT)
INSTALLMAN1DIR = $(INSTALL_BASE)/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = $(INSTALL_BASE)/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = $(INSTALL_BASE)/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = $(INSTALL_BASE)/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = $(INSTALL_BASE)/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = $(INSTALL_BASE)/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB =
PERL_ARCHLIB = /System/Library/Perl/5.8.8/darwin-thread-multi-2level
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /System/Library/Perl/5.8.8/darwin-thread-multi-2level/CORE
PERL = /usr/bin/perl "-Iinc"
FULLPERL = /usr/bin/perl "-Iinc"
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-Iinc" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /System/Library/Perl/5.8.8/ExtUtils/MakeMaker.pm
MM_VERSION  = 6.46
MM_REVISION = 66493

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
MAKE = make
FULLEXT = MojoMojo
BASEEXT = MojoMojo
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = 
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = script/mojomojo_cgi.pl \
	script/mojomojo_create.pl \
	script/mojomojo_fastcgi.pl \
	script/mojomojo_fcgi.pl \
	script/mojomojo_server.pl \
	script/mojomojo_test.pl
MAN3PODS = lib/MojoMojo.pm \
	lib/MojoMojo/Controller/Admin.pm \
	lib/MojoMojo/Controller/Attachment.pm \
	lib/MojoMojo/Controller/Comment.pm \
	lib/MojoMojo/Controller/Export.pm \
	lib/MojoMojo/Controller/Gallery.pm \
	lib/MojoMojo/Controller/Journal.pm \
	lib/MojoMojo/Controller/Jsrpc.pm \
	lib/MojoMojo/Controller/Page.pm \
	lib/MojoMojo/Controller/PageAdmin.pm \
	lib/MojoMojo/Controller/Root.pm \
	lib/MojoMojo/Controller/Tag.pm \
	lib/MojoMojo/Controller/User.pm \
	lib/MojoMojo/Formatter.pm \
	lib/MojoMojo/Formatter/Comment.pm \
	lib/MojoMojo/Formatter/IRCLog.pm \
	lib/MojoMojo/Formatter/Include.pm \
	lib/MojoMojo/Formatter/Markdown.pm \
	lib/MojoMojo/Formatter/Pod.pm \
	lib/MojoMojo/Formatter/Redirect.pm \
	lib/MojoMojo/Formatter/Scrub.pm \
	lib/MojoMojo/Formatter/Textile.pm \
	lib/MojoMojo/Formatter/Wiki.pm \
	lib/MojoMojo/Installation.pod \
	lib/MojoMojo/Model/DBIC.pm \
	lib/MojoMojo/Model/Search.pm \
	lib/MojoMojo/Prefs.pod \
	lib/MojoMojo/Schema/Attachment.pm \
	lib/MojoMojo/Schema/Comment.pm \
	lib/MojoMojo/Schema/Content.pm \
	lib/MojoMojo/Schema/Page.pm \
	lib/MojoMojo/Schema/Person.pm \
	lib/MojoMojo/Schema/Photo.pm \
	lib/MojoMojo/Schema/Tag.pm \
	lib/MojoMojo/View/TT.pm \
	lib/Text/SmartyPants.pm \
	lib/Text/Textile2.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)$(DFSEP)Config.pm $(PERL_INC)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = lib/MojoMojo.pm \
	lib/MojoMojo/Controller/Admin.pm \
	lib/MojoMojo/Controller/Attachment.pm \
	lib/MojoMojo/Controller/Comment.pm \
	lib/MojoMojo/Controller/Export.pm \
	lib/MojoMojo/Controller/Gallery.pm \
	lib/MojoMojo/Controller/Journal.pm \
	lib/MojoMojo/Controller/Jsrpc.pm \
	lib/MojoMojo/Controller/Page.pm \
	lib/MojoMojo/Controller/PageAdmin.pm \
	lib/MojoMojo/Controller/Root.pm \
	lib/MojoMojo/Controller/Tag.pm \
	lib/MojoMojo/Controller/User.pm \
	lib/MojoMojo/Formatter.pm \
	lib/MojoMojo/Formatter/Comment.pm \
	lib/MojoMojo/Formatter/IRCLog.pm \
	lib/MojoMojo/Formatter/Include.pm \
	lib/MojoMojo/Formatter/Markdown.pm \
	lib/MojoMojo/Formatter/Pod.pm \
	lib/MojoMojo/Formatter/Redirect.pm \
	lib/MojoMojo/Formatter/Scrub.pm \
	lib/MojoMojo/Formatter/Textile.pm \
	lib/MojoMojo/Formatter/Wiki.pm \
	lib/MojoMojo/I18N/en.po \
	lib/MojoMojo/I18N/no.po \
	lib/MojoMojo/Installation.pod \
	lib/MojoMojo/Model/DBIC.pm \
	lib/MojoMojo/Model/Search.pm \
	lib/MojoMojo/Prefs.pod \
	lib/MojoMojo/Schema.pm \
	lib/MojoMojo/Schema/Attachment.pm \
	lib/MojoMojo/Schema/Comment.pm \
	lib/MojoMojo/Schema/Content.pm \
	lib/MojoMojo/Schema/Entry.pm \
	lib/MojoMojo/Schema/Journal.pm \
	lib/MojoMojo/Schema/Link.pm \
	lib/MojoMojo/Schema/Page.pm \
	lib/MojoMojo/Schema/PageVersion.pm \
	lib/MojoMojo/Schema/PathPermissions.pm \
	lib/MojoMojo/Schema/Person.pm \
	lib/MojoMojo/Schema/Photo.pm \
	lib/MojoMojo/Schema/Preference.pm \
	lib/MojoMojo/Schema/Role.pm \
	lib/MojoMojo/Schema/RoleMember.pm \
	lib/MojoMojo/Schema/RolePrivilege.pm \
	lib/MojoMojo/Schema/Tag.pm \
	lib/MojoMojo/Schema/WantedPage.pm \
	lib/MojoMojo/View/TT.pm \
	lib/Text/SmartyPants.pm \
	lib/Text/Textile2.pm

PM_TO_BLIB = lib/MojoMojo/Controller/User.pm \
	blib/lib/MojoMojo/Controller/User.pm \
	lib/MojoMojo/Schema/PathPermissions.pm \
	blib/lib/MojoMojo/Schema/PathPermissions.pm \
	lib/MojoMojo/Controller/Export.pm \
	blib/lib/MojoMojo/Controller/Export.pm \
	lib/MojoMojo/Model/Search.pm \
	blib/lib/MojoMojo/Model/Search.pm \
	lib/MojoMojo.pm \
	blib/lib/MojoMojo.pm \
	lib/MojoMojo/View/TT.pm \
	blib/lib/MojoMojo/View/TT.pm \
	lib/MojoMojo/Schema/Link.pm \
	blib/lib/MojoMojo/Schema/Link.pm \
	lib/MojoMojo/Schema/WantedPage.pm \
	blib/lib/MojoMojo/Schema/WantedPage.pm \
	lib/MojoMojo/Formatter/Redirect.pm \
	blib/lib/MojoMojo/Formatter/Redirect.pm \
	lib/MojoMojo/Controller/Attachment.pm \
	blib/lib/MojoMojo/Controller/Attachment.pm \
	lib/MojoMojo/Formatter/Textile.pm \
	blib/lib/MojoMojo/Formatter/Textile.pm \
	lib/MojoMojo/Schema/Preference.pm \
	blib/lib/MojoMojo/Schema/Preference.pm \
	lib/MojoMojo/Schema/Role.pm \
	blib/lib/MojoMojo/Schema/Role.pm \
	lib/MojoMojo/Formatter/Wiki.pm \
	blib/lib/MojoMojo/Formatter/Wiki.pm \
	lib/MojoMojo/Schema/Person.pm \
	blib/lib/MojoMojo/Schema/Person.pm \
	lib/MojoMojo/Formatter/Markdown.pm \
	blib/lib/MojoMojo/Formatter/Markdown.pm \
	lib/MojoMojo/I18N/en.po \
	blib/lib/MojoMojo/I18N/en.po \
	lib/MojoMojo/Controller/Root.pm \
	blib/lib/MojoMojo/Controller/Root.pm \
	lib/MojoMojo/Formatter/Include.pm \
	blib/lib/MojoMojo/Formatter/Include.pm \
	lib/MojoMojo/Schema/Content.pm \
	blib/lib/MojoMojo/Schema/Content.pm \
	lib/MojoMojo/Formatter/Scrub.pm \
	blib/lib/MojoMojo/Formatter/Scrub.pm \
	lib/MojoMojo/Formatter.pm \
	blib/lib/MojoMojo/Formatter.pm \
	lib/MojoMojo/Controller/Journal.pm \
	blib/lib/MojoMojo/Controller/Journal.pm \
	lib/MojoMojo/Prefs.pod \
	blib/lib/MojoMojo/Prefs.pod \
	lib/MojoMojo/I18N/no.po \
	blib/lib/MojoMojo/I18N/no.po \
	lib/Text/Textile2.pm \
	blib/lib/Text/Textile2.pm \
	lib/MojoMojo/Schema.pm \
	blib/lib/MojoMojo/Schema.pm \
	lib/Text/SmartyPants.pm \
	blib/lib/Text/SmartyPants.pm \
	lib/MojoMojo/Controller/PageAdmin.pm \
	blib/lib/MojoMojo/Controller/PageAdmin.pm \
	lib/MojoMojo/Schema/RolePrivilege.pm \
	blib/lib/MojoMojo/Schema/RolePrivilege.pm \
	lib/MojoMojo/Formatter/Comment.pm \
	blib/lib/MojoMojo/Formatter/Comment.pm \
	lib/MojoMojo/Schema/Page.pm \
	blib/lib/MojoMojo/Schema/Page.pm \
	lib/MojoMojo/Controller/Page.pm \
	blib/lib/MojoMojo/Controller/Page.pm \
	lib/MojoMojo/Controller/Gallery.pm \
	blib/lib/MojoMojo/Controller/Gallery.pm \
	lib/MojoMojo/Schema/PageVersion.pm \
	blib/lib/MojoMojo/Schema/PageVersion.pm \
	lib/MojoMojo/Controller/Comment.pm \
	blib/lib/MojoMojo/Controller/Comment.pm \
	lib/MojoMojo/Schema/Photo.pm \
	blib/lib/MojoMojo/Schema/Photo.pm \
	lib/MojoMojo/Model/DBIC.pm \
	blib/lib/MojoMojo/Model/DBIC.pm \
	lib/MojoMojo/Formatter/IRCLog.pm \
	blib/lib/MojoMojo/Formatter/IRCLog.pm \
	lib/MojoMojo/Schema/Comment.pm \
	blib/lib/MojoMojo/Schema/Comment.pm \
	lib/MojoMojo/Schema/Attachment.pm \
	blib/lib/MojoMojo/Schema/Attachment.pm \
	lib/MojoMojo/Formatter/Pod.pm \
	blib/lib/MojoMojo/Formatter/Pod.pm \
	lib/MojoMojo/Installation.pod \
	blib/lib/MojoMojo/Installation.pod \
	lib/MojoMojo/Schema/Entry.pm \
	blib/lib/MojoMojo/Schema/Entry.pm \
	lib/MojoMojo/Schema/Tag.pm \
	blib/lib/MojoMojo/Schema/Tag.pm \
	lib/MojoMojo/Controller/Tag.pm \
	blib/lib/MojoMojo/Controller/Tag.pm \
	lib/MojoMojo/Controller/Admin.pm \
	blib/lib/MojoMojo/Controller/Admin.pm \
	lib/MojoMojo/Schema/RoleMember.pm \
	blib/lib/MojoMojo/Schema/RoleMember.pm \
	lib/MojoMojo/Schema/Journal.pm \
	blib/lib/MojoMojo/Schema/Journal.pm \
	lib/MojoMojo/Controller/Jsrpc.pm \
	blib/lib/MojoMojo/Controller/Jsrpc.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 6.46
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$ARGV[0], $$ARGV[1], 0, 1, 1)' --



# --- MakeMaker tool_xsubpp section:


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(SHELL) -c true
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) "-MExtUtils::Command" -e mkpath
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) "-MExtUtils::Command" -e eqtime
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install({@ARGV}, '\''$(VERBINST)'\'', 0, '\''$(UNINST)'\'');' --
DOC_INSTALL = $(ABSPERLRUN) "-MExtUtils::Command::MM" -e perllocal_install
UNINSTALL = $(ABSPERLRUN) "-MExtUtils::Command::MM" -e uninstall
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) "-MExtUtils::Command::MM" -e warn_if_old_packlist
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(PERLRUN) "-MExtUtils::MY" -e "MY->fixin(shift)"


# --- MakeMaker makemakerdflt section:
makemakerdflt : all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = COPY_EXTENDED_ATTRIBUTES_DISABLE=1 COPYFILE_DISABLE=1 tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip --best
SUFFIX = .gz
SHAR = shar
PREOP = $(PERL) -I. "-MModule::Install::Admin" -e "dist_preop(q($(DISTVNAME)))"
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist
DISTNAME = MojoMojo
DISTVNAME = MojoMojo-0.999021


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:


# --- MakeMaker const_loadlibs section:


# --- MakeMaker const_cccmd section:


# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"\
	INSTALL_BASE="$(INSTALL_BASE)"


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir



# --- MakeMaker c_o section:


# --- MakeMaker xs_c section:


# --- MakeMaker xs_o section:


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) 755 $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) 755 $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) 755 $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) 755 $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) 755 $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) 755 $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) 755 $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) 755 $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(INST_DYNAMIC) $(INST_BOOT)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	script/mojomojo_fastcgi.pl \
	script/mojomojo_create.pl \
	script/mojomojo_cgi.pl \
	script/mojomojo_server.pl \
	script/mojomojo_test.pl \
	script/mojomojo_fcgi.pl \
	lib/MojoMojo/Controller/User.pm \
	lib/MojoMojo/Controller/Export.pm \
	lib/MojoMojo/Model/Search.pm \
	lib/MojoMojo.pm \
	lib/MojoMojo/View/TT.pm \
	lib/MojoMojo/Formatter/Redirect.pm \
	lib/MojoMojo/Controller/Attachment.pm \
	lib/MojoMojo/Formatter/Textile.pm \
	lib/MojoMojo/Formatter/Wiki.pm \
	lib/MojoMojo/Schema/Person.pm \
	lib/MojoMojo/Formatter/Markdown.pm \
	lib/MojoMojo/Controller/Root.pm \
	lib/MojoMojo/Formatter/Include.pm \
	lib/MojoMojo/Formatter.pm \
	lib/MojoMojo/Controller/Journal.pm \
	lib/MojoMojo/Schema/Content.pm \
	lib/MojoMojo/Formatter/Scrub.pm \
	lib/MojoMojo/Prefs.pod \
	lib/Text/Textile2.pm \
	lib/Text/SmartyPants.pm \
	lib/MojoMojo/Controller/PageAdmin.pm \
	lib/MojoMojo/Formatter/Comment.pm \
	lib/MojoMojo/Schema/Page.pm \
	lib/MojoMojo/Controller/Page.pm \
	lib/MojoMojo/Controller/Gallery.pm \
	lib/MojoMojo/Controller/Comment.pm \
	lib/MojoMojo/Schema/Photo.pm \
	lib/MojoMojo/Model/DBIC.pm \
	lib/MojoMojo/Formatter/IRCLog.pm \
	lib/MojoMojo/Schema/Comment.pm \
	lib/MojoMojo/Schema/Attachment.pm \
	lib/MojoMojo/Formatter/Pod.pm \
	lib/MojoMojo/Installation.pod \
	lib/MojoMojo/Schema/Tag.pm \
	lib/MojoMojo/Controller/Tag.pm \
	lib/MojoMojo/Controller/Admin.pm \
	lib/MojoMojo/Controller/Jsrpc.pm
	$(NOECHO) $(POD2MAN) --section=1 --perm_rw=$(PERM_RW) \
	  script/mojomojo_fastcgi.pl $(INST_MAN1DIR)/mojomojo_fastcgi.pl.$(MAN1EXT) \
	  script/mojomojo_create.pl $(INST_MAN1DIR)/mojomojo_create.pl.$(MAN1EXT) \
	  script/mojomojo_cgi.pl $(INST_MAN1DIR)/mojomojo_cgi.pl.$(MAN1EXT) \
	  script/mojomojo_server.pl $(INST_MAN1DIR)/mojomojo_server.pl.$(MAN1EXT) \
	  script/mojomojo_test.pl $(INST_MAN1DIR)/mojomojo_test.pl.$(MAN1EXT) \
	  script/mojomojo_fcgi.pl $(INST_MAN1DIR)/mojomojo_fcgi.pl.$(MAN1EXT) 
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) \
	  lib/MojoMojo/Controller/User.pm $(INST_MAN3DIR)/MojoMojo::Controller::User.$(MAN3EXT) \
	  lib/MojoMojo/Controller/Export.pm $(INST_MAN3DIR)/MojoMojo::Controller::Export.$(MAN3EXT) \
	  lib/MojoMojo/Model/Search.pm $(INST_MAN3DIR)/MojoMojo::Model::Search.$(MAN3EXT) \
	  lib/MojoMojo.pm $(INST_MAN3DIR)/MojoMojo.$(MAN3EXT) \
	  lib/MojoMojo/View/TT.pm $(INST_MAN3DIR)/MojoMojo::View::TT.$(MAN3EXT) \
	  lib/MojoMojo/Formatter/Redirect.pm $(INST_MAN3DIR)/MojoMojo::Formatter::Redirect.$(MAN3EXT) \
	  lib/MojoMojo/Controller/Attachment.pm $(INST_MAN3DIR)/MojoMojo::Controller::Attachment.$(MAN3EXT) \
	  lib/MojoMojo/Formatter/Textile.pm $(INST_MAN3DIR)/MojoMojo::Formatter::Textile.$(MAN3EXT) \
	  lib/MojoMojo/Formatter/Wiki.pm $(INST_MAN3DIR)/MojoMojo::Formatter::Wiki.$(MAN3EXT) \
	  lib/MojoMojo/Schema/Person.pm $(INST_MAN3DIR)/MojoMojo::Schema::Person.$(MAN3EXT) \
	  lib/MojoMojo/Formatter/Markdown.pm $(INST_MAN3DIR)/MojoMojo::Formatter::Markdown.$(MAN3EXT) \
	  lib/MojoMojo/Controller/Root.pm $(INST_MAN3DIR)/MojoMojo::Controller::Root.$(MAN3EXT) \
	  lib/MojoMojo/Formatter/Include.pm $(INST_MAN3DIR)/MojoMojo::Formatter::Include.$(MAN3EXT) \
	  lib/MojoMojo/Formatter.pm $(INST_MAN3DIR)/MojoMojo::Formatter.$(MAN3EXT) \
	  lib/MojoMojo/Controller/Journal.pm $(INST_MAN3DIR)/MojoMojo::Controller::Journal.$(MAN3EXT) \
	  lib/MojoMojo/Schema/Content.pm $(INST_MAN3DIR)/MojoMojo::Schema::Content.$(MAN3EXT) \
	  lib/MojoMojo/Formatter/Scrub.pm $(INST_MAN3DIR)/MojoMojo::Formatter::Scrub.$(MAN3EXT) \
	  lib/MojoMojo/Prefs.pod $(INST_MAN3DIR)/MojoMojo::Prefs.$(MAN3EXT) \
	  lib/Text/Textile2.pm $(INST_MAN3DIR)/Text::Textile2.$(MAN3EXT) \
	  lib/Text/SmartyPants.pm $(INST_MAN3DIR)/Text::SmartyPants.$(MAN3EXT) \
	  lib/MojoMojo/Controller/PageAdmin.pm $(INST_MAN3DIR)/MojoMojo::Controller::PageAdmin.$(MAN3EXT) \
	  lib/MojoMojo/Formatter/Comment.pm $(INST_MAN3DIR)/MojoMojo::Formatter::Comment.$(MAN3EXT) \
	  lib/MojoMojo/Schema/Page.pm $(INST_MAN3DIR)/MojoMojo::Schema::Page.$(MAN3EXT) \
	  lib/MojoMojo/Controller/Page.pm $(INST_MAN3DIR)/MojoMojo::Controller::Page.$(MAN3EXT) \
	  lib/MojoMojo/Controller/Gallery.pm $(INST_MAN3DIR)/MojoMojo::Controller::Gallery.$(MAN3EXT) \
	  lib/MojoMojo/Controller/Comment.pm $(INST_MAN3DIR)/MojoMojo::Controller::Comment.$(MAN3EXT) \
	  lib/MojoMojo/Schema/Photo.pm $(INST_MAN3DIR)/MojoMojo::Schema::Photo.$(MAN3EXT) \
	  lib/MojoMojo/Model/DBIC.pm $(INST_MAN3DIR)/MojoMojo::Model::DBIC.$(MAN3EXT) \
	  lib/MojoMojo/Formatter/IRCLog.pm $(INST_MAN3DIR)/MojoMojo::Formatter::IRCLog.$(MAN3EXT) \
	  lib/MojoMojo/Schema/Comment.pm $(INST_MAN3DIR)/MojoMojo::Schema::Comment.$(MAN3EXT) \
	  lib/MojoMojo/Schema/Attachment.pm $(INST_MAN3DIR)/MojoMojo::Schema::Attachment.$(MAN3EXT) \
	  lib/MojoMojo/Formatter/Pod.pm $(INST_MAN3DIR)/MojoMojo::Formatter::Pod.$(MAN3EXT) \
	  lib/MojoMojo/Installation.pod $(INST_MAN3DIR)/MojoMojo::Installation.$(MAN3EXT) \
	  lib/MojoMojo/Schema/Tag.pm $(INST_MAN3DIR)/MojoMojo::Schema::Tag.$(MAN3EXT) \
	  lib/MojoMojo/Controller/Tag.pm $(INST_MAN3DIR)/MojoMojo::Controller::Tag.$(MAN3EXT) \
	  lib/MojoMojo/Controller/Admin.pm $(INST_MAN3DIR)/MojoMojo::Controller::Admin.$(MAN3EXT) \
	  lib/MojoMojo/Controller/Jsrpc.pm $(INST_MAN3DIR)/MojoMojo::Controller::Jsrpc.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:

EXE_FILES = script/hash_passwords.pl script/mojomojo_cgi.pl script/mojomojo_create.pl script/mojomojo_fastcgi.pl script/mojomojo_fcgi.pl script/mojomojo_server.pl script/mojomojo_spawn_db.pl script/mojomojo_test.pl script/search_query.pl

pure_all :: $(INST_SCRIPT)/search_query.pl $(INST_SCRIPT)/mojomojo_spawn_db.pl $(INST_SCRIPT)/mojomojo_cgi.pl $(INST_SCRIPT)/hash_passwords.pl $(INST_SCRIPT)/mojomojo_server.pl $(INST_SCRIPT)/mojomojo_create.pl $(INST_SCRIPT)/mojomojo_fastcgi.pl $(INST_SCRIPT)/mojomojo_test.pl $(INST_SCRIPT)/mojomojo_fcgi.pl
	$(NOECHO) $(NOOP)

realclean ::
	$(RM_F) \
	  $(INST_SCRIPT)/search_query.pl $(INST_SCRIPT)/mojomojo_spawn_db.pl \
	  $(INST_SCRIPT)/mojomojo_cgi.pl $(INST_SCRIPT)/hash_passwords.pl \
	  $(INST_SCRIPT)/mojomojo_server.pl $(INST_SCRIPT)/mojomojo_create.pl \
	  $(INST_SCRIPT)/mojomojo_fastcgi.pl $(INST_SCRIPT)/mojomojo_test.pl \
	  $(INST_SCRIPT)/mojomojo_fcgi.pl 

$(INST_SCRIPT)/search_query.pl : script/search_query.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/search_query.pl
	$(CP) script/search_query.pl $(INST_SCRIPT)/search_query.pl
	$(FIXIN) $(INST_SCRIPT)/search_query.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/search_query.pl

$(INST_SCRIPT)/mojomojo_spawn_db.pl : script/mojomojo_spawn_db.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/mojomojo_spawn_db.pl
	$(CP) script/mojomojo_spawn_db.pl $(INST_SCRIPT)/mojomojo_spawn_db.pl
	$(FIXIN) $(INST_SCRIPT)/mojomojo_spawn_db.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/mojomojo_spawn_db.pl

$(INST_SCRIPT)/mojomojo_cgi.pl : script/mojomojo_cgi.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/mojomojo_cgi.pl
	$(CP) script/mojomojo_cgi.pl $(INST_SCRIPT)/mojomojo_cgi.pl
	$(FIXIN) $(INST_SCRIPT)/mojomojo_cgi.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/mojomojo_cgi.pl

$(INST_SCRIPT)/hash_passwords.pl : script/hash_passwords.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/hash_passwords.pl
	$(CP) script/hash_passwords.pl $(INST_SCRIPT)/hash_passwords.pl
	$(FIXIN) $(INST_SCRIPT)/hash_passwords.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/hash_passwords.pl

$(INST_SCRIPT)/mojomojo_server.pl : script/mojomojo_server.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/mojomojo_server.pl
	$(CP) script/mojomojo_server.pl $(INST_SCRIPT)/mojomojo_server.pl
	$(FIXIN) $(INST_SCRIPT)/mojomojo_server.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/mojomojo_server.pl

$(INST_SCRIPT)/mojomojo_create.pl : script/mojomojo_create.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/mojomojo_create.pl
	$(CP) script/mojomojo_create.pl $(INST_SCRIPT)/mojomojo_create.pl
	$(FIXIN) $(INST_SCRIPT)/mojomojo_create.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/mojomojo_create.pl

$(INST_SCRIPT)/mojomojo_fastcgi.pl : script/mojomojo_fastcgi.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/mojomojo_fastcgi.pl
	$(CP) script/mojomojo_fastcgi.pl $(INST_SCRIPT)/mojomojo_fastcgi.pl
	$(FIXIN) $(INST_SCRIPT)/mojomojo_fastcgi.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/mojomojo_fastcgi.pl

$(INST_SCRIPT)/mojomojo_test.pl : script/mojomojo_test.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/mojomojo_test.pl
	$(CP) script/mojomojo_test.pl $(INST_SCRIPT)/mojomojo_test.pl
	$(FIXIN) $(INST_SCRIPT)/mojomojo_test.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/mojomojo_test.pl

$(INST_SCRIPT)/mojomojo_fcgi.pl : script/mojomojo_fcgi.pl $(FIRST_MAKEFILE) $(INST_SCRIPT)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists
	$(NOECHO) $(RM_F) $(INST_SCRIPT)/mojomojo_fcgi.pl
	$(CP) script/mojomojo_fcgi.pl $(INST_SCRIPT)/mojomojo_fcgi.pl
	$(FIXIN) $(INST_SCRIPT)/mojomojo_fcgi.pl
	-$(NOECHO) $(CHMOD) $(PERM_RWX) $(INST_SCRIPT)/mojomojo_fcgi.pl



# --- MakeMaker subdirs section:

# none

# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  *$(LIB_EXT) core \
	  core.[0-9] $(INST_ARCHAUTODIR)/extralibs.all \
	  core.[0-9][0-9] $(BASEEXT).bso \
	  pm_to_blib.ts core.[0-9][0-9][0-9][0-9] \
	  $(BASEEXT).x $(BOOTSTRAP) \
	  perl$(EXE_EXT) tmon.out \
	  *$(OBJ_EXT) pm_to_blib \
	  $(INST_ARCHAUTODIR)/extralibs.ld blibdirs.ts \
	  core.[0-9][0-9][0-9][0-9][0-9] *perl.core \
	  core.*perl.*.? $(MAKE_APERL_FILE) \
	  perl $(BASEEXT).def \
	  core.[0-9][0-9][0-9] mon.out \
	  lib$(BASEEXT).def perlmain.c \
	  perl.exe so_locations \
	  $(BASEEXT).exp 
	- $(RM_RF) \
	  blib 
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	$(NOECHO) $(NOOP)


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge ::  clean realclean_subdirs
	- $(RM_F) \
	  $(MAKEFILE_OLD) $(FIRST_MAKEFILE) 
	- $(RM_RF) \
	  $(DISTVNAME) 


# --- MakeMaker metafile section:
metafile :
	$(NOECHO) $(NOOP)


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ */*~ *.orig */*.orig *.bak */*.bak *.old */*.old 



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';' --

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir  
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL 
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{META.yml} => q{Module meta-data (added by MakeMaker)}}) } ' \
	  -e '    or print "Could not add META.yml to MANIFEST: $${'\''@'\''}\n"' --



# --- MakeMaker distsignature section:
distsignature : create_distdir
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) } ' \
	  -e '    or print "Could not add SIGNATURE to MANIFEST: $${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: all pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: all pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: all pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: all pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLARCHLIB) \
		$(INST_BIN) $(DESTINSTALLBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLSITELIB) \
		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
		$(INST_BIN) $(DESTINSTALLSITEBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSITESCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

pure_vendor_install ::
	$(NOECHO) $(MOD_INSTALL) \
		read $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLVENDORARCH) \
		$(INST_BIN) $(DESTINSTALLVENDORBIN) \
		$(INST_SCRIPT) $(DESTINSTALLVENDORSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLVENDORMAN3DIR)

doc_perl_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_site_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_vendor_install ::
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE :
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	false



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/bin/perl

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR= \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/01app.t t/02pod.t t/03podcoverage.t t/formatter_comment.t t/formatter_include.t t/formatter_irclog.t t/formatter_redirect.t t/formatter_wiki.t t/schema_DBIC.t t/schema_DBIC_Attachment.t t/schema_DBIC_Content.t t/schema_DBIC_Page.t t/schema_DBIC_Person.t t/schema_DBIC_Tag.t t/selenium.t t/c/attachment.t t/c/comment.t t/c/journal.t t/c/jsrpc.t t/c/page.t t/c/page_edit.t t/c/user.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE) subdirs-test

subdirs-test ::
	$(NOECHO) $(NOOP)


test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), 'inc', '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-Iinc" "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: test_dynamic
testdb_static :: testdb_dynamic


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd :
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="0,999021,0,0">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <TITLE>$(DISTNAME)</TITLE>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT>A Catalyst & DBIx::Class powered Wiki.</ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR>Marcus Ramberg C&lt;marcus@nordaaker.com&gt;</AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Algorithm-Diff" VERSION="1,1901,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Archive-Zip" VERSION="1,14,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Cache-Memory" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst" VERSION="5,7000,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Action-RenderView" VERSION="0,07,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Authentication-Store-DBIx-Class" VERSION="0,101,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Controller-HTML-FormFu" VERSION="0,02000,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Model-DBIC-Schema" VERSION="0,01,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-Authentication" VERSION="0,10005,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-Cache-Store-Memory" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-ConfigLoader" VERSION="0,13,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-Email" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-FillInForm" VERSION="0,04,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-FormValidator" VERSION="0,02,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-I18N" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-Session-State-Cookie" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-Session-Store-File" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-Singleton" VERSION="0,02,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-Static-Simple" VERSION="0,07,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-SubRequest" VERSION="0,09,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-Unicode" VERSION="0,8,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-Plugin-UploadProgress" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Catalyst-View-TT" VERSION="0,23,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Config-General" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="DBD-SQLite" VERSION="1,08,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="DBIx-Class" VERSION="0,08,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="DBIx-Class-DateTime-Epoch" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="DBIx-Class-EncodedColumn" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="DBIx-Class-HTML-FormFu" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Data-FormValidator-Constraints-DateTime" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Data-Page" VERSION="2,00,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="DateTime" VERSION="0,28,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="DateTime-Format-Mail" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="ExtUtils-MakeMaker" VERSION="6,46,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="File-MMagic" VERSION="1,27,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="HTML-Scrubber" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="HTML-Strip" VERSION="1,04,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="HTML-TagCloud" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="IO-Scalar" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Image-ExifTool" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Image-Math-Constrain" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Imager" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="KinoSearch" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="LWP-Simple" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Module-Pluggable-Ordered" VERSION="1,4,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Moose" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Pod-Simple-HTML" VERSION="3,01,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="String-Diff" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Template-Plugin-JavaScript" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Text-Context" VERSION="3,5,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="Text-Password-Pronounceable" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="URI" VERSION="1,35,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="URI-Fetch" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="XML-Clean" VERSION="0,0,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <DEPENDENCY NAME="YAML" VERSION="0,36,0,0" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <OS NAME="$(OSNAME)" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="darwin-thread-multi-2level-5.8" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', '\''$(PM_FILTER)'\'')' -- \
	  lib/MojoMojo/Controller/User.pm blib/lib/MojoMojo/Controller/User.pm \
	  lib/MojoMojo/Schema/PathPermissions.pm blib/lib/MojoMojo/Schema/PathPermissions.pm \
	  lib/MojoMojo/Controller/Export.pm blib/lib/MojoMojo/Controller/Export.pm \
	  lib/MojoMojo/Model/Search.pm blib/lib/MojoMojo/Model/Search.pm \
	  lib/MojoMojo.pm blib/lib/MojoMojo.pm \
	  lib/MojoMojo/View/TT.pm blib/lib/MojoMojo/View/TT.pm \
	  lib/MojoMojo/Schema/Link.pm blib/lib/MojoMojo/Schema/Link.pm \
	  lib/MojoMojo/Schema/WantedPage.pm blib/lib/MojoMojo/Schema/WantedPage.pm \
	  lib/MojoMojo/Formatter/Redirect.pm blib/lib/MojoMojo/Formatter/Redirect.pm \
	  lib/MojoMojo/Controller/Attachment.pm blib/lib/MojoMojo/Controller/Attachment.pm \
	  lib/MojoMojo/Formatter/Textile.pm blib/lib/MojoMojo/Formatter/Textile.pm \
	  lib/MojoMojo/Schema/Preference.pm blib/lib/MojoMojo/Schema/Preference.pm \
	  lib/MojoMojo/Schema/Role.pm blib/lib/MojoMojo/Schema/Role.pm \
	  lib/MojoMojo/Formatter/Wiki.pm blib/lib/MojoMojo/Formatter/Wiki.pm \
	  lib/MojoMojo/Schema/Person.pm blib/lib/MojoMojo/Schema/Person.pm \
	  lib/MojoMojo/Formatter/Markdown.pm blib/lib/MojoMojo/Formatter/Markdown.pm \
	  lib/MojoMojo/I18N/en.po blib/lib/MojoMojo/I18N/en.po \
	  lib/MojoMojo/Controller/Root.pm blib/lib/MojoMojo/Controller/Root.pm \
	  lib/MojoMojo/Formatter/Include.pm blib/lib/MojoMojo/Formatter/Include.pm \
	  lib/MojoMojo/Schema/Content.pm blib/lib/MojoMojo/Schema/Content.pm \
	  lib/MojoMojo/Formatter/Scrub.pm blib/lib/MojoMojo/Formatter/Scrub.pm \
	  lib/MojoMojo/Formatter.pm blib/lib/MojoMojo/Formatter.pm \
	  lib/MojoMojo/Controller/Journal.pm blib/lib/MojoMojo/Controller/Journal.pm \
	  lib/MojoMojo/Prefs.pod blib/lib/MojoMojo/Prefs.pod \
	  lib/MojoMojo/I18N/no.po blib/lib/MojoMojo/I18N/no.po \
	  lib/Text/Textile2.pm blib/lib/Text/Textile2.pm \
	  lib/MojoMojo/Schema.pm blib/lib/MojoMojo/Schema.pm \
	  lib/Text/SmartyPants.pm blib/lib/Text/SmartyPants.pm \
	  lib/MojoMojo/Controller/PageAdmin.pm blib/lib/MojoMojo/Controller/PageAdmin.pm \
	  lib/MojoMojo/Schema/RolePrivilege.pm blib/lib/MojoMojo/Schema/RolePrivilege.pm \
	  lib/MojoMojo/Formatter/Comment.pm blib/lib/MojoMojo/Formatter/Comment.pm \
	  lib/MojoMojo/Schema/Page.pm blib/lib/MojoMojo/Schema/Page.pm \
	  lib/MojoMojo/Controller/Page.pm blib/lib/MojoMojo/Controller/Page.pm \
	  lib/MojoMojo/Controller/Gallery.pm blib/lib/MojoMojo/Controller/Gallery.pm \
	  lib/MojoMojo/Schema/PageVersion.pm blib/lib/MojoMojo/Schema/PageVersion.pm \
	  lib/MojoMojo/Controller/Comment.pm blib/lib/MojoMojo/Controller/Comment.pm \
	  lib/MojoMojo/Schema/Photo.pm blib/lib/MojoMojo/Schema/Photo.pm \
	  lib/MojoMojo/Model/DBIC.pm blib/lib/MojoMojo/Model/DBIC.pm \
	  lib/MojoMojo/Formatter/IRCLog.pm blib/lib/MojoMojo/Formatter/IRCLog.pm \
	  lib/MojoMojo/Schema/Comment.pm blib/lib/MojoMojo/Schema/Comment.pm \
	  lib/MojoMojo/Schema/Attachment.pm blib/lib/MojoMojo/Schema/Attachment.pm \
	  lib/MojoMojo/Formatter/Pod.pm blib/lib/MojoMojo/Formatter/Pod.pm \
	  lib/MojoMojo/Installation.pod blib/lib/MojoMojo/Installation.pod \
	  lib/MojoMojo/Schema/Entry.pm blib/lib/MojoMojo/Schema/Entry.pm \
	  lib/MojoMojo/Schema/Tag.pm blib/lib/MojoMojo/Schema/Tag.pm \
	  lib/MojoMojo/Controller/Tag.pm blib/lib/MojoMojo/Controller/Tag.pm \
	  lib/MojoMojo/Controller/Admin.pm blib/lib/MojoMojo/Controller/Admin.pm \
	  lib/MojoMojo/Schema/RoleMember.pm blib/lib/MojoMojo/Schema/RoleMember.pm \
	  lib/MojoMojo/Schema/Journal.pm blib/lib/MojoMojo/Schema/Journal.pm \
	  lib/MojoMojo/Controller/Jsrpc.pm blib/lib/MojoMojo/Controller/Jsrpc.pm 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
# Postamble by Module::Install 0.77
# --- Module::Install::Admin::Makefile section:

realclean purge ::
	$(RM_F) $(DISTVNAME).tar$(SUFFIX)
	$(RM_RF) inc MANIFEST.bak _build
	$(PERL) -I. "-MModule::Install::Admin" -e "remove_meta()"

reset :: purge

upload :: test dist
	cpan-upload -verbose $(DISTVNAME).tar$(SUFFIX)

grok ::
	perldoc Module::Install

distsign ::
	cpansign -s

catalyst_par :: all
	$(NOECHO) $(PERL) -Ilib -Minc::Module::Install -MModule::Install::Catalyst -e"Catalyst::Module::Install::_catalyst_par( '', 'MojoMojo', { CLASSES => [], CORE => 0, ENGINE => 'CGI', MULTIARCH => 0, SCRIPT => '', USAGE => q## } )"
# --- Module::Install::AutoInstall section:

config :: installdeps
	$(NOECHO) $(NOOP)

checkdeps ::
	$(PERL) Makefile.PL --checkdeps

installdeps ::
	$(NOECHO) $(NOOP)

