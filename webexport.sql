create or replace PACKAGE         EXPORT_DATA
  IS

    PROCEDURE export_cands;
    
    PROCEDURE export_alus;
    
    PROCEDURE export_years;

END EXPORT_DATA;


create or replace PACKAGE BODY EXPORT_DATA
AS

  PROCEDURE export_cands
  IS
  v_sqlselect      VARCHAR2(2000);
  v_queryctx       DBMS_XMLQuery.ctxType;
  v_clob_par        CLOB;
  v_offset number default 1;
  v_chunk_size number := 10000;
  begin
    v_sqlselect := 'SELECT c.BI, c.CURSO, c.ANO_LECTIVO, c.RESULTADO, c.MEDIA
    FROM CANDS c
    ';
    v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);
    DBMS_XMLQuery.setEncodingTag(v_queryctx, 'ISO-8859-1');
    v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
    DBMS_XMLQuery.closeContext(v_queryctx);
    loop
      exit when v_offset > dbms_lob.getlength(v_clob_par);
      htp.p( dbms_lob.substr( v_clob_par, v_chunk_size, v_offset ) );
      htp.para;
      v_offset := v_offset +  v_chunk_size;
    end loop;
  END export_cands; 

  PROCEDURE export_alus
  AS
  v_sqlselect      VARCHAR2(2000);
  v_queryctx       DBMS_XMLQuery.ctxType;
  v_clob_par       CLOB;
  v_offset number default 1;
  v_chunk_size number := 10000;
  BEGIN
    v_sqlselect := 'SELECT a.NUMERO, a.BI, a.CURSO, a.A_LECT_MATRICULA, a.ESTADO, a.A_LECT_CONCLUSAO, a.MED_FINAL
        FROM ALUS a 
        ';
    v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);
    DBMS_XMLQuery.setEncodingTag(v_queryctx, 'ISO-8859-1');
    DBMS_XMLQUERY.SETSTYLESHEETHEADER(v_queryctx, 'xml2json.xsl');
    v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
    
    DBMS_XMLQuery.closeContext(v_queryctx);
    loop
      exit when v_offset > dbms_lob.getlength(v_clob_par);
      htp.p( dbms_lob.substr( v_clob_par, v_chunk_size, v_offset ) );
      htp.para;
      v_offset := v_offset +  v_chunk_size;
    end loop;
  EXCEPTION
  WHEN OTHERS THEN
    htp.p(SQLERRM);
  END export_alus; 



  PROCEDURE export_years
  IS
  v_sqlselect      VARCHAR2(2000);
  v_queryctx       DBMS_XMLQuery.ctxType;
  v_clob_par       CLOB;
  re               XMLTYPE;
  BEGIN
  v_sqlselect := 'SELECT an.ANO
      FROM anos an    
      ';
  v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);
  DBMS_XMLQuery.setEncodingTag(v_queryctx, 'ISO-8859-1');
  v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
  DBMS_XMLQuery.closeContext(v_queryctx);
  --htp.p(v_clob_par);
  re := XMLTYPE.createXML(v_clob_par);
  
  DBMS_OUTPUT.PUT_LINE(re.getstringval());
  --htp.para;
  EXCEPTION
  WHEN OTHERS THEN
    htp.p(SQLERRM);
  END export_years; 

END EXPORT_DATA;


