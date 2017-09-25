<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- NOTE: Imports are virtual in the top-level XML file -->

  <!-- global variables -->
  <xsl:key match="Param" name="cgi-param" use="@name"/>
  <xsl:variable name="cgiPage" select="/Top/DlxsGlobals/CurrentCgi/Param[@name='page']"/>
  <xsl:variable name="searchType" select="/Top/SearchType"/>
  <xsl:variable name="searchHeaderText">
    <xsl:choose>
      <xsl:when test="contains( $searchType, 'simple' )">
        <xsl:value-of select="key('get-lookup','searchhistory.str.1')"/>
      </xsl:when>
      <xsl:when test="contains( $searchType, 'boolean' )">
        <xsl:value-of select="key('get-lookup','searchhistory.str.2')"/>
      </xsl:when>
      <xsl:when test="contains( $searchType, 'proximity' )">
        <xsl:value-of select="key('get-lookup','searchhistory.str.3')"/>
      </xsl:when>
      <xsl:when test="contains( $searchType, 'bib' )">
        <xsl:value-of select="key('get-lookup','searchhistory.str.4')"/>
      </xsl:when>
      <xsl:when test="contains( $searchType, 'history' )">
        <xsl:value-of select="key('get-lookup','searchhistory.str.5')"/>
      </xsl:when>
      <xsl:when test="contains( $searchType, 'wordindex' )">
        <xsl:value-of select="key('get-lookup','searchhistory.str.6')"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <!-- end global variables -->


  <xsl:template match="/Top">

    <!-- start HTML page -->
    <html>
      <head>
        <xsl:apply-templates select="DlxsGlobals" mode="BuildHeadDefaults"/>
      </head>

      <body class="defaultbody" bgcolor="#ffffff">

        <!-- Nav Header -->
        <xsl:apply-templates select="NavHeader"/>



        <div class="maincontent">
          <div class="subheader">
            <span class="blksubheader">
              <xsl:value-of select="key('get-lookup','searchhistory.str.7')"/>
            </span>
          </div>

          <table border="0" cellpadding="0" cellspacing="0">
            <tr>
              <td>
                <div class="searchblock">
                  <table border="0" cellspacing="0" cellpadding="0" width="100%">
                    <xsl:text>&#x0a;</xsl:text>

                    <!-- Build the navbar of Search type tabs -->
                    <tr>
                      <td align="left" valign="top" bgcolor="ffffff">
                        <div class="searchnavblock">
                          <xsl:call-template name="BuildNavBar">
                            <xsl:with-param name="NavItems" select="SearchNav/*"/>
                            <xsl:with-param name="NavBarType" select="'search'"/>
                          </xsl:call-template>
                        </div>
                      </td>
                    </tr>
                    <tr>
                      <td>

                        <!-- Begin search history table -->
                        <xsl:comment>begin table for search history</xsl:comment>
                        <xsl:apply-templates select="SearchHistoryTable" mode="BuildSearchHistoryTable"/>
                      </td>
                    </tr>

                  </table>
                </div>

              </td>
            </tr>
          </table>
        </div>
        <xsl:call-template name="BuildFooter" select="Footer"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="SearchHistoryTable" mode="BuildSearchHistoryTable">
    <xsl:choose>
      <xsl:when test="not(Number)">
        <div id="historyHelp">
          <br/>
          <span class="formfont"><xsl:value-of select="key('get-lookup','searchhistory.str.8')"/></span>
          <br/>
        </div>
      </xsl:when>
      <xsl:otherwise>



		<div class="searchform">
        <div id="historyHelp">
          <span class="formfont">
            <xsl:value-of select="key('get-lookup','searchhistory.str.9')"/>
          </span>
        </div>

        <table width="95%" border="0" cellspacing="1" cellpadding="5" id="historytable">
          <tr>
            <th valign="top" align="center"><span class="formfont">&#160;</span></th>
            <th valign="top" align="center"><span class="formfont">
            <xsl:value-of select="key('get-lookup','searchhistory.str.10')"/>
          </span></th>
          <th valign="top"><span class="formfont">
          <xsl:value-of select="key('get-lookup','searchhistory.str.11')"/>
        </span></th>
        <th valign="top" align="center"><span class="formfont">
        <xsl:value-of select="key('get-lookup','searchhistory.str.12')"/>
      </span></th>
    </tr>
    <xsl:for-each select="Item">
      <xsl:call-template name="BuildItemRow"/>
    </xsl:for-each>

  </table>
  </div>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="BuildItemRow">
  <tr>
    <td><xsl:value-of select="position()"/></td>
    <td>
      <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="normalize-space(Href)"/></xsl:attribute>
        <xsl:value-of select="Query"/>
      </xsl:element>
    </td>
    <td><xsl:value-of select="Collections"/></td>
    <td>

      <xsl:apply-templates select="Results"/>

    </td>
  </tr>
</xsl:template>


<xsl:template match="Results">
  <xsl:choose>
    <xsl:when test="contains(HitVariant,'childlevel')">
      <xsl:call-template name="BooleanXCHitSumm"/>
    </xsl:when>
    <xsl:when test="contains(HitVariant,'bib')">
      <xsl:call-template name="BibXCHitSumm"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="SimpleXCHitSumm"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
