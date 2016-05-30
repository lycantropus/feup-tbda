create table alus as select * from gtd2.alus;
create table anos as select * from gtd2.anos;
create table cands as select * from gtd2.cands;
create table lics as select * from gtd2.lics;


create or replace PACKAGE         enrolments
  IS

    PROCEDURE list_programs;
    
    PROCEDURE list_applications;
    
    PROCEDURE list_enrolments;
    
    PROCEDURE list_years;

END enrolments;


create or replace PACKAGE BODY enrolments
AS

 PROCEDURE list_programs
  AS
  v_sqlselect      VARCHAR2(2000);
  v_queryctx       DBMS_XMLQuery.ctxType;
  v_clob_par       CLOB;
  BEGIN
  v_sqlselect := 'SELECT l.codigo, l.sigla, l.nome
  FROM LICS l
  ';
  v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);
  DBMS_XMLQuery.setEncodingTag(v_queryctx, 'ISO-8859-1');
  v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
  DBMS_XMLQuery.closeContext(v_queryctx);
  htp.p(v_clob_par);
  htp.para;
  EXCEPTION
  WHEN OTHERS THEN
    htp.p(SQLERRM);
  END list_programs; 

  PROCEDURE list_applications
  IS
  v_sqlselect      VARCHAR2(2000);
  v_queryctx       DBMS_XMLQuery.ctxType;
  candidates xmltype;
  re       CLOB;
 begin
 select xmlagg(xmlelement("candidates",
  xmlattributes('c' || cands.bi as bi)),
  xmlelement("curso", cands.curso),
  --xmlelement("ano_lectivo", cands.ano_lectivo),
  xmlelement("resultado", cands.resultado),
  xmlelement("media", cands.media)
)
into re
from cands;
        
        htp.p(re);      
  END list_applications; 

  PROCEDURE list_enrolments
  AS
  v_sqlselect      VARCHAR2(2000);
  v_queryctx       DBMS_XMLQuery.ctxType;
  v_clob_par       CLOB;
  BEGIN
  v_sqlselect := 'SELECT *
      FROM ALUS  
      ';
  v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);
  DBMS_XMLQuery.setEncodingTag(v_queryctx, 'ISO-8859-1');
  v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
  DBMS_XMLQuery.closeContext(v_queryctx);
  htp.p(v_clob_par);
  htp.para;
  EXCEPTION
  WHEN OTHERS THEN
    htp.p(SQLERRM);
  END list_enrolments; 

  PROCEDURE list_years
  IS
  v_sqlselect      VARCHAR2(2000);
  v_queryctx       DBMS_XMLQuery.ctxType;
  v_clob_par       CLOB;
  BEGIN
  v_sqlselect := 'SELECT *
      FROM anos     
      ';
  v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);
  DBMS_XMLQuery.setEncodingTag(v_queryctx, 'ISO-8859-1');
  v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
  DBMS_XMLQuery.closeContext(v_queryctx);
  htp.p(v_clob_par);
  htp.para;
  EXCEPTION
  WHEN OTHERS THEN
    htp.p(SQLERRM);
  END list_years; 

END enrolments ;