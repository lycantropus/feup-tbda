/*create table alus as select * from gtd2.alus;
create table anos as select * from gtd2.anos;
create table cands as select * from gtd2.cands;
create table lics as select * from gtd2.lics;
*/

create or replace PACKAGE XML_DATA
  IS

    PROCEDURE xml_cands;
    
    PROCEDURE xml_alus;
    
    PROCEDURE xml_years;

END XML_DATA;

create or replace PACKAGE BODY XML_DATA
AS

  PROCEDURE xml_cands
  IS
  v_sqlselect      VARCHAR2(2000);
  v_queryctx       DBMS_XMLQuery.ctxType;
  v_clob_par        CLOB;
  v_offset number default 1;
  v_chunk_size number := 10000;
  re              XMLTYPE;
  xsl_transform   XMLTYPE;
  xsl_result      XMLTYPE;
  
  begin
    v_sqlselect := 'SELECT c.BI, c.CURSO, c.ANO_LECTIVO, c.RESULTADO, c.MEDIA,
      CURSOR(SELECT l.codigo, l.sigla, l.nome
      FROM lics l
      WHERE c.CURSO = l.codigo) as curso
    FROM CANDS c
    ';
    v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);
    DBMS_XMLQuery.setEncodingTag(v_queryctx, 'ISO-8859-1');
    v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
    DBMS_XMLQuery.closeContext(v_queryctx);
    loop
      exit when v_offset > dbms_lob.getlength(v_clob_par);
      htp.p( dbms_lob.substr(v_clob_par, v_chunk_size, v_offset ) );
      v_offset := v_offset +  v_chunk_size;
    end loop;
  END xml_cands; 
  
  
  PROCEDURE xml_alus
  IS
  v_sqlselect      VARCHAR2(2000);
  v_queryctx       DBMS_XMLQuery.ctxType;
  v_clob_par        CLOB;
  v_offset number default 1;
  v_chunk_size number := 10000;
  re              XMLTYPE;
  xsl_transform   XMLTYPE;
  xsl_result      XMLTYPE;
  
  BEGIN
    v_sqlselect := 'SELECT a.NUMERO, a.BI, a.CURSO, a.A_LECT_MATRICULA, a.ESTADO, a.A_LECT_CONCLUSAO, a.MED_FINAL,
      CURSOR(SELECT l.codigo, l.sigla, l.nome
      FROM lics l
      WHERE a.CURSO = l.codigo) as curso
    FROM ALUS a
    ';
    v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);
    DBMS_XMLQuery.setEncodingTag(v_queryctx, 'ISO-8859-1');
    v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
    DBMS_XMLQuery.closeContext(v_queryctx);
    
    loop
      exit when v_offset > dbms_lob.getlength(v_clob_par);
      htp.p( dbms_lob.substr(v_clob_par, v_chunk_size, v_offset ) );
      v_offset := v_offset +  v_chunk_size;
    end loop;
  END xml_alus; 


  PROCEDURE xml_years
      IS
    v_sqlselect      VARCHAR2(2000);
    v_queryctx       DBMS_XMLQuery.ctxType;
    v_clob_par       CLOB;
    re               XMLTYPE;
    xsl_transform   XMLTYPE;
    xsl_result      XMLTYPE;
    
    BEGIN
    
    v_sqlselect := 'SELECT an.ANO
        FROM anos an    
        ';
    v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);
    DBMS_XMLQuery.setEncodingTag(v_queryctx, 'ISO-8859-1');
    v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
  
    htp.p(xsl_result.getClobVal );
    EXCEPTION
    WHEN OTHERS THEN
      htp.p(SQLERRM);
  END xml_years;

END XML_DATA;
