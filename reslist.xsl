<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:func="http://exslt.org/functions"
  xmlns:dlxs="http://dlxs.org"
  extension-element-prefixes="func dlxs"
  exclude-result-prefixes="func dlxs">

  <!-- ____________________ Global Variables ____________________ -->
  <xsl:variable name="searchtype" select="key('get-lookup',/Top/SearchDescription/SearchTypeName)"/>
  <xsl:variable name="TotalRecs" select="/Top/ResultsLinks/SliceNavigationLinks/TotalRecordsOrItemHits"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/Top">
    <html>
      <head>
        <xsl:apply-templates select="DlxsGlobals" mode="BuildHeadDefaults"/>
      </head>
      <body class="defaultbody" bgcolor="#ffffff">
        <!-- Nav Header -->
        <xsl:apply-templates select="NavHeader">
          <xsl:with-param name="searchtype"/>
        </xsl:apply-templates>
        <!-- Main content -->
        <div class="maincontent">
          <div class="subheader">
            <span class="blksubheader">
              <xsl:value-of select="key('get-lookup','reslist.str.searchresults')"/>
            </span>
          </div>
          <!-- Main wrapping table -->
          <table width="100%" border="0" cellpadding="0" cellspacing="0">
            <tr>
              <!-- Build or don't build Guide Frame -->
              <xsl:if test="$xcmode = 'colls' or $xcmode = 'group'">
                <xsl:if test="count(/Top/GuideFrame/GuideFrameResults/Coll)&gt;1">
                  <td width="25%" valign="top" class="guideframebg">
                    <xsl:apply-templates select="GuideFrame"/>
                  </td>
                </xsl:if>
              </xsl:if>
              <!-- end Guide Frame -->
              <td width="75%" valign="top" id="res">
                <!-- search description string -->
                <xsl:apply-templates select="SearchDescription"/>
                <xsl:if test="$TotalRecs != '0'">
                  <xsl:call-template name="buildFisheyeTable"/>
                </xsl:if>
                <xsl:apply-templates select="ResList/Results" mode="Results"/>
                <div id="sliceftr">
                  <table width="98%" border="0" cellpadding="4" cellspacing="0">
                    <tr>
                      <td align="left" width="35%" nowrap="">
                        <span class="resultsheader"> </span>
                      </td>
                      <td width="65%" align="left" valign="top"> </td>
                    </tr>
                  </table>
                </div>
              </td>
            </tr>
          </table>
        </div>
        <xsl:if test="$TotalRecs != '0'">
          <xsl:call-template name="buildFisheyeTable"/>
        </xsl:if>
        <!-- FOOTER  -->
        <xsl:call-template name="BuildFooter"/>
      </body>
    </html>
  </xsl:template>

<xsl:template name="buildFisheyeTable">
    <div class="maincontent">
        <div id="slicehdr">
            <table border="0" cellpadding="0" cellspacing="0">
                <tr>
                    <td align="left" width="35%" nowrap="nowrap">
                        <!-- Build or don't build slice links -->
                        <xsl:if test="ResultsLinks/SliceNavigationLinks/*">
                            <xsl:apply-templates select="ResultsLinks/SliceNavigationLinks"/>
                        </xsl:if>
                        <!-- Build or don't build return to results link -->
                        <div class="resdetail">
                            <xsl:if test="/Top/DlxsGlobals/CurrentCgi/Param[@name='subview']='detail'">
                                <xsl:apply-templates select="ReturnToResultsLink"/>
                            </xsl:if>
                        </div>
                    </td>
                    <td width="60%" align="center" valign="top" nowrap="nowrap">
                        <xsl:choose>
                            <!-- Build or don't build sort select form -->
                            <xsl:when test="not(/Top/DlxsGlobals/CurrentCgi/Param[@name='subview']='detail')">
                                <xsl:apply-templates select="ResultsLinks" mode="sort"/>
                            </xsl:when>
                            <!-- Build or don't build previous/next links -->
                            <xsl:when test="/Top/DlxsGlobals/CurrentCgi/Param[@name='subview']='detail'">
                                <xsl:apply-templates select="ResultsLinks" mode="prevnext"/>
                            </xsl:when>
                        </xsl:choose>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</xsl:template>


  
  
  
  <!-- create sort pull down -->
  <xsl:template match="ResultsLinks" mode="sort">
    <xsl:variable name="sortResultsStr">
      <xsl:value-of select="key('get-lookup','results.str.sortresults')"/> 
    </xsl:variable>
    <div align="right" class="resultsheader">
      <xsl:choose>
        <xsl:when test="SortSelect = 'sort.overthreshold'">
          <xsl:value-of select="key('get-lookup','results.str.11')"/>
          <span color="red" style="color:red;font-style:italic;">
            <xsl:value-of select="key('get-lookup','results.str.12')"/>
          </span>
          <!-- </span> -->
        </xsl:when>
        <xsl:when test="SortSelect = ''">
          <xsl:comment>No results to sort</xsl:comment>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="form">
            <xsl:attribute name="name">sortform</xsl:attribute>
            <xsl:attribute name="method">get</xsl:attribute>
            <xsl:attribute name="action">
              <xsl:copy-of select="/Top/DlxsGlobals/ScriptName[@application='text']"/>
            </xsl:attribute>
            <xsl:value-of select="key('get-lookup','results.str.13')"/>
            <xsl:apply-templates select="SortSelect" mode="BuildHtmlSelect"/>
            <!-- with onchange="sortform.submit()" -->
            <xsl:apply-templates select="HiddenVars"/>
            <xsl:text>&#xa0;</xsl:text>
            <input type="submit" value="{$sortResultsStr}" class="selectmenu"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  <!-- results navigation templates -->
  <xsl:template match="ResultsLinks" mode="slice">
    <xsl:apply-templates select="SliceNavigationLinks"/>
  </xsl:template>
  <!--  handle Previous / Next link building -->
  <xsl:template match="ResultsLinks" mode="prevnext">
    <xsl:if test="PrevNextItemLinks/prev">
      <span class="resultsheader">
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:value-of select="PrevNextItemLinks/prev/Href"/>
          </xsl:attribute>
          <xsl:value-of select="key('get-lookup','reslist.str.previousitem')"/>
        </xsl:element>
      </span>
    </xsl:if>
    <xsl:if test="PrevNextItemLinks/prev and PrevNextItemLinks/next">
      <xsl:text> | </xsl:text>
    </xsl:if>
    <xsl:if test="PrevNextItemLinks/next">
      <span class="resultsheader">
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:value-of select="PrevNextItemLinks/next/Href"/>
          </xsl:attribute>
          <xsl:value-of select="key('get-lookup','reslist.str.nextitem')"/>
        </xsl:element>
      </span>
    </xsl:if>
  </xsl:template>
  <!-- Build fisheye links -->
  <xsl:template match="SliceNavigationLinks">
    <xsl:variable name="toStr">
      <xsl:value-of select="key('get-lookup','reslist.str.to')"/>
    </xsl:variable>
    <xsl:variable name="ofStr">
      <xsl:value-of select="key('get-lookup','reslist.str.of')"/> 
    </xsl:variable>
    <!-- *** -->
    <div class="resultsheader">
      <xsl:value-of select="concat(Start,$toStr,End,$ofStr,TotalRecordsOrItemHits,' ',key('get-lookup',OccurrenceType))"/>
      <xsl:if test="End > Start">
        <xsl:value-of select="key('get-lookup','reslist.str.plural')"/>
      </xsl:if>
      <xsl:if test="/Top/DlxsGlobals/CurrentCgi/Param[@name='subview']='detail'">
        <strong>
          <xsl:value-of select="key('get-lookup','reslist.str.inthisitem')"/>
        </strong>
      </xsl:if>
    </div>
    <xsl:if test="PrevHitsLink!=''">
      <span class="resultsheader">
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:value-of select="PrevHitsLink"/>
          </xsl:attribute>
          <xsl:value-of select="key('get-lookup','reslist.str.previous')"/>
        </xsl:element>
        <xsl:text> | </xsl:text>
      </span>
    </xsl:if>
    <xsl:apply-templates select="FisheyeLinks"/>
    <xsl:if test="NextHitsLink!=''">
      <span class="resultsheader">
        <xsl:text> | </xsl:text>
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:value-of select="NextHitsLink"/>
          </xsl:attribute>
          <xsl:value-of select="key('get-lookup','reslist.str.next')"/>
        </xsl:element>
      </span>
    </xsl:if>
  </xsl:template>
  <xsl:template match="FisheyeLinks">
    <span class="resultsheader">
      <xsl:for-each select="FisheyeLink">
        <xsl:choose>
          <!-- if there is an Href then build a link, otherwise, this is the slice in focus -->
          <xsl:when test="Href!=''">
            <xsl:element name="a">
              <xsl:attribute name="href">
                <xsl:value-of select="Href"/>
              </xsl:attribute>
              <xsl:value-of select="LinkNumber"/>
            </xsl:element>
          </xsl:when>
          <!-- slice in focus, just output the link number -->
          <xsl:otherwise>
            <span class="hilite">
              <xsl:value-of select="LinkNumber"/>
            </span>
          </xsl:otherwise>
        </xsl:choose>
        <!-- output separator after all links, but the last one -->
        <xsl:choose>
          <xsl:when test="position() = last()"/>
          <!-- do nothing -->
          <xsl:otherwise>
            <xsl:text disable-output-escaping="yes"> | </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </span>
  </xsl:template>
  <!-- search description templates -->
  <xsl:template match="SearchDescription">
    <div id="ressummarycell">
      <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td>
            <span class="resultsheader">
              <strong>
                <xsl:value-of select="key('get-lookup','reslist.str.yousearched')"/>
              </strong>
              <xsl:choose>
                <xsl:when test="SearchQualifier!=''">
                  <span class="itemid">
                    <xsl:value-of select="key('get-lookup',SearchQualifier)"/>
                  </span>
                </xsl:when>
                <xsl:otherwise>
                  <span class="collid">
                    <xsl:apply-templates select="SearchCollid"/>
                  </span>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="key('get-lookup','reslist.str.for')"/>
              <span class="naturallanguage">
                <xsl:apply-templates select="SearchInNaturalLanguage"/>
              </span>
              <br/>
              <strong>
                <xsl:value-of select="key('get-lookup','reslist.str.results')"/>
              </strong>
              <xsl:apply-templates select="CollTotals"/>
            </span>
            <br/>
            <br/>
            <span class="resultsheader">
              <xsl:element name="a">
                <xsl:attribute name="href">
                  <xsl:apply-templates select="RefineSearchLink"/>
                </xsl:attribute>
                <xsl:value-of select="key('get-lookup','reslist.str.refinesearch')"/>
              </xsl:element>
            </span>
          </td>
        </tr>
      </table>
    </div>
  </xsl:template>
  <xsl:template match="CollTotals">
    <xsl:choose>
      <xsl:when test="$searchtype='basic' or $searchtype='proximity'">
        <xsl:call-template name="SimpleXCHitSumm"/>
      </xsl:when>
      <xsl:when test="$searchtype='boolean'">
        <xsl:call-template name="BooleanXCHitSumm"/>
      </xsl:when>
      <xsl:when test="$searchtype='bibliographic'">
        <xsl:call-template name="BibXCHitSumm"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="SearchQualifier">
    <xsl:copy-of select="."/>
  </xsl:template>
  <xsl:template match="SearchTypeName">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="SearchInNaturalLanguage">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="SearchCollid">
    <xsl:choose>
      <xsl:when test="contains(.,'.')">
        <xsl:value-of select="key('get-lookup',.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="RefineSearchLink">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <!-- guide frame templates -->
  <xsl:template match="GuideFrame">
    <table width="100%" border="0" cellpadding="6" cellspacing="0">
      <tr>
        <td valign="top">
          <img src="/t/text/graphics/plug.gif" width="200" height="2"/>
          <br/>
          <span class="smallheadernormal">
            <xsl:value-of select="key('get-lookup','reslist.str.resultsbycollection')"/>
          </span>
        </td>
      </tr>
      <xsl:apply-templates select="GuideFrameResults"/>
    </table>
  </xsl:template>

  <xsl:template match="GuideFrameResults">
    <xsl:apply-templates select="Coll"/>
  </xsl:template>

  <xsl:template match="Coll">
    <tr>
      <!-- if Collection is in focus, highlight it via css -->
      <xsl:element name="td">
        <xsl:attribute name="valign">top</xsl:attribute>
        <xsl:choose>
          <xsl:when test="FocusColl">
            <xsl:attribute name="class">hilitecell</xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:element name="div">
          <xsl:choose>
            <xsl:when test="FocusColl">
              <xsl:attribute name="class">collnamefocus</xsl:attribute>
              <img src="/t/text/graphics/onbullet.gif" width="11" height="11" hspace="0" align="left"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">collname</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <span class="collnamehd">
            <xsl:choose>
              <!-- Do not build a link for the collection in focus or for any collections that have zero results -->
              <xsl:when test="Records = 0 or not(FocusColl)">
                <xsl:element name="a">
                  <xsl:attribute name="href">
                    <xsl:value-of select="CollHomeHref"/>
                  </xsl:attribute>
                  <xsl:apply-templates select="CollName" mode="gframe"/>
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="CollName" mode="gframe"/>
              </xsl:otherwise>
            </xsl:choose>
          </span>
        </xsl:element>
        <div class="collsummary">
          <span class="cresultslink">
            <xsl:apply-templates select="CollTotals"/>
            <xsl:if test="CollResultsHref/node()">
              <xsl:text>&#xa0;</xsl:text>
              <xsl:element name="a">
                <xsl:attribute name="href">
                  <xsl:value-of select="CollResultsHref"/>
                </xsl:attribute>
                <xsl:value-of select="key('get-lookup','results.str.viewresults')"/>
              </xsl:element>
            </xsl:if>
          </span>
        </div>
      </xsl:element>
    </tr>
  </xsl:template>
  
  <xsl:template match="CollName" mode="gframe">
    <xsl:choose>
      <xsl:when test="current() = 'results.allselectedcolls'">
        <xsl:value-of select="key('get-lookup',.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
