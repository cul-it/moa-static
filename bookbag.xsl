<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" 
  xmlns:dlxs="http://dlxs.org"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- global variables --> 
  <xsl:variable name="cgiPage" select="/Top/DlxsGlobals/CurrentCgi/Param[@name='page']"/>
  <xsl:variable name="searchtype" select="/Top/SearchType"/>
  <xsl:variable name="BookBagHoldingsLink"
    select="/Top/NavHeader/MainNav/NavItem[Name='bookbag']/Link"/>
  <!-- end global variables -->
  
  
    <xsl:template match="/Top">
        <xsl:comment>Using bookbag.xsl</xsl:comment>
        <html>
            <head>
                <xsl:apply-templates select="DlxsGlobals" mode="BuildHeadDefaults"/>
            </head>
            <body class="defaultbody" bgcolor="#ffffff">
                <!-- this is a temporary measure until new bookbag add function is available 
                 essentially, if this page is being loaded because of bbaction add request
                 we insert a blank block to prevent us from seeing the header display  -->
                <xsl:apply-templates select="NavHeader"/>
                <div class="maincontent">
                    <xsl:apply-templates select="ReturnToResultsLink"/>
                    <span class="blksubheader">
                        <xsl:choose>
                            <xsl:when test="contains( $cgiPage, 'bbag' )">
                                <br/>
                                <div class="indentBlock">
                                    <xsl:value-of select="key('get-lookup','bookbag.str.holdings')"/>
                                    <br/>
                                </div>
                            </xsl:when>
                            <xsl:when test="$cgiPage='bbagemail'">
                                <xsl:value-of select="key('get-lookup','bookbag.str.emailbookbagcontents')"/>
                            </xsl:when>
                        </xsl:choose>
                    </span>
                </div>

                <xsl:if test="/Top/Bookbag/BookbagItems!=0">

                    <xsl:if test="$cgiPage!='bbagemail'">
                        <div style="margin-top:20px">
                            <xsl:call-template name="BookbagActionForms"/>
                        </div>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="contains( $cgiPage, 'bbag' )">
                    <div class="maincontent">
                        <div id="BBItemsList">
                            <xsl:apply-templates select="/Top/Bookbag/BookbagResults"/>
                        </div>
                    </div>
                </xsl:if>


                <xsl:if test="/Top/Bookbag/BookbagItems!=0">
                     <!-- Build a search form to search within the bookbag items
                   unless this is just the page for the user to enter an
                   address to which to the records -->
                    <xsl:if test="contains( $cgiPage, 'bbag' ) and $cgiPage != 'bbagemail'">
                        <div class="maincontent">
                            <div class="BBsearchblock">
                                <!-- wrapper table to keep child tables a common width -->
                                <table border="0" cellspacing="0" cellpadding="0" width="100%">
                                    <tr>
                                        <td>
                                            <table border="0" cellspacing="0" cellpadding="0" width="100%">
                                                <xsl:text>&#x0a;</xsl:text>
                                                <!-- Build the navbar of Search type tabs -->
                                                <tr>
                                                    <td align="left" valign="top" bgcolor="ffffff">
                                                        <div class="searchnavblock">
                                                            <xsl:call-template name="BuildNavBar">
                                                                <xsl:with-param name="NavItems" select="SearchNav/*"/>
                                                                <xsl:with-param name="NavBarType" select="'bbag'"/>
                                                                <xsl:with-param name="searchtype" select="'search'"/>
                                                            </xsl:call-template>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                            <div class="BBsearchform">
                                                <table border="0" cellspacing="0" cellpadding="0" width="100%">
                                                    <!-- Begin HTML form element, to wrap all search related elements -->
                                                    <xsl:element name="form">
                                                        <xsl:attribute name="method">GET</xsl:attribute>
                                                        <xsl:attribute name="name">search</xsl:attribute>
                                                        <xsl:attribute name="action">
                                                            <xsl:value-of select="DlxsGlobals/ScriptName[@application='text']"/>
                                                        </xsl:attribute>
                                                        <!-- Begin search form proper -->
                                                        <xsl:comment>begin table for search form proper</xsl:comment>
                                                        <xsl:apply-templates select="SearchForm" mode="SearchForm"/>
                                                    </xsl:element>
                                                </table>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </xsl:if>
                    <xsl:if test="$cgiPage='bbagemail'">
                        <xsl:call-template name="BookbagEmailForm"/>
                    </xsl:if>
                </xsl:if>
                <xsl:call-template name="BuildFooter"/>
            </body>
        </html>
    </xsl:template>

  <!-- _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ -->
  <!-- TEMPLATE: return to result link               -->
  <!-- _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ -->
  <xsl:template name="BookbagEmailForm">
    <div class="maincontent">
        <div style="margin-left:20px">
          <table cellpadding="5" border="0">
            <xsl:element name="form">
              <xsl:attribute name="method">GET</xsl:attribute>
              <xsl:attribute name="action">
                <xsl:value-of select="/Top/DlxsGlobals/ScriptName[@application='text']"/>
              </xsl:attribute>
              <tr>
                <td align="right" class="nobreak">
                  <xsl:value-of select="key('get-lookup','bookbag.str.sendto')"/>
                </td>
                <td>
                  <input type="text" name="email" size="25"/>
                  <input type="hidden" name="bbaction" value="email"/>
                </td>
              </tr>
              <tr>
                <td valign="top">
                  <xsl:text>&#xa0;</xsl:text>
                </td>
                <td>
                  <xsl:apply-templates select="/Top/Bookbag/BookbagActionForm/HiddenVars"/>
                  <input type="submit" value="email bookbag records"/>
                </td>
              </tr>
            </xsl:element>
          </table>
        </div>
    </div>
  </xsl:template>
  <!-- _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ -->
  <!-- TEMPLATE: Buttons for download, email, empty in form  -->
  <!-- _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ -->
  <xsl:template name="BookbagActionForms">
    <div class="maincontent">
        <div id="BBOptionsBlock">
          <table border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td>
                <table cellpadding="0" cellspacing="0" border="0">
                  <tr>
                    <td nowrap="nowrap">
                      <font size="-1" face="arial,sanserif">
                        <xsl:choose>
                          <xsl:when test="$cgiPage='bbagemail'">
                            <xsl:call-template name="BuildBookbagActionForm">
                              <xsl:with-param name="bookbagaction" select="'list'"/>
                            </xsl:call-template>
                          </xsl:when>
                          <!-- if not specifically the email page -->
                          <xsl:otherwise>
                            <xsl:call-template name="BuildBookbagActionForm">
                              <xsl:with-param name="bookbagaction" select="'email'"/>
                            </xsl:call-template>
                          </xsl:otherwise>
                        </xsl:choose>
                      </font>
                    </td>
                    <td nowrap="nowrap">
                      <font size="-1" face="arial,sanserif">
                        <xsl:call-template name="BuildBookbagActionForm">
                          <xsl:with-param name="bookbagaction" select="'download'"/>
                        </xsl:call-template>
                      </font>
                    </td>
                    <td nowrap="nowrap">
                      <font size="-1" face="arial,sanserif">
                        <xsl:call-template name="BuildBookbagActionForm">
                          <xsl:with-param name="bookbagaction" select="'empty'"/>
                        </xsl:call-template>
                      </font>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </div>
    </div>
  </xsl:template>
  <!-- _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ -->
  <!-- TEMPLATE: for building a bookbag action form  -->
  <!-- _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ -->
  <xsl:template name="BuildBookbagActionForm">
    <xsl:param name="bookbagaction"/>
    <!-- string to display on button -->
    <xsl:variable name="buttonText">
      <xsl:choose>
        <xsl:when test="$bookbagaction = 'email'">
          <xsl:value-of select="key('get-lookup','bookbag.str.emailcontents')"/>
        </xsl:when>
        <xsl:when test="$bookbagaction = 'list'">
          <xsl:value-of select="key('get-lookup','bookbag.str.bookbagholdings')"/>
        </xsl:when>
        <xsl:when test="$bookbagaction = 'download'">
          <xsl:value-of select="key('get-lookup','bookbag.str.downloadcontents')"/>
        </xsl:when>
        <xsl:when test="$bookbagaction = 'empty'">
          <xsl:value-of select="key('get-lookup','bookbag.str.emptycontents')"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <!-- building of actual form with hidden vars -->
    <xsl:element name="form">
      <xsl:attribute name="method">GET</xsl:attribute>
      <xsl:attribute name="bbaction">
        <xsl:value-of select="/Top/DlxsGlobals/ScriptName[@application='text']"/>
      </xsl:attribute>
      <!--  <xsl:if test="$bookbagaction = 'download'">
           <xsl:attribute name="target">mainwindow</xsl:attribute>
         </xsl:if> -->
      <xsl:apply-templates select="/Top/Bookbag/BookbagActionForm/HiddenVars"/>
      <xsl:choose>
        <xsl:when test="$bookbagaction = 'email'">
          <xsl:element name="input">
            <xsl:attribute name="type">hidden</xsl:attribute>
            <xsl:attribute name="name">page</xsl:attribute>
            <xsl:attribute name="value">bbagemail</xsl:attribute>
          </xsl:element>
        </xsl:when>
        <xsl:when test="$bookbagaction = 'list'">
          <xsl:element name="input">
            <xsl:attribute name="type">hidden</xsl:attribute>
            <xsl:attribute name="name">page</xsl:attribute>
            <xsl:attribute name="value">bbaglist</xsl:attribute>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="input">
            <xsl:attribute name="type">hidden</xsl:attribute>
            <xsl:attribute name="name">bbaction</xsl:attribute>
            <xsl:attribute name="value">
              <xsl:value-of select="$bookbagaction"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:element name="input">
        <xsl:attribute name="class">selectmenu</xsl:attribute>
        <xsl:attribute name="type">submit</xsl:attribute>
        <xsl:attribute name="name">Submit</xsl:attribute>
        <xsl:attribute name="value">
          <xsl:value-of select="normalize-space( $buttonText )"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <!-- _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ -->
  <!-- TEMPLATE: filtering the bookbag items themselves  -->
  <!-- _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ -->
  <xsl:template match="BookbagResults">
    <xsl:if test="/Top/NavHeader/BookbagItems = '0'">
      <p>
        <xsl:value-of select="key('get-lookup','bookbag.str.no.items')"/>
      </p>
    </xsl:if>
    <ul>
      <xsl:for-each select="Item">
        <li class="browselistitem">
          <xsl:call-template name="ItemHeaderFilter">
            <xsl:with-param name="itemRoot" select="."/>
          </xsl:call-template>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>
</xsl:stylesheet>
