<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:func="http://exslt.org/functions" 
  xmlns:dlxs="http://dlxs.org"
  extension-element-prefixes="func dlxs" 
  exclude-result-prefixes="func dlxs">
 
<!--  This version updated by George Kozak 12/22/09 -->
<!--  This version updated by Frances Webb 1/11/10 -->
<!--  This version updated by Frances Webb 4/26/12 -->

  <xsl:import href="../../lib/xslfunctions.xsl"/>
  
  <xsl:strip-space elements="*"/>

  <xsl:template match="*" mode="BuildOutlineList">
    <xsl:param name="DisplayLayout"/>
    <!-- Matching DIV1s here -->
    <xsl:element name="div">
      <xsl:attribute name="class">indentlevel1</xsl:attribute>
      <xsl:choose>
        <xsl:when test="/Top/DlxsGlobals/CurrentCgi/Param[@name='view']='text' and $DisplayLayout='breadcrumb'">
          <xsl:for-each select="descendant::Divhead">
            <xsl:apply-templates select="."/>
            <xsl:if test="position()!=last()">
              <xsl:text>&#xa0;&gt;&#xa0;</xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="Divhead"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
      	<xsl:when test="ScopingPage">
      		<xsl:for-each select="ScopingPage|Kwic|SummaryString">
                  <xsl:choose>
                    <xsl:when test="name()='ScopingPage'">
                      <xsl:apply-templates select="." mode="ScopingPage"/>
                    </xsl:when>
                    <xsl:when test="name()='Kwic'">
                      <xsl:apply-templates select="."/>
                    </xsl:when>
                    <xsl:when test="name()='SummaryString'">
                      <xsl:apply-templates select="."/>
                    </xsl:when>
                  </xsl:choose>
            </xsl:for-each>
      	</xsl:when>
      	<xsl:otherwise>
      	     <xsl:apply-templates select="*[starts-with(name(),'DIV')]" mode="ItemDetails"/>
      	     <xsl:apply-templates select="Kwic"/>
      	</xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <!-- outline is the default mode for executing this template, when called
             from results.xsl.  However, if called from text.xsl the DisplayType
             variable could be set to breadcrumb.
             -->
        <xsl:when test="$dlxsTemp='header'">
           <!-- apply templates to DIVns other than current. (Saxon complains about using 'descendant' axis, so: -->
          <xsl:apply-templates select="*[starts-with(name(),'DIV')][not(name()=name(.))]" mode="ItemDetails"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$DisplayLayout='outline'">
              <xsl:apply-templates select="*[starts-with(name(),'DIV')][not(name()=name(.))]" mode="ItemDetails"/>
            </xsl:when>           
            <xsl:when test="$DisplayLayout='breadcrumb'">
              <xsl:apply-templates select="*[starts-with(name(),'DIV')][not(name()=name(.))]" mode="TxtItemDetailsBC"/>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>


  <xsl:template match="DIV2|DIV3|DIV4|DIV5|DIV6|DIV7|DIV8|DIV9|DIV10">
    <xsl:if test="@ID">
      <xsl:element name="a">
        <xsl:attribute name="name"><xsl:value-of select="@ID"/></xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:element name="div">
      <xsl:attribute name="class">textindentlevelx</xsl:attribute>
      <xsl:if test="@ID">
        <xsl:attribute name="id">
          <xsl:value-of select="@ID"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="DIVINFO">
          <xsl:for-each select="HEAD">
            <xsl:apply-templates select="."/>
            <xsl:if test="position()!=last()">
              <xsl:text>&#xa0;</xsl:text>
            </xsl:if>
          </xsl:for-each>

          <xsl:apply-templates select="*[name()!='DIVINFO'][name()!='HEAD']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>


  <xsl:template match="DIV2|DIV3|DIV4|DIV5|DIV6|DIV7|DIV8|DIV9|DIV10" mode="TxtItemDetailsBC">
    <xsl:element name="span">
      <xsl:attribute name="class">inlinediv</xsl:attribute>
      <xsl:choose>
        <xsl:when test="Divhead">
          <xsl:apply-templates select="Kwic"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
      <xsl:apply-templates select="*[starts-with(name(),'DIV')]" mode="TxtItemDetailsBC"/>
    </xsl:element>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

    
  <xsl:template match="Divhead">
    <xsl:variable name="BuildLinks">
      <xsl:choose>
        <xsl:when test="/Top/AuthRequired='true'">false</xsl:when>
        <xsl:otherwise>true</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- BuildLinks is item-level, NonLinkedDiv is specific to this div -->
    <xsl:variable name="NonLinkedDiv">
      <xsl:choose>
        <!-- disable div linking for serialarticle: served whole -->
        <xsl:when test="ancestor::Item/DocEncodingType='serialarticle'">
          <xsl:value-of select="'true'"/>
        </xsl:when>
        <xsl:when test="parent::*[@STATUS='nolink'] or parent::*[@STATUS='hidden']">
          <xsl:value-of select="'true'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'false'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="span">
      <xsl:attribute name="class">divhead</xsl:attribute>
      <xsl:choose>
        <xsl:when test="ancestor::Item/DocEncodingType='serialissue'">
          <xsl:call-template name="SerIssueItemBrief">
            <xsl:with-param name="itemBiblNode" select="BIBL"/>
            <xsl:with-param name="itemLink" select="following-sibling::Link"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="BIBLcontent">
            <xsl:choose>
              <xsl:when test="BIBL and not(/Top/Item/DocEncodingType='serialissue')">
                <xsl:for-each select="BIBL/*">
                  <xsl:apply-templates select="."/>
                  <xsl:if test="position()!=last()">
                    <xsl:text>,&#xa0;</xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise/>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$BuildLinks='false' or $NonLinkedDiv='true'">
              <!-- labels, not links  -->
              <xsl:call-template name="BuildDivHeadLinkLabel"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="a">
                <xsl:attribute name="href">
                  <xsl:value-of select="following-sibling::Link"/>
                </xsl:attribute>
                <!-- handle labels for DIVs without HEADs -->
                <xsl:call-template name="BuildDivHeadLinkLabel"/>
              </xsl:element>
              <xsl:element name="div">
                <xsl:attribute name="class">indentlevel1</xsl:attribute>
	        <xsl:attribute name="style">margin-top: -2px</xsl:attribute>
                <xsl:for-each select="HEAD/AUTHOR">
                  <xsl:element name="i">
                    <xsl:value-of select="."/>
                  </xsl:element>
		  <xsl:if test="position()!=last()">
                    <xsl:element name="br"/>
	          </xsl:if>
                </xsl:for-each>
              </xsl:element>
              <!-- append meta info such as page numbers in toc view only-->
              <!-- not desired in results details or textview, or it'll
                   muck up the breadcrumbs -->
              <xsl:if test="/Top/DlxsGlobals/CurrentCgi/Param[@name='view']='toc'">
                <xsl:if test="not($BIBLcontent='')">
                  <span class="divmeta">
                    <xsl:text>,&#xa0;</xsl:text>
                    <xsl:value-of select="$BIBLcontent"/>
                  </span>
                </xsl:if>
                <xsl:if test="HEAD/BIBL[@TYPE!='pg' or @TYPE='pp' or @TYPE='page' or @TYPE='para']">
                  <xsl:text>&#xa0;</xsl:text>
                  <span class="divmeta">
                    <xsl:apply-templates select="HEAD/BIBL[@TYPE='pg' or @TYPE='pp' or @TYPE='page' or @TYPE='para']"/>
                  </span>
                </xsl:if>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="descendant::NOTE1 and $dlxsTemp='text'">
            <xsl:apply-templates select="descendant::NOTE1"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
      
      

    <xsl:template name="BuildDivHeadLinkLabel">
        <xsl:choose>
            <xsl:when test="not(child::HEAD) and ../@TYPE!='PDIV'">
                <xsl:value-of select="../@TYPE"/>
            </xsl:when>
            <xsl:when test="not(child::HEAD) and ../@TYPE='PDIV'">
                <xsl:text>Section</xsl:text>
            </xsl:when>
            <xsl:when test="not(child::HEAD) and not(../@TYPE)">
                <xsl:text>Section</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!-- we don't want to lose our HEADs : -->
                <xsl:for-each select="HEAD">
                    <xsl:apply-templates mode="procdivhead" select="."/>
                    <!-- level4 failing -->
                    <xsl:if test="position()!=last()">
                        <xsl:text>&#xa0;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

  <xsl:template match="DIV2|DIV3|DIV4|DIV5|DIV6|DIV7|DIV8|DIV9|DIV10" mode="ItemDetails">
    <xsl:element name="div">
      <xsl:attribute name="class">resindentlevelx</xsl:attribute>
      <xsl:attribute name="style">padding-top: 3px</xsl:attribute>
      <xsl:if test="@ID">
        <xsl:attribute name="id">
          <xsl:value-of select="@ID"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:apply-templates select="Divhead"/>
      
      <xsl:choose>
      <xsl:when test="ScopingPage">
        <xsl:for-each select="ScopingPage|Kwic|SummaryString">
          <xsl:choose>
            <xsl:when test="name()='ScopingPage'">
              <xsl:apply-templates select="." mode="ScopingPage"/>
            </xsl:when>
            <xsl:when test="name()='Kwic'">
              <xsl:apply-templates select="."/>
            </xsl:when>
            <xsl:when test="name()='SummaryString'">
              <xsl:apply-templates select="."/>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>

      <xsl:otherwise>
      <xsl:apply-templates select="Kwic|SummaryString"/>
      </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*[starts-with(name(),'DIV')][string-length(name())&lt;=5]" mode="ItemDetails"/>

      <xsl:choose>
        <xsl:when test="DIVINFO">
          <xsl:apply-templates select="HEAD[1]"/>
          <xsl:apply-templates select="*[name()!='DIVINFO'][name()!='HEAD']"/>
        </xsl:when>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="HEAD" mode="procdivhead">
    <xsl:if test="BIBL">
      <xsl:for-each select="BIBL[@TYPE!='pg' and @TYPE!='pp' and @TYPE!='page' and @TYPE!='para']">
        <xsl:choose>
          <xsl:when test="@TYPE='title'">
            <xsl:element name="span">
              <xsl:attribute name="class">bibldivhead</xsl:attribute>
              <xsl:apply-templates select="LB|DATE|HI1|HI2|Highlight|text()"/>
            </xsl:element>
          </xsl:when>
          <xsl:when test="@TYPE='author'">
            <xsl:element name="span">
              <xsl:attribute name="class">biblauthor</xsl:attribute>
              <xsl:apply-templates select="LB|DATE|HI1|HI2|Highlight|text()"/>
            </xsl:element>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="position()!=last()">
          <xsl:text>:&#xa0;</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="TITLE">
	<xsl:value-of select="TITLE"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="LB|DATE|HI1|HI2|SEG|Highlight|text()[not(starts-with(normalize-space(.),' '))]"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>


  <xsl:template match="BIBL[ancestor::Divhead]">
    <xsl:choose>
      <xsl:when test="@TYPE='para'">
        <xsl:text>[para.&#xa0;</xsl:text>
        <xsl:value-of select="concat(.,']&#xa0;')"/>
      </xsl:when>
      <xsl:when test="@TYPE='title'">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:when test="@TYPE='chapter'">
        <xsl:value-of select="concat(., ':&#xa0;')"/>
      </xsl:when>
      <xsl:otherwise> [<xsl:value-of select="."/>] </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Template for handling ScopingPages -->
  <xsl:template match="ScopingPage" mode="ScopingPage">
    <xsl:variable name="BuildLinks">
      <xsl:choose>
        <xsl:when test="/Top/AuthRequired='true'">false</xsl:when>
        <xsl:otherwise>true</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:element name="div">
      <xsl:attribute name="class">indentlevel1</xsl:attribute>
      <xsl:element name="span">
        <xsl:attribute name="class">scopingpage</xsl:attribute>
        <xsl:text>&#x0a;</xsl:text>
        <xsl:choose>
          <xsl:when test="$BuildLinks='true'">
            <xsl:call-template name="BuildLink">
              <xsl:with-param name="href" select="ViewPageLink"/>
              <xsl:with-param name="content">
                <xsl:value-of select="concat('Page ',PageNumber)"/>

           <!-- xsl:value-of select="key('get-lookup','headerutils.str.page')"/ -->
<!--                <xsl:text>&#xa0;</xsl:text>
                <xsl:value-of select="PageNumber"/>      -->
                <xsl:if test="PageType!='viewer.ftr.uns'"><xsl:text>&#xa0;-&#xa0;</xsl:text></xsl:if>
                <xsl:value-of select="key('get-lookup',PageType)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="key('get-lookup','headerutils.str.page')"/>
            <xsl:text>&#xa0;</xsl:text>
            <xsl:value-of select="PageNumber"/>
            <xsl:if test="PageType!='viewer.ftr.uns'"><xsl:text>&#xa0;-&#xa0;</xsl:text></xsl:if>
            <xsl:value-of select="key('get-lookup',PageType)"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#x0a;</xsl:text>
        <xsl:element name="span">
          <xsl:attribute name="class">indentlevel0</xsl:attribute>
          <xsl:comment> page hit summary string goes here </xsl:comment>
        </xsl:element>
        <xsl:text>&#x0a;</xsl:text>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- template for building results or toc section and page links -->
  <xsl:template name="BuildLink">
    <xsl:param name="content"/>
    <xsl:param name="href"/>
    <a href="{$href}">
      <xsl:value-of select="$content"/>
    </a>
  </xsl:template>

  <!-- SerIssueItemBrief: for TOC div/article display.  Could be
  enhanced to handle divs that are not article content such as title
  page etc. -->
  <xsl:template name="SerIssueItemBrief">
    <xsl:param name="itemBiblNode"/>
    <xsl:param name="itemLink"/>
    <xsl:variable name="authRequired">
      <xsl:value-of select="/Top/AuthRequired"/>
    </xsl:variable>

        <xsl:if test="$itemBiblNode/TITLE">
          <xsl:choose>
            <xsl:when test="$itemLink!=''">
            <!-- <xsl:when test="$itemLink!='null'"> -->
              <a href="{$itemLink}" class="articletitle">
                <xsl:apply-templates select="$itemBiblNode/TITLE[not(@TYPE='sort')]" mode="hdrtitle"/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <span class="articletitle">
                <xsl:apply-templates select="$itemBiblNode/TITLE[not(@TYPE='sort')]" mode="hdrtitle"/>
              </span>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$itemBiblNode/AUTHOR">
            <div class="articleauthor">
              <xsl:apply-templates select="$itemBiblNode/AUTHOR" mode="hdrauthor"/>
              <xsl:if test="$itemBiblNode/BIBLSCOPE[(@TYPE='pg' or @TYPE='pageno')]">
                <xsl:text>,&#xa0;</xsl:text>
                <xsl:apply-templates select="$itemBiblNode/BIBLSCOPE[(@TYPE='pg' or @TYPE='pageno')]"/>
              </xsl:if>
            </div>
          </xsl:when>
          <xsl:when test="$itemBiblNode/AUTHORIND">
            <div class="articleauthor">
              <xsl:for-each select="$itemBiblNode/AUTHORIND">
                <xsl:apply-templates select="."/>
                <xsl:if test="position()!=last()">
                  <xsl:text>;&#xa0;</xsl:text>
                </xsl:if>
              </xsl:for-each>
              <xsl:if test="$itemBiblNode/BIBLSCOPE[(@TYPE='pg' or @TYPE='pageno')]">
                <xsl:text>;&#xa0;</xsl:text>
                <xsl:apply-templates select="$itemBiblNode/BIBLSCOPE[(@TYPE='pg' or @TYPE='pageno')]"/>
              </xsl:if>
            </div>
          </xsl:when><xsl:otherwise>
            <div class="articleauthor">
              <xsl:if test="$itemBiblNode/BIBLSCOPE[(@TYPE='pg' or @TYPE='pageno')]">
                <xsl:apply-templates select="$itemBiblNode/BIBLSCOPE[(@TYPE='pg' or @TYPE='pageno')]"/>
              </xsl:if>
            </div>
          </xsl:otherwise>

        </xsl:choose>
  </xsl:template>
  <xsl:template match="DATE">
    <xsl:text>&#xa0;</xsl:text><xsl:apply-templates/>
  </xsl:template>
 
</xsl:stylesheet>
