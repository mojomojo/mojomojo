<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Created by SQL::Translator::Producer::XML::SQLFairy
Created on Tue Aug 15 18:32:58 2006

 -->

<schema name="" database="" xmlns="http://sqlfairy.sourceforge.net/sqlfairy.xml">
  <extra />
  <tables>
    <table name="entry" order="65">
      <extra />
      <fields>
        <field name="id" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="1" is_primary_key="1" is_foreign_key="0" order="437">
          <extra />
          <comments></comments>
        </field>
        <field name="journal" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="438">
          <extra />
          <comments></comments>
        </field>
        <field name="author" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="439">
          <extra />
          <comments></comments>
        </field>
        <field name="title" data_type="VARCHAR" size="150" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="440">
          <extra />
          <comments></comments>
        </field>
        <field name="content" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="441">
          <extra />
          <comments></comments>
        </field>
        <field name="posted" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="442">
          <extra />
          <comments></comments>
        </field>
        <field name="location" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="443">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="id" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_author" type="FOREIGN KEY" fields="author" reference_table="person" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_journal" type="FOREIGN KEY" fields="journal" reference_table="journal" reference_fields="pageid" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="preference" order="66">
      <extra />
      <fields>
        <field name="prefkey" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="1" is_foreign_key="0" order="444">
          <extra />
          <comments></comments>
        </field>
        <field name="prefvalue" data_type="VARCHAR" size="100" is_nullable="1" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="445">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="prefkey" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="wanted_page" order="67">
      <extra />
      <fields>
        <field name="id" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="1" is_primary_key="1" is_foreign_key="0" order="446">
          <extra />
          <comments></comments>
        </field>
        <field name="from_page" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="447">
          <extra />
          <comments></comments>
        </field>
        <field name="to_path" data_type="TEXT" size="4000" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="448">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="id" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_from_page" type="FOREIGN KEY" fields="from_page" reference_table="page" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="page" order="68">
      <extra />
      <fields>
        <field name="id" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="1" is_primary_key="1" is_foreign_key="1" order="449">
          <extra />
          <comments></comments>
        </field>
        <field name="version" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="450">
          <extra />
          <comments></comments>
        </field>
        <field name="parent" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="451">
          <extra />
          <comments></comments>
        </field>
        <field name="name" data_type="VARCHAR" size="200" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="452">
          <extra />
          <comments></comments>
        </field>
        <field name="name_orig" data_type="VARCHAR" size="200" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="453">
          <extra />
          <comments></comments>
        </field>
        <field name="depth" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="454">
          <extra />
          <comments></comments>
        </field>
        <field name="lft" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="455">
          <extra />
          <comments></comments>
        </field>
        <field name="rgt" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="456">
          <extra />
          <comments></comments>
        </field>
        <field name="content_version" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="457">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="id" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="page_unique_child_index" type="UNIQUE" fields="parent,name" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_parent" type="FOREIGN KEY" fields="parent" reference_table="page" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_content_version" type="FOREIGN KEY" fields="content_version,id" reference_table="content" reference_fields="version,page" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_version" type="FOREIGN KEY" fields="version,id" reference_table="page_version" reference_fields="version,page" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="person" order="69">
      <extra />
      <fields>
        <field name="id" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="1" is_primary_key="1" is_foreign_key="0" order="458">
          <extra />
          <comments></comments>
        </field>
        <field name="active" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="459">
          <extra />
          <comments></comments>
        </field>
        <field name="registered" data_type="BIGINT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="460">
          <extra />
          <comments></comments>
        </field>
        <field name="views" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="461">
          <extra />
          <comments></comments>
        </field>
        <field name="photo" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="462">
          <extra />
          <comments></comments>
        </field>
        <field name="login" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="463">
          <extra />
          <comments></comments>
        </field>
        <field name="name" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="464">
          <extra />
          <comments></comments>
        </field>
        <field name="email" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="465">
          <extra />
          <comments></comments>
        </field>
        <field name="pass" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="466">
          <extra />
          <comments></comments>
        </field>
        <field name="timezone" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="467">
          <extra />
          <comments></comments>
        </field>
        <field name="born" data_type="BIGINT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="468">
          <extra />
          <comments></comments>
        </field>
        <field name="gender" data_type="CHAR" size="1" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="469">
          <extra />
          <comments></comments>
        </field>
        <field name="occupation" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="470">
          <extra />
          <comments></comments>
        </field>
        <field name="industry" data_type="VARCHART" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="471">
          <extra />
          <comments></comments>
        </field>
        <field name="interests" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="472">
          <extra />
          <comments></comments>
        </field>
        <field name="movies" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="473">
          <extra />
          <comments></comments>
        </field>
        <field name="music" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="474">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="id" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="link" order="70">
      <extra />
      <fields>
        <field name="id" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="1" is_primary_key="1" is_foreign_key="0" order="475">
          <extra />
          <comments></comments>
        </field>
        <field name="from_page" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="476">
          <extra />
          <comments></comments>
        </field>
        <field name="to_page" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="477">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="id" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_from_page" type="FOREIGN KEY" fields="from_page" reference_table="page" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_to_page" type="FOREIGN KEY" fields="to_page" reference_table="page" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="tag" order="71">
      <extra />
      <fields>
        <field name="id" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="1" is_primary_key="1" is_foreign_key="0" order="478">
          <extra />
          <comments></comments>
        </field>
        <field name="person" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="479">
          <extra />
          <comments></comments>
        </field>
        <field name="page" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="480">
          <extra />
          <comments></comments>
        </field>
        <field name="photo" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="481">
          <extra />
          <comments></comments>
        </field>
        <field name="tag" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="482">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="id" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_page" type="FOREIGN KEY" fields="page" reference_table="page" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_person" type="FOREIGN KEY" fields="person" reference_table="person" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_photo" type="FOREIGN KEY" fields="photo" reference_table="photo" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="role_privilege" order="72">
      <extra />
      <fields>
        <field name="page" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="1" is_foreign_key="1" order="483">
          <extra />
          <comments></comments>
        </field>
        <field name="role" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="1" is_foreign_key="1" order="484">
          <extra />
          <comments></comments>
        </field>
        <field name="privilege" data_type="VARCHAR" size="20" is_nullable="0" is_auto_increment="0" is_primary_key="1" is_foreign_key="0" order="485">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="page,role,privilege" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_page" type="FOREIGN KEY" fields="page" reference_table="page" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_role" type="FOREIGN KEY" fields="role" reference_table="role" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="role" order="73">
      <extra />
      <fields>
        <field name="id" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="1" is_primary_key="1" is_foreign_key="0" order="486">
          <extra />
          <comments></comments>
        </field>
        <field name="name" data_type="VARCHAR" size="200" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="487">
          <extra />
          <comments></comments>
        </field>
        <field name="active" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="488">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="id" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="name_unique" type="UNIQUE" fields="name" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="attachment" order="74">
      <extra />
      <fields>
        <field name="id" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="1" is_primary_key="1" is_foreign_key="0" order="489">
          <extra />
          <comments></comments>
        </field>
        <field name="uploaded" data_type="BIGINT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="490">
          <extra />
          <comments></comments>
        </field>
        <field name="page" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="491">
          <extra />
          <comments></comments>
        </field>
        <field name="name" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="492">
          <extra />
          <comments></comments>
        </field>
        <field name="size" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="493">
          <extra />
          <comments></comments>
        </field>
        <field name="contenttype" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="494">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="id" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_page" type="FOREIGN KEY" fields="page" reference_table="page" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="comment" order="75">
      <extra />
      <fields>
        <field name="id" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="1" is_primary_key="1" is_foreign_key="0" order="495">
          <extra />
          <comments></comments>
        </field>
        <field name="poster" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="496">
          <extra />
          <comments></comments>
        </field>
        <field name="page" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="497">
          <extra />
          <comments></comments>
        </field>
        <field name="picture" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="498">
          <extra />
          <comments></comments>
        </field>
        <field name="posted" data_type="BIGINT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="499">
          <extra />
          <comments></comments>
        </field>
        <field name="body" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="500">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="id" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_page" type="FOREIGN KEY" fields="page" reference_table="page" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_poster" type="FOREIGN KEY" fields="poster" reference_table="person" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_picture" type="FOREIGN KEY" fields="picture" reference_table="photo" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="photo" order="76">
      <extra />
      <fields>
        <field name="id" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="1" is_primary_key="1" is_foreign_key="0" order="501">
          <extra />
          <comments></comments>
        </field>
        <field name="title" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="502">
          <extra />
          <comments></comments>
        </field>
        <field name="description" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="503">
          <extra />
          <comments></comments>
        </field>
        <field name="camera" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="504">
          <extra />
          <comments></comments>
        </field>
        <field name="taken" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="505">
          <extra />
          <comments></comments>
        </field>
        <field name="iso" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="506">
          <extra />
          <comments></comments>
        </field>
        <field name="lens" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="507">
          <extra />
          <comments></comments>
        </field>
        <field name="aperture" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="508">
          <extra />
          <comments></comments>
        </field>
        <field name="flash" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="509">
          <extra />
          <comments></comments>
        </field>
        <field name="height" data_type="INT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="510">
          <extra />
          <comments></comments>
        </field>
        <field name="width" data_type="INT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="511">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="id" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="role_member" order="77">
      <extra />
      <fields>
        <field name="role" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="1" is_foreign_key="1" order="512">
          <extra />
          <comments></comments>
        </field>
        <field name="person" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="1" is_foreign_key="1" order="513">
          <extra />
          <comments></comments>
        </field>
        <field name="admin" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="514">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="role,person" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_person" type="FOREIGN KEY" fields="person" reference_table="person" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_role" type="FOREIGN KEY" fields="role" reference_table="role" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="page_version" order="78">
      <extra />
      <fields>
        <field name="page" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="1" is_foreign_key="1" order="515">
          <extra />
          <comments></comments>
        </field>
        <field name="version" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="1" is_foreign_key="0" order="516">
          <extra />
          <comments></comments>
        </field>
        <field name="parent" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="517">
          <extra />
          <comments></comments>
        </field>
        <field name="parent_version" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="518">
          <extra />
          <comments></comments>
        </field>
        <field name="name" data_type="VARCHAR" size="200" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="519">
          <extra />
          <comments></comments>
        </field>
        <field name="name_orig" data_type="VARCHAR" size="200" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="520">
          <extra />
          <comments></comments>
        </field>
        <field name="depth" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="521">
          <extra />
          <comments></comments>
        </field>
        <field name="creator" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="522">
          <extra />
          <comments></comments>
        </field>
        <field name="created" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="523">
          <extra />
          <comments></comments>
        </field>
        <field name="status" data_type="VARCHAR" size="20" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="524">
          <extra />
          <comments></comments>
        </field>
        <field name="release_date" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="525">
          <extra />
          <comments></comments>
        </field>
        <field name="remove_date" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="526">
          <extra />
          <comments></comments>
        </field>
        <field name="comments" data_type="TEXT" size="4000" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="527">
          <extra />
          <comments></comments>
        </field>
        <field name="content_version_first" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="528">
          <extra />
          <comments></comments>
        </field>
        <field name="content_version_last" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="529">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="page,version" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_creator" type="FOREIGN KEY" fields="creator" reference_table="person" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_page" type="FOREIGN KEY" fields="page" reference_table="page" reference_fields="page" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_content_version_last" type="FOREIGN KEY" fields="content_version_last,page" reference_table="content" reference_fields="version,page" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_parent_version" type="FOREIGN KEY" fields="parent_version,parent" reference_table="page_version" reference_fields="version,page" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="content" order="79">
      <extra />
      <fields>
        <field name="page" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="1" is_foreign_key="1" order="530">
          <extra />
          <comments></comments>
        </field>
        <field name="version" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="1" is_foreign_key="0" order="531">
          <extra />
          <comments></comments>
        </field>
        <field name="creator" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="1" order="532">
          <extra />
          <comments></comments>
        </field>
        <field name="created" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="533">
          <extra />
          <comments></comments>
        </field>
        <field name="status" data_type="VARCHAR" size="20" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="534">
          <extra />
          <comments></comments>
        </field>
        <field name="release_date" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="535">
          <extra />
          <comments></comments>
        </field>
        <field name="remove_date" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="536">
          <extra />
          <comments></comments>
        </field>
        <field name="type" data_type="VARCHAR" size="200" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="537">
          <extra />
          <comments></comments>
        </field>
        <field name="abstract" data_type="TEXT" size="4000" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="538">
          <extra />
          <comments></comments>
        </field>
        <field name="comments" data_type="TEXT" size="4000" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="539">
          <extra />
          <comments></comments>
        </field>
        <field name="body" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="540">
          <extra />
          <comments></comments>
        </field>
        <field name="precompiled" data_type="TEXT" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="541">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="page,version" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_creator" type="FOREIGN KEY" fields="creator" reference_table="person" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
        <constraint name="fk_page" type="FOREIGN KEY" fields="page" reference_table="page" reference_fields="id" on_delete="CASCADE" on_update="CASCADE" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
    <table name="journal" order="80">
      <extra />
      <fields>
        <field name="pageid" data_type="INTEGER" size="0" is_nullable="0" is_auto_increment="0" is_primary_key="1" is_foreign_key="0" order="542">
          <extra />
          <comments></comments>
        </field>
        <field name="name" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="543">
          <extra />
          <comments></comments>
        </field>
        <field name="dateformat" data_type="VARCHAR" size="20" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="544">
          <extra />
          <comments></comments>
        </field>
        <field name="defaultlocation" data_type="VARCHAR" size="100" is_nullable="0" is_auto_increment="0" is_primary_key="0" is_foreign_key="0" order="545">
          <extra />
          <comments></comments>
        </field>
      </fields>
      <indices></indices>
      <constraints>
        <constraint name="" type="PRIMARY KEY" fields="pageid" reference_table="" reference_fields="" on_delete="" on_update="" match_type="" expression="" options="" deferrable="1">
          <extra />
        </constraint>
      </constraints>
      <comments></comments>
    </table>
  </tables>
  <views></views>
  <triggers></triggers>
  <procedures></procedures>
</schema>
