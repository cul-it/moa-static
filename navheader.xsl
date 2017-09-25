<?xml version="1.0" encoding="UTF-8" ?>



<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- this attribute set applies to nav button table cells -->

  <xsl:attribute-set name="navtab-base">

    <xsl:attribute name="height">20</xsl:attribute>

    <xsl:attribute name="align">center</xsl:attribute>

    <xsl:attribute name="nowrap">nowrap</xsl:attribute>

  </xsl:attribute-set>

  <xsl:attribute-set name="navtable-base">

    <xsl:attribute name="border">0</xsl:attribute>

    <xsl:attribute name="cellspacing">0</xsl:attribute>

    <xsl:attribute name="cellpadding">0</xsl:attribute>

  </xsl:attribute-set>

  <!-- Global variables -->

  <xsl:variable name="cgiNode" select="/Top/DlxsGlobals/CurrentCgi"/>

  <xsl:template match="NavHeader">

    <xsl:param name="searchtype"/>

    <xsl:call-template name="buildNavHeadTable"/>
	<div id="nav-container">
    	<div id="navigation">
            <!-- this row contains a table controlling layout for the nav tabs themselves   -->
            <!-- remove unnecessary table layout <table width="100%" border="0" cellspacing="2" cellpadding="0" id="navwrapper">
              
        
              <tr>
        
                <td class="navcolor" colspan="2" align="left">-->
        
        
                  <xsl:call-template name="BuildNavBar">
        
                    <xsl:with-param name="NavItems" select="MainNav/*"/>
        
                    <xsl:with-param name="NavBarType" select="'main'"/>
        
                    <xsl:with-param name="searchtype" select="$searchtype"/>
        
                  </xsl:call-template>
        
                <!-- remove unnecessary table layout
                </td>
        
              </tr>
        
            </table>-->
    	</div>
	</div>
  </xsl:template>

  <xsl:template name="buildNavHeadTable">

    <xsl:variable name="hdrstyle">

      <xsl:choose>

        <xsl:when test="/Top/DlxsGlobals/XcollMode='colls'">

          <xsl:value-of select="'xchdrcolor'"/>

        </xsl:when>

        <xsl:otherwise>

          <xsl:value-of select="'hdrcolor'"/>

        </xsl:otherwise>

      </xsl:choose>

    </xsl:variable>

    <div class="navheadTable">

      <table width="100%" border="0" cellspacing="0" cellpadding="2">

        <tr>

          <xsl:element name="td">

            <xsl:attribute name="height">43</xsl:attribute>

            <xsl:attribute name="id">hdr1</xsl:attribute>

            <xsl:attribute name="align">left</xsl:attribute>

            <xsl:attribute name="class">

              <xsl:value-of select="$hdrstyle"/>

            </xsl:attribute>

            <a name="top"/>

            <!-- in templates, logo is rendered as TITLE mode="complex" -->

            <xsl:element name="a">

              <xsl:attribute name="href">

                <xsl:value-of select="MainNav/NavItem[Name='home']/Link"/>

              </xsl:attribute>

			  <xsl:attribute name="class">border-none</xsl:attribute>

              <xsl:attribute name="target">_top</xsl:attribute>

              <xsl:apply-templates select="/Top/DlxsGlobals/TitleComplex"/>

            </xsl:element>

          </xsl:element>

          <xsl:element name="td">

            <xsl:attribute name="valign">top</xsl:attribute>

            <xsl:attribute name="align">right</xsl:attribute>

            <xsl:attribute name="id">hdr2</xsl:attribute>

            <xsl:attribute name="class">

              <xsl:value-of select="$hdrstyle"/>

            </xsl:attribute>

            <table border="0" cellspacing="0" cellpadding="1">

              <tr>

                <xsl:if test="$dlxsTemp != 'bbag'">

                  <td>

                    <div class="navinfo">

                      <xsl:call-template name="BookbagItemsIframe"/>

                    </div>

                    <xsl:text disable-output-escaping="yes">&#xa0;</xsl:text>

                  </td>

                </xsl:if>

              </tr>

            </table>

          </xsl:element>

        </tr>

      </table>

    </div>

  </xsl:template>

  <!-- Build string, in an iframe, saying how many items are in the bookbag -->

  <xsl:template name="BookbagItemsIframe">

    <xsl:variable name="bookbagItemCount" select="/Top/NavHeader/BookbagItems"/>

    <xsl:variable name="webDir" select="substring-after($cachedirpath,'web')"/>

    <xsl:variable name="bookbagStringHtmlFilename">bookbagitemsstring.html</xsl:variable>

    <xsl:element name="iframe">

      <xsl:attribute name="id">BBwindow</xsl:attribute>

      <xsl:attribute name="name">BBwindow</xsl:attribute>

      <xsl:attribute name="height">20</xsl:attribute>

      <xsl:attribute name="width">200</xsl:attribute>

      <xsl:attribute name="marginwidth">0</xsl:attribute>

      <xsl:attribute name="frameborder">0</xsl:attribute>

      <xsl:attribute name="scrolling">no</xsl:attribute>

      <xsl:attribute name="src">

        <xsl:value-of select="concat($webDir,$bookbagStringHtmlFilename)"/>

      </xsl:attribute>

    </xsl:element>

    <!-- ____________________ Write the document to disk ____________________ -->

    <xsl:call-template name="BuildBookbagContainsString">

      <xsl:with-param name="mode">writetodisk</xsl:with-param>

      <xsl:with-param name="cachedirpath" select="$cachedirpath"/>

      <xsl:with-param name="bookbagStringHtmlFilename" select="$bookbagStringHtmlFilename"/>

      <xsl:with-param name="bookbagItemCount" select="$bookbagItemCount"/>

    </xsl:call-template>

  </xsl:template>

  <!-- TitleComplex template -->

  <xsl:template match="TitleComplex">

    <xsl:choose>

      <xsl:when test="img">

        <xsl:copy-of select="*"/>

      </xsl:when>

      <xsl:otherwise>

        <h3 class="topheadlink">

          <xsl:value-of select="."/>

        </h3>

      </xsl:otherwise>

    </xsl:choose>

  </xsl:template>

  <!-- nav bar utility templates -->

  <xsl:template name="BuildNavBar">

    <xsl:param name="NavItems"/>

    <xsl:param name="NavBarType"/>

    <xsl:param name="searchtype"/>

    <!-- this will add an 'xc' to any help file name,

         when building links to help files later -->

    <xsl:variable name="xcHelpLinkPrefix">

      <xsl:choose>

        <xsl:when test="$xcmode='singlecoll'">

          <xsl:text/>

        </xsl:when>

        <xsl:otherwise>

          <xsl:text>xc</xsl:text>

        </xsl:otherwise>

      </xsl:choose>

    </xsl:variable>

    <!-- NavBarType is either 'search' or 'main' -->

    <xsl:element name="table" use-attribute-sets="navtable-base">

      <xsl:choose>

        <xsl:when test="$NavBarType = 'search' or $NavBarType = 'bbag'">

          <xsl:attribute name="id">searchnav</xsl:attribute>

        </xsl:when>

        <xsl:otherwise>

          <xsl:attribute name="id">mainnav</xsl:attribute>

        </xsl:otherwise>

      </xsl:choose>

      <tr>

        <!-- build blank cell at beginning -->

        <!-- build individual tabs from navitems -->

        <xsl:for-each select="$NavItems">

          <xsl:if test="Tab='true'">

            <!-- For localization of nav link labels:

                 Build a langmap lookup key from the

                 hard-coded Name element.  -->

            <xsl:variable name="key">

              <xsl:text>navheader.str.</xsl:text>

              <xsl:value-of select="Name"/>

            </xsl:variable>

            <xsl:variable name="label">

              <xsl:value-of select="key('get-lookup', $key)"/>

            </xsl:variable>

            <xsl:call-template name="BuildNavButton">

              <xsl:with-param name="label" select="$label"/>

              <xsl:with-param name="url">

                <xsl:choose>

                  <xsl:when test="$NavBarType='search'">

                    <xsl:value-of

                      select="concat(Link,';tips=',/Top/DlxsGlobals/CurrentCgi/Param[@name='tips'])"

                    />

                  </xsl:when>

                  <xsl:when test="$NavBarType = 'bbag'">

                    <xsl:value-of

                      select="concat(Link,';tips=',/Top/DlxsGlobals/CurrentCgi/Param[@name='tips'])"

                    />

                  </xsl:when>

                  <xsl:when test="$NavBarType= 'main' and Name = 'help'">

                    <xsl:value-of select="Link"/>

                  </xsl:when>

                  <xsl:otherwise>

                    <xsl:value-of select="Link"/>

                  </xsl:otherwise>

                </xsl:choose>

              </xsl:with-param>

              <xsl:with-param name="type">

                <xsl:choose>

                  <xsl:when test="$NavBarType='bbag'">

                    <xsl:value-of select="'search'"/>

                  </xsl:when>

                  <xsl:otherwise>

                    <xsl:value-of select="$NavBarType"/>

                  </xsl:otherwise>

                </xsl:choose>

              </xsl:with-param>

              <xsl:with-param name="state">

                <xsl:choose>

                  <xsl:when test="$NavBarType='search'">

                    <xsl:value-of select="/Top/DlxsGlobals/CurrentCgi/Param[@name='page']"/>

                  </xsl:when>

                  <xsl:when test="$NavBarType='bbag'">

                       <xsl:choose>

                       	<xsl:when test="/Top/DlxsGlobals/CurrentCgi/Param[@name='page']='booleanbbag'">

                       		<xsl:value-of select="'boolean'"/>

                       	</xsl:when>

                       	<xsl:when test="/Top/DlxsGlobals/CurrentCgi/Param[@name='page']='proximitybbag'">

                       		<xsl:value-of select="'proximity'"/>

                       	</xsl:when>

                        <xsl:otherwise>

                            <xsl:value-of select="'simple'"/>                       	

                        </xsl:otherwise>

                       </xsl:choose>

                  </xsl:when>

                  <xsl:otherwise>

                    <xsl:value-of select="$dlxsTemp"/>

                  </xsl:otherwise>

                </xsl:choose>

              </xsl:with-param>

            </xsl:call-template>

            <!-- build another blank cell at end -->

            <xsl:if test="position()!=last()">

              <xsl:call-template name="BuildNavBarBlankCell"/>

            </xsl:if>

          </xsl:if>

        </xsl:for-each>

      </tr>

    </xsl:element>

  </xsl:template>

  <!-- template for building a blank cell for navbar -->

  <xsl:template name="BuildNavBarBlankCell">

    <td width="2" class="blank">

      <img src="/t/text/graphics/plug.gif" width="2" height="23" border="0" vspace="0" hspace="0"

        alt=""/>

    </td>

  </xsl:template>

  <!-- template for building a search button for the search types navbar -->

  <xsl:template name="BuildNavButton">

    <xsl:param name="label"/>

    <xsl:param name="url"/>

    <xsl:param name="type"/>

    <xsl:param name="state"/>

    <!-- set local variable -->

    <xsl:variable name="iscurrent">

      <xsl:choose>

        <xsl:when test="contains($state, Name)">

          <xsl:text>true</xsl:text>

        </xsl:when>

        <xsl:otherwise>

          <xsl:text>false</xsl:text>

        </xsl:otherwise>

      </xsl:choose>

    </xsl:variable>

    <xsl:element name="td" use-attribute-sets="navtab-base">

      <xsl:attribute name="class">

        <xsl:value-of select="concat($type,'navcell')"/>

      </xsl:attribute>

      <xsl:if test="$iscurrent='true'">

        <xsl:attribute name="id">

          <xsl:value-of select="concat($type,'Hilite')"/>

        </xsl:attribute>

      </xsl:if>

      <span class="navlinks">

        <xsl:choose>

          <xsl:when test="$iscurrent='true'">

            <xsl:value-of select="$label"/>

            <xsl:if test="$type='search' and Name != 'history'">

              <xsl:text>&#xa0;</xsl:text>

              <xsl:value-of select="key('get-lookup','navheader.str.search')"/>

              <xsl:text>&#xa0;</xsl:text>

            </xsl:if>

          </xsl:when>

          <xsl:otherwise>

            <xsl:element name="a">

              <xsl:attribute name="class">nav</xsl:attribute>

              <xsl:attribute name="href">

                <xsl:value-of select="$url"/>

              </xsl:attribute>

              <xsl:attribute name="target">_top</xsl:attribute>

                

             

              <xsl:value-of select="$label"/>

            </xsl:element>

          </xsl:otherwise>

        </xsl:choose>

      </span>

    </xsl:element>

  </xsl:template>

</xsl:stylesheet>

