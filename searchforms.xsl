<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
 <!-- import/include (needs to be first child of stylesheet element -->
 
 <!-- search query form chunks -->
 <xsl:template name="SearchForm" mode="SearchForm" match="*">
  <tr>
   <!-- not included in DlxsGlobals -->
   <xsl:apply-templates select="HiddenVars"/>
   <xsl:element name="input">
    <xsl:attribute name="type">hidden</xsl:attribute>
    <xsl:attribute name="name">type</xsl:attribute>
    <xsl:attribute name="value">
     <xsl:choose>
      <xsl:when test="contains($searchtype, 'bbag')">
       <xsl:text>simple</xsl:text>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="$searchtype"/>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:attribute>
   </xsl:element>
   <!-- if bbag, set rgn to 'fulltext' -->
   <xsl:if test="contains($searchtype, 'bbag')">
    <xsl:element name="input">
     <xsl:attribute name="type">hidden</xsl:attribute>
     <xsl:attribute name="name">rgn</xsl:attribute>
     <xsl:attribute name="value">full text</xsl:attribute>
    </xsl:element>
    <xsl:element name="input">
     <xsl:attribute name="type">hidden</xsl:attribute>
     <xsl:attribute name="name">bookbag</xsl:attribute>
     <xsl:attribute name="value">1</xsl:attribute>
    </xsl:element>
   </xsl:if>
   <td colspan="2" align="left" valign="top">
    <table border="0" cellspacing="0" cellpadding="7" style="margin-top:10px">
     <xsl:choose>
      <!-- basic form -->
      <xsl:when test="contains($searchtype, 'simple')">
       <xsl:apply-templates select="SearchQuery" mode="simpleQ"/>
      </xsl:when>
      <!-- boolean form -->
      <xsl:when test="contains($searchtype, 'boolean')">
       <xsl:apply-templates mode="booleanQ" select="SearchQuery"/>
      </xsl:when>
      <!-- proximity search form -->
      <xsl:when test="contains($searchtype,'proximity')">
       <xsl:apply-templates mode="proximityQ" select="SearchQuery"/>
      </xsl:when>
      <!-- Bib search form -->
      <xsl:when test="contains($searchtype, 'bib')">
       <xsl:apply-templates mode="bibQ" select="SearchQuery"/>
      </xsl:when>
     </xsl:choose>
     <tr bgcolor="#ffffff">
      <td align="right" valign="top" class="nobreak">
       <strong>
         <span class="redformfont"><xsl:value-of select="key('get-lookup','searchforms.str.tip')"/> :</span>
       </strong>
      </td>
      <td colspan="2" align="left" valign="top" class="nobreak">
       <p>
        <span class="smallformfont">
         <xsl:value-of select="key('get-lookup','searchforms.str.1')"/>
        </span>
        <br/>
        <span class="smallformfont">
         <xsl:value-of select="key('get-lookup','searchforms.str.2')"/>
        </span>
       </p>
       <xsl:if test="//SearchTips/Show = 'false'">
        <span class="smallformfont">
         <xsl:element name="a">
          <xsl:attribute name="href">
           <xsl:value-of select="normalize-space(//SearchTips/Url)"/>
          </xsl:attribute>
         </xsl:element>
        </span>
       </xsl:if>
      </td>
     </tr>
     <!-- Cite Resctictions -->
     <xsl:if test="CiteRestrictions and not(contains($searchtype, 'bib'))">
      <xsl:apply-templates mode="makeCiteRestrict" select="CiteRestrictions"/>
     </xsl:if>
     <!-- Other collection-specific Resctictions -->
     <xsl:if test="OtherRestrictions and not(contains($searchtype, 'bib'))">
      <xsl:apply-templates mode="makeOtherRestrict" select="OtherRestrictions"/>
     </xsl:if>
     <tr>
      <td colspan="2" align="center">
       <input name="Submit" type="submit" value="Search"/>
      </td>
     </tr>
    </table>
   </td>
  </tr>
 </xsl:template>
 <!-- templates for various versions of the main query form -->
 <!-- here is the simple form -->
 <xsl:template match="SearchQuery" mode="simpleQ">
  <xsl:comment>Simple Search form</xsl:comment>
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td align="right" nowrap="nowrap">
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.4')"/>
    </span>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td width="103" align="left">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:choose>
     <xsl:when test="contains($searchtype, 'bbag')">
      <strong>
       <span class="formfont">
        <xsl:value-of select="key('get-lookup','searchforms.str.5')"/>
       </span>
      </strong>
     </xsl:when>
     <xsl:otherwise>
      <xsl:apply-templates select="RegionSearchSelect" mode="BuildHtmlSelect"/>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td align="right">
    <xsl:text>&#x0a;</xsl:text>
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.6')"/>
    </span>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td align="left" nowrap="nowrap">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Q1" mode="BuildHtmlTextInput"/>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
 </xsl:template>
 <!-- here is the boolean form -->
 <xsl:template match="SearchQuery" mode="booleanQ">
  <xsl:comment>Boolean Search Form</xsl:comment>
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td align="right" nowrap="nowrap">
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.7')"/>
    </span>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td width="103" align="left">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:choose>
     <xsl:when test="contains($searchtype, 'bbag')">
      <xsl:value-of select="key('get-lookup','searchforms.str.8')"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:apply-templates select="RegionSearchSelect" mode="BuildHtmlSelect"/>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td align="right">
    <xsl:text>&#x0a;</xsl:text>
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.9')"/>
    </span>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td align="left" nowrap="nowrap">
    <xsl:text>&#x0a;</xsl:text>
    (
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Q1" mode="BuildHtmlTextInput"/>
    <xsl:text>&#xa0;</xsl:text>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Op2" mode="BuildHtmlSelect"/>
    <xsl:text>&#xa0;</xsl:text>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Q2" mode="BuildHtmlTextInput"/>
    <xsl:text>&#xa0;</xsl:text>
    <xsl:text>&#x0a;</xsl:text>
    )
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td>
    <xsl:text>&#xa0;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Op3" mode="BuildHtmlSelect"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:text>&#xa0;</xsl:text>
    <xsl:apply-templates select="Q3" mode="BuildHtmlTextInput"/>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
 </xsl:template>
 <!-- here is the proximity form -->
 <xsl:template match="SearchQuery" mode="proximityQ">
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td align="right" nowrap="nowrap">
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.10')"/>
    </span>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td width="103" align="left">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:choose>
     <xsl:when test="contains($searchtype, 'bbag')">
      <xsl:value-of select="key('get-lookup','searchforms.str.11')"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:apply-templates select="RegionSearchSelect" mode="BuildHtmlSelect"/>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td align="right">
    <xsl:text>&#x0a;</xsl:text>
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.12')"/>
    </span>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td align="left" nowrap="nowrap">
    <xsl:text>&#x0a;</xsl:text>
    (
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Q1" mode="BuildHtmlTextInput"/>
    <xsl:text>&#xa0;</xsl:text>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Op2" mode="BuildHtmlSelect"/>
    <xsl:text>&#xa0;</xsl:text>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td nowrap="nowrap">
    <xsl:text>&#xa0;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:text>&#xa0;</xsl:text>
    <xsl:apply-templates select="Q2" mode="BuildHtmlTextInput"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Amt2" mode="BuildHtmlSelect"/>
    <xsl:text>&#x0a;&#xa0;</xsl:text>
    <xsl:text>&#x0a;</xsl:text>
    )
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td align="right">
    <xsl:text>&#xa0;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td align="left" valign="top" nowrap="nowrap">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Op3" mode="BuildHtmlSelect"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:text>&#xa0;</xsl:text>
    <xsl:apply-templates select="Q3" mode="BuildHtmlTextInput"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:text>&#xa0;</xsl:text>
    <xsl:apply-templates select="Amt3" mode="BuildHtmlSelect"/>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
 </xsl:template>
 <!-- here is the bib form -->
 <xsl:template match="SearchQuery" mode="bibQ">
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td align="right">
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.13')"/>
    </span>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td align="left" nowrap="nowrap">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Q1" mode="BuildHtmlTextInput"/>
    <xsl:text>&#x0a;&#xa0;</xsl:text>
    <span class="formfont">in</span>
    <xsl:text>&#xa0;&#x0a;</xsl:text>
    <xsl:apply-templates select="Region1SearchSelect" mode="BuildHtmlSelect"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Op2" mode="BuildHtmlSelect"/>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td align="right">
    <xsl:text>&#xa0;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td align="left" nowrap="nowrap">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Q2" mode="BuildHtmlTextInput"/>
    <xsl:text>&#x0a;&#xa0;</xsl:text>
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.14')"/>
    </span>
    <xsl:text>&#xa0;&#x0a;</xsl:text>
    <xsl:apply-templates select="Region2SearchSelect" mode="BuildHtmlSelect"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Op3" mode="BuildHtmlSelect"/>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td align="right">
    <xsl:text>&#xa0;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td align="left" nowrap="nowrap">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="Q3" mode="BuildHtmlTextInput"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:text>&#xa0;</xsl:text>
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.15')"/>
    </span>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:text>&#xa0;</xsl:text>
    <xsl:apply-templates select="Region3SearchSelect" mode="BuildHtmlSelect"/>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
  </tr>
  <xsl:text>&#x0a;</xsl:text>
 </xsl:template>
 <!-- end of the various main query forms -->
 <!-- Begin cite restrictions -->
 <xsl:template match="CiteRestrictions" mode="makeCiteRestrict">
  <tr bgcolor="#ffffff">
   <xsl:text>&#x0a;</xsl:text>
   <td align="right" valign="top" class="nobreak" bgcolor="#ffffff">
    <xsl:text>&#x0a;</xsl:text>
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.16')"/>
    </span>
    <xsl:text>&#x0a;</xsl:text>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td colspan="2" align="left" class="nobreak">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:for-each select="Cite">
     <!-- html input for the cite restriction -->
     <xsl:apply-templates select="Input" mode="BuildHtmlTextInput"/>
     <xsl:text>&#x0a;
            &#xa0;</xsl:text>
     <span class="formfont">
      <xsl:value-of select="key('get-lookup','searchforms.str.17')"/>
     </span>&#xa0; <xsl:text>&#x0a;</xsl:text>
     <xsl:apply-templates select="Restrict" mode="BuildHtmlSelect"/>
     <!-- if this is the last Cite, then insert "and" -->
     <xsl:if test="position()!=last()">
      <xsl:text>&#x0a;
              &#xa0;</xsl:text>
      <div class="formfont" style="margin:3px">
       <xsl:value-of select="key('get-lookup','searchforms.str.18')"/>
      </div>
     </xsl:if>
    </xsl:for-each>
   </td>
  </tr>
 </xsl:template>
 <!-- Begin collection specific restrictions -->
 <xsl:template match="OtherRestrictions" mode="makeOtherRestrict">
  <xsl:if test="GenreSelect/*">
   <xsl:call-template name="GenreSelect"/>
  </xsl:if>
  <xsl:if test="GenderSelect/*">
   <xsl:call-template name="GenderSelect"/>
  </xsl:if>
  <xsl:if test="PeriodSelect/*">
   <xsl:call-template name="PeriodSelect"/>
  </xsl:if>
  <xsl:if test="PubBetweenSelect/*">
   <xsl:call-template name="PubBetweenSelect"/>
  </xsl:if>
 </xsl:template>
 <xsl:template name="GenreSelect">
  <tr>
   <td bgcolor="#ffffff" align="right" class="nobreak">
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.19')"/>
    </span>
   </td>
   <td colspan="2" bgcolor="#ffffff" class="nobreak">
    <xsl:apply-templates select="GenreSelect" mode="BuildHtmlSelect"/>
   </td>
  </tr>
 </xsl:template>
 <xsl:template name="GenderSelect">
  <tr>
   <td bgcolor="#ffffff" align="right" class="nobreak">
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.20')"/>
    </span>
   </td>
   <td colspan="2" bgcolor="#ffffff" class="nobreak">
    <xsl:apply-templates select="GenderSelect" mode="BuildHtmlSelect"/>
   </td>
  </tr>
 </xsl:template>
 <xsl:template name="PeriodSelect">
  <tr>
   <td bgcolor="#ffffff" align="right" class="nobreak">
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.21')"/>
    </span>
   </td>
   <td colspan="2" bgcolor="#ffffff" class="nobreak">
    <xsl:apply-templates select="PeriodSelect" mode="BuildHtmlSelect"/>
   </td>
  </tr>
 </xsl:template>
 <xsl:template name="PubBetweenSelect">
  <tr>
   <td bgcolor="#ffffff" align="right" class="nobreak">
    <xsl:text>&#x0a;</xsl:text>
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.22')"/>
    </span>
   </td>
   <xsl:text>&#x0a;</xsl:text>
   <td colspan="2" bgcolor="#ffffff" class="nobreak">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="PubBetweenSelect/FromSelect" mode="BuildHtmlSelect"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:value-of select="key('get-lookup','searchforms.str.23')"/>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:apply-templates select="PubBetweenSelect/ToSelect" mode="BuildHtmlSelect"/>
    <xsl:text>&#x0a;</xsl:text>
   </td>
  </tr>
 </xsl:template>
 <xsl:template match="CheckboxInclude">
  <tr>
   <!-- begin new table -->
   <td width="10" rowspan="2" align="left" valign="top" bgcolor="#ffffffffffff">
    <a name="clist"/>&#xa0;</td>
   <td align="left" valign="top" bgcolor="#ffffffffffff">
    <span class="formfont">
     <xsl:value-of select="key('get-lookup','searchforms.str.24')"/>
     <strong>
      <span class="collmenuhilite">&#xa0; &#xa0;&#xa0;</span>
     </strong>
     <br/>
     <br/>
     <xsl:value-of select="key('get-lookup','searchforms.str.25')"/>
    </span>
   </td>
  </tr>
  <tr bgcolor="#ffffffffffff">
   <td align="left" valign="top">
    <input type="button" value="uncheck all" onclick="clearAllRecords(this.form);"/>
    <input type="button" value="check all" onclick="checkAllRecords(this.form);"/>
   </td>
  </tr>
  <tr>
   <td width="10" valign="top" bgcolor="#ffffffffffff">&#xa0;</td>
   <td valign="top" bgcolor="#ffffffffffff">
    <table border="0" cellspacing="0" cellpadding="2" summary="list of collections checkboxes">
     <xsl:apply-templates select="CollCheckboxList"/>
    </table>
    <!-- end coll list table -->
   </td>
  </tr>
  <tr>
   <td align="right" valign="top" bgcolor="#ffffffffffff">&#xa0;</td>
   <td valign="top" bgcolor="#ffffffffffff">&#xa0;</td>
  </tr>
  <tr>
   <td align="right" valign="top" bgcolor="#ffffffffffff">&#xa0;</td>
   <td valign="top" bgcolor="#ffffffffffff">&#xa0;</td>
  </tr>
 </xsl:template>
</xsl:stylesheet>
