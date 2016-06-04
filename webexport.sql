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
    xsl_transform   XMLTYPE;
    xsl_result      XMLTYPE;
    
    BEGIN
    
    v_sqlselect := 'SELECT an.ANO
        FROM anos an    
        ';
    v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);
    DBMS_XMLQuery.setEncodingTag(v_queryctx, 'ISO-8859-1');
    v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
    
   xsl_transform := XMLTYPE.CREATEXML('<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:dp="http://www.datapower.com/extensions">
  
     <xsl:template match="/ROWSET">
     <dp:set-local-variable name="''counter''" value="0"/>
      db.years.insert([
         <xsl:for-each select="ROW">
        <dp:set-local-variable name="counter" value="dp:local-variable(''counter'')+1"/>
        <xsl:choose>
        <xsl:when test="not(dp:local-variable(''counter'') > 1)">
          <xsl:value-of select="ANO"/>   
          </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="ANO"/>,
      </xsl:otherwise>  
        </xsl:choose>
         </xsl:for-each>
         ]);
     </xsl:template>
    </xsl:stylesheet>');
  
    re := XMLTYPE.createXML(v_clob_par);
    
    xsl_result := re.transform(xsl => xsl_transform);
    
    
    htp.p(xsl_result.getClobVal );
    
    htp.para;
    EXCEPTION
    WHEN OTHERS THEN
      htp.p(SQLERRM);
    END export_years; 
  
  END EXPORT_DATA;



SET ECHO ON;
SET SERVEROUTPUT ON;

