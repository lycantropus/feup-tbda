create or replace PACKAGE BODY WEB_DATA
AS

  PROCEDURE json_cands
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
   xsl_transform := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="utf-8"?>
 <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
   <xsl:template match="/ROWSET">
      {
"cands": [
      <xsl:for-each select="ROW">
      	{
        "bi": "<xsl:value-of select="BI" />",
         "curso": {
         "codigo": <xsl:value-of select="CURSO/CURSO_ROW/CODIGO" />,
         "sigla": "<xsl:value-of select="CURSO/CURSO_ROW/SIGLA" />",
         "nome": "<xsl:value-of select="CURSO/CURSO_ROW/NOME" />"
         },
         "ano_lectivo": <xsl:value-of select="ANO_LECTIVO" />,
         "resultado": "<xsl:value-of select="RESULTADO" />"
         <xsl:if test="MEDIA">,
         "media": <xsl:value-of select="MEDIA" />
         </xsl:if>
        }
        <xsl:if test="./following-sibling::ROW">,</xsl:if>
      </xsl:for-each> 
      ]}
   </xsl:template>
</xsl:stylesheet>');
  
    re := XMLTYPE.createXML(v_clob_par);
    
    xsl_result := re.transform(xsl => xsl_transform);
    
    v_clob_par := xsl_result.getClobVal();
    
    loop
      exit when v_offset > dbms_lob.getlength(v_clob_par);
      htp.prn(dbms_lob.substr(v_clob_par, v_chunk_size, v_offset));
      v_offset := v_offset +  v_chunk_size;
    end loop;
  END json_cands; 
  
  PROCEDURE json_alus
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
      WHERE a.CURSO = l.codigo) as curso,
      CURSOR(SELECT c.bi, c.curso, c.ano_lectivo, c.resultado, c.media
      FROM cands c
      WHERE c.BI = a.BI AND c.CURSO = a.CURSO AND c.ano_lectivo = a.a_lect_matricula) as cand
    FROM ALUS a
    ';
    v_queryctx := DBMS_XMLQuery.newContext(v_sqlselect);
    DBMS_XMLQuery.setEncodingTag(v_queryctx, 'ISO-8859-1');
    v_clob_par := DBMS_XMLQuery.getXML(v_queryctx);
    DBMS_XMLQuery.closeContext(v_queryctx);
    xsl_transform := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="utf-8"?>
 <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
   <xsl:template match="/ROWSET">
      {
"alus": [
      <xsl:for-each select="ROW">
      	{
         "numero": "<xsl:value-of select="NUMERO" />",
         "bi": "<xsl:value-of select="BI" />",
         "curso": {
         "codigo": <xsl:value-of select="CURSO/CURSO_ROW/CODIGO" />,
         "sigla": "<xsl:value-of select="CURSO/CURSO_ROW/SIGLA" />",
         "nome": "<xsl:value-of select="CURSO/CURSO_ROW/NOME" />"
         },
         "a_lect_matricula": <xsl:value-of select="A_LECT_MATRICULA" />,
         "estado": "<xsl:value-of select="ESTADO" />",
         <xsl:if test="A_LECT_CONCLUSAO">
         "a_lect_conclusao": <xsl:value-of select="A_LECT_CONCLUSAO" />,
         </xsl:if>
         <xsl:if test="MED_FINAL">
         "med_final": <xsl:value-of select="MED_FINAL" />,
         </xsl:if>
         "cand": {
          "resultado": "<xsl:value-of select="CAND/CAND_ROW/RESULTADO" />"
          <xsl:if test="CAND/CAND_ROW/MEDIA">,
          "media": <xsl:value-of select="CAND/CAND_ROW/MEDIA" />
          </xsl:if>
         }
        }
        <xsl:if test="./following-sibling::ROW">,</xsl:if>
      </xsl:for-each> 
      ]}
   </xsl:template>
</xsl:stylesheet>');
  
    re := XMLTYPE.createXML(v_clob_par);
    
    xsl_result := re.transform(xsl => xsl_transform);
    
    v_clob_par := xsl_result.getClobVal();
    
    loop
      exit when v_offset > dbms_lob.getlength(v_clob_par);
      htp.prn(dbms_lob.substr(v_clob_par, v_chunk_size, v_offset));
      v_offset := v_offset +  v_chunk_size;
    end loop;
  END json_alus; 


  PROCEDURE json_years
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
    
   xsl_transform := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="UTF-8"?>
 <xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
   <xsl:template match="/ROWSET">
      {
"anos":[
      <xsl:for-each select="ROW">
         <xsl:value-of select="ANO" />
         
         <xsl:if test="./following-sibling::ROW">,</xsl:if>
      </xsl:for-each>
      ]
      }
   </xsl:template>
</xsl:stylesheet>');
  
    re := XMLTYPE.createXML(v_clob_par);
    
    xsl_result := re.transform(xsl => xsl_transform);    
    htp.prn(xsl_result.getClobVal );
    EXCEPTION
    WHEN OTHERS THEN
      htp.p(SQLERRM);
  END json_years;

END WEB_DATA;