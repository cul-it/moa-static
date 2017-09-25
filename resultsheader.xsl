<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings" xmlns:exsl="http://exslt.org/common"
  xmlns:func="http://exslt.org/functions" xmlns:dlxs="http://dlxs.org"
  extension-element-prefixes="str exsl dlxs func" exclude-result-prefixes="str exsl dlxs func">

  <!-- ********************************************************************** -->
  <!-- FILTER ITEM HEADERS -->
  <!-- ********************************************************************** -->
  <xsl:template name="ItemHeaderFilter">
    <xsl:param name="encodingType"/>
    <xsl:param name="iel"/>
    <xsl:param name="isSubjSearch"/>

    <!-- context is 'Item' -->
    <xsl:choose>

      <!-- ********************************************************************** -->
      <!-- if need to filter MONOGRAPH -->
      <!-- ********************************************************************** -->
      <xsl:when test="$encodingType='monograph'">
        <xsl:call-template name="ProcessMonograph">
          <xsl:with-param name="iel" select="$iel"/>
          <xsl:with-param name="isSubjSearch" select="$isSubjSearch"/>
        </xsl:call-template>
      </xsl:when>

      <!-- ********************************************************************** -->
      <!-- if need to filter SERIALARTICLE -->
      <!-- ********************************************************************** -->
      <xsl:when test="$encodingType='serialarticle'">
        <xsl:call-template name="ProcessSerialarticle">
          <xsl:with-param name="iel" select="$iel"/>
          <xsl:with-param name="isSubjSearch" select="$isSubjSearch"/>
        </xsl:call-template>
      </xsl:when>

      <!-- ********************************************************************** -->
      <!-- if need to filter SERIALISSUE -->
      <!-- ********************************************************************** -->
      <xsl:when test="$encodingType='serialissue'">
        <xsl:choose>

          <!-- ********************************************************************** -->
          <!-- branch to filter SERIALISSUE, after regular search, layer 1 results -->
          <!-- ********************************************************************** -->
          <xsl:when test="not ( /Top/DlxsGlobals/CurrentCgi/Param[@name='node'] )
            and
            /Top/DlxsGlobals/CurrentCgi/Param[@name='view'] = 'reslist'
            and
            not( /Top/DlxsGlobals/CurrentCgi/Param[@name='idno'] )" >
            <xsl:call-template name="ProcessSerialissueForLayer1">
              <xsl:with-param name="iel" select="$iel"/>
              <xsl:with-param name="isSubjSearch" select="$isSubjSearch"/>
            </xsl:call-template>
          </xsl:when>

          <!-- ********************************************************************** -->
          <!-- branch to filter SERIALISSUE, only one article, layer2 results -->
          <!-- ********************************************************************** -->
          <xsl:when test="/Top/DlxsGlobals/CurrentCgi/Param[@name='node']
            and
            /Top/DlxsGlobals/CurrentCgi/Param[@name='view'] = 'reslist'
            and
            /Top/DlxsGlobals/CurrentCgi/Param[@name='didno'] " >
            <xsl:call-template name="ProcessSerialissueForSingleArticle">
              <xsl:with-param name="iel" select="$iel"/>
              <xsl:with-param name="isSubjSearch" select="$isSubjSearch"/>
            </xsl:call-template>
          </xsl:when>

          <!-- ********************************************************************** -->
          <!-- branch to filter SERIALISSUE, TOC view, multiple article -->
          <!-- ********************************************************************** -->
          <xsl:when test="/Top/DlxsGlobals/CurrentCgi/Param[@name='node']
            and
            /Top/DlxsGlobals/CurrentCgi/Param[@name='view'] = 'toc' " >
            <xsl:call-template name="ProcessSerialissueForTocView">
              <xsl:with-param name="iel" select="$iel"/>
              <xsl:with-param name="itemDetails" select="./ItemDetails"/>
              <xsl:with-param name="isSubjSearch" select="$isSubjSearch"/>
            </xsl:call-template>
          </xsl:when>

          <!-- ********************************************************************** -->
          <!-- branch to filter SERIALISSUE, result of search within this issue, multiple article -->
          <!-- ********************************************************************** -->
          <xsl:otherwise>
            <xsl:call-template name="ProcessSerialissueForMultipleArticles">
              <xsl:with-param name="iel" select="$iel"/>
              <xsl:with-param name="itemDetails" select="./ItemDetails"/>
              <xsl:with-param name="isSubjSearch" select="$isSubjSearch"/>
            </xsl:call-template>
          </xsl:otherwise>

        </xsl:choose>
      </xsl:when>

    </xsl:choose>

  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- PROCESS MONOGRAPH -->
  <!-- ********************************************************************** -->
  <xsl:template name="ProcessMonograph">
    <xsl:param name="iel"/>
    <xsl:param name="isSubjSearch"/>

    <xsl:variable name="sourcedesc" select="HEADER/FILEDESC/SOURCEDESC"/>
    <xsl:variable name="mainTitle">
      <xsl:call-template name="procTitle"/>
    </xsl:variable>

    <xsl:variable name="mainAuthors">
      <xsl:choose>
        <xsl:when test="HEADER/FILEDESC/TITLESTMT/AUTHOR">
          <xsl:for-each select="HEADER/FILEDESC/TITLESTMT/AUTHOR">
            <!-- may contain DESCRIPs -->
            <xsl:apply-templates select="."/>
            <xsl:if test="following-sibling::AUTHOR">, </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="HEADER/FILEDESC/TITLESTMT/EDITOR">
          <xsl:for-each select="HEADER/FILEDESC/TITLESTMT/EDITOR">
            <xsl:value-of select="."/>
            <xsl:if test="following-sibling::EDITOR">, </xsl:if>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="authorCount">
      <xsl:value-of select="count(HEADER/FILEDESC/TITLESTMT/AUTHOR)"/>
    </xsl:variable>

    <xsl:variable name="editionStmt">
      <xsl:value-of select="HEADER/FILEDESC//EDITIONSTMT"/>
    </xsl:variable>

    <xsl:variable name="pubinfo">
      <xsl:apply-templates select="$sourcedesc/BIBL/PUBPLACE"/>
      <xsl:text>&#xa0;</xsl:text>
      <xsl:apply-templates select="$sourcedesc/BIBL/PUBLISHER"/>
      <xsl:text>&#xa0;</xsl:text>
      <xsl:apply-templates select="$sourcedesc/BIBL/DATE"/>
    </xsl:variable>

    <xsl:variable name="subjectinfo">
      <xsl:if test="$isSubjSearch='yes' and .//KEYWORDS/child::TERM">
        <xsl:call-template name="resitemSubjects">
          <xsl:with-param name="subjParent" select="."/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:call-template name="OutputHeader">
      <xsl:with-param name="mainTitle" select="$mainTitle"/>
      <xsl:with-param name="mainAuthors" select="$mainAuthors"/>
      <xsl:with-param name="authorCount" select="$authorCount"/>
      <xsl:with-param name="iel" select="$iel"/>
      <xsl:with-param name="editionStmt" select="$editionStmt"/>
      <xsl:with-param name="pubinfo" select="$pubinfo"/>
      <xsl:with-param name="subjectinfo" select="$subjectinfo"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- PROCESS SERIALISSUE FOR SINGLE ARTICLE (Layer2) -->
  <!-- ********************************************************************** -->
  <xsl:template name="ProcessSerialissueForSingleArticle">
    <xsl:param name="iel"/>

    <xsl:variable name="articleCite" select="ItemDetails/DIV1/Divhead/BIBL"/>
    <xsl:variable name="serIssSrc" select="MainHeader/HEADER/FILEDESC/SOURCEDESC"/>

    <!-- artcile title -->
    <xsl:variable name="mainTitle">
        <xsl:element name="a">
           <xsl:attribute name="href"><xsl:value-of select="FirstPageHref"/></xsl:attribute>
        <xsl:value-of select="$articleCite/TITLE[1]"/>
        </xsl:element>
    </xsl:variable>

    <xsl:variable name="pubinfo">
      <xsl:call-template name="definePubInfoForSerialIssue">
        <xsl:with-param name="serIssSrc" select="$serIssSrc"/>
        <xsl:with-param name="articleCite" select="$articleCite"/>
      </xsl:call-template>
    </xsl:variable>


    <xsl:variable name="mainAuthors">
      <xsl:call-template name="defineMainAuthors">
        <xsl:with-param name="articleCite" select="$articleCite"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="authorCount">
      <xsl:call-template name="defineAuthorCount">
        <xsl:with-param name="articleCite" select="$articleCite"/>
      </xsl:call-template>
    </xsl:variable>


    <xsl:variable name="subjectinfo">
      <xsl:if test="$isSubjSearch='yes' and $articleCite//child::TERM">
        <xsl:call-template name="resitemSubjects">
          <xsl:with-param name="subjParent" select="."/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <!-- output -->
    <xsl:call-template name="OutputHeader">
      <xsl:with-param name="mainTitle" select="$mainTitle"/>
      <xsl:with-param name="mainAuthors" select="$mainAuthors"/>
      <xsl:with-param name="authorCount" select="$authorCount"/>
      <xsl:with-param name="iel" select="$iel"/>
      <xsl:with-param name="editionStmt" select="''"/>
      <xsl:with-param name="pubinfo" select="$pubinfo"/>
      <xsl:with-param name="subjectinfo" select="$subjectinfo"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- PROCESS SERIALISSUE FOR MULTIPLE ARTICLES  -->
  <!-- ********************************************************************** -->
  <xsl:template name="ProcessSerialissueForMultipleArticles">
    <xsl:param name="iel"/>

    <xsl:variable name="articleCite" select="descendant::DIV1/Divhead/BIBL"/>
    <xsl:variable name="mainHeader" select="MainHeader"/>

    <!-- output issue header information -->
    <xsl:call-template name="OutputIssueHeader">
      <xsl:with-param name="mainHeader" select="$mainHeader"/>
    </xsl:call-template>


    <!-- each article (wrapped in ItemDetails) within this issue will
      be filtered by the next part in Reslist/Results -->
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- PROCESS SERIALISSUE FOR LAYER1 RESULTS  -->
  <!-- ********************************************************************** -->
  <xsl:template name="ProcessSerialissueForLayer1">
    <xsl:param name="iel"/>

    <xsl:variable name="serIssSrc" select="MainHeader/HEADER/FILEDESC/SOURCEDESC"/>
    <xsl:variable name="articleCite" select="DIV1/Divhead/BIBL"/>

    <xsl:variable name="mainAuthors">
      <xsl:call-template name="defineMainAuthors">
        <xsl:with-param name="articleCite" select="$articleCite"/>
      </xsl:call-template>
    </xsl:variable>
    
    <!-- article's enclosing issue's publication information -->
    <xsl:variable name="pubinfo">
      <xsl:call-template name="definePubInfoForSerialIssue">
        <xsl:with-param name="serIssSrc" select="$serIssSrc"/>
        <xsl:with-param name="articleCite" select="$articleCite"/>
      </xsl:call-template>
    </xsl:variable>
    

    <!-- output article title -->
    <div class="itemcitation">
      <span class="resfieldlabel">
        <xsl:value-of select="key('get-lookup','headerutils.str.title')"/>
        <xsl:text>:&#xa0;</xsl:text>
      </span>
      <xsl:element name="a">
      <xsl:attribute name="href">
          <xsl:value-of select="FirstPageHref"/>
      </xsl:attribute>
      	<xsl:value-of select="$articleCite/TITLE"/>
      </xsl:element>
      
    </div>

    <!-- output article authors if any -->
    <xsl:if test="$mainAuthors!=''">
      <div class="itemcitation">
        <span class="resfieldlabel">
          <xsl:value-of select="key('get-lookup','headerutils.str.author')"/>
          <xsl:text>:&#xa0;</xsl:text>
        </span>
        <xsl:value-of select="$mainAuthors"/>
      </div>      
    </xsl:if>
      
    <!-- output encompassing issue's pub info -->
    <div class="itemcitation">
      <span class="resfieldlabel">
        <xsl:value-of select="key('get-lookup','headerutils.str.publicationinfo')"/>
        <xsl:text>:&#xa0;</xsl:text>
      </span>
      <xsl:value-of select="$pubinfo"/>
    </div>

  </xsl:template>


  <!-- ********************************************************************** -->
  <!-- PROCESS SERIALISSUE FOR TOC VIEW  -->
  <!-- ********************************************************************** -->
  <xsl:template name="ProcessSerialissueForTocView">
    <xsl:param name="iel"/>

    <xsl:variable name="articleCite" select="descendant::DIV1/Divhead/BIBL"/>
    <xsl:variable name="serIssSrc" select="MainHeader/HEADER/FILEDESC/SOURCEDESC"/>

    <!-- Issue's information -->
    <xsl:variable name="mainTitle">
      <xsl:choose>
        <xsl:when test="child::FirstPageHref">
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="FirstPageHref"/>
            </xsl:attribute>
            <xsl:value-of select="$articleCite/TITLE[1]"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$articleCite/TITLE[1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:variable name="pubinfo">
      <xsl:value-of select="$serIssSrc/descendant::TITLE[1]"/>
      <xsl:text>&#xa0;/&#xa0;</xsl:text>
      <xsl:if test="$serIssSrc/BIBL/BIBLSCOPE">
        <xsl:apply-templates select="$serIssSrc/BIBL/BIBLSCOPE"/>
        <xsl:text>,&#xa0;</xsl:text>
      </xsl:if>
      <xsl:if test="$serIssSrc/descendant::DATE[1][not(@TYPE='sort')]">
        <xsl:value-of select="$serIssSrc/descendant::DATE[1][not(@TYPE='sort')]"/>
        <xsl:text>,&#xa0;</xsl:text>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="mainAuthors">
      <xsl:call-template name="defineMainAuthors">
        <xsl:with-param name="articleCite" select="$articleCite"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- output issue header information -->
    <xsl:call-template name="OutputHeader">
      <xsl:with-param name="mainTitle" select="$mainTitle"/>
      <xsl:with-param name="mainAuthors" select="$mainAuthors"/>
      <xsl:with-param name="pubinfo" select="$pubinfo"/>
    </xsl:call-template>

    <!-- each article within this issue will
      be filtered by the next part in Reslist/Results -->

  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- PROCESS SERIALARTICLE -->
  <!-- ********************************************************************** -->
  <xsl:template name="ProcessSerialarticle">
    <xsl:param name="iel"/>
    <xsl:variable name="articleCite" select="HEADER/FILEDESC/SOURCEDESC/BIBL"/>
    <xsl:variable name="mainTitle">
      <xsl:if test="child::ViewEntireTextLink">
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:value-of select="ViewEntireTextLink"/>
          </xsl:attribute>
          <xsl:call-template name="procTitle"/>
        </xsl:element>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="mainAuthors">
      <xsl:choose>
        <xsl:when test="$articleCite/AUTHORIND">
          <xsl:for-each select="$articleCite/AUTHORIND">
            <!-- may contain DESCRIPs -->
            <xsl:apply-templates select="."/>
            <xsl:if test="position()!=last()">; </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$articleCite/AUTHOR and not($articleCite/AUTHORIND)">
          <xsl:for-each select="$articleCite/AUTHOR">
            <!-- may contain DESCRIPs -->
            <xsl:apply-templates select="."/>
            <xsl:if test="position()!=last()">, </xsl:if>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="authorCount">
      <xsl:call-template name="defineAuthorCount">
        <xsl:with-param name="articleCite" select="$articleCite"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="pubinfo">
      <xsl:if test="$xcmode!='singlecoll'">
        <xsl:for-each select="$articleCite/PUBLISHER">
          <xsl:value-of select="dlxs:stripEndingChars(.,'.,:;')"/>
          <xsl:if test="position()!=last()">
            <xsl:text>,&#xa0;</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>.&#xa0;</xsl:text>
      </xsl:if>
      <xsl:if test="$articleCite/DATE">
        <xsl:value-of select="$articleCite/DATE"/>
        <xsl:if test="$articleCite/BIBLSCOPE">
          <xsl:text>,&#xa0;</xsl:text>
          <xsl:apply-templates select="$articleCite/BIBLSCOPE"/>
        </xsl:if>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="subjectinfo">
      <xsl:if test="$isSubjSearch='yes' and HEADER//KEYWORDS/child::TERM">
        <xsl:call-template name="resitemSubjects">
          <xsl:with-param name="subjParent" select="."/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="OutputHeader">
      <xsl:with-param name="mainTitle" select="$mainTitle"/>
      <xsl:with-param name="mainAuthors" select="$mainAuthors"/>
      <xsl:with-param name="authorCount" select="$authorCount"/>
      <xsl:with-param name="iel" select="$iel"/>
      <xsl:with-param name="editionStmt" select="''"/>
      <xsl:with-param name="pubinfo" select="$pubinfo"/>
      <xsl:with-param name="subjectinfo" select="$subjectinfo"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- OUTPUT ISSUE HEADER -->
  <!-- ********************************************************************** -->
  <xsl:template name="OutputIssueHeader">
    <xsl:param name="mainHeader"/>

    <xsl:variable name="sourceDesc" select="$mainHeader/HEADER/FILEDESC/SOURCEDESC"/>
    <div class="itemcitation">
      <span class="resfieldlabel">
        <xsl:value-of select="key('get-lookup','headerutils.str.title')"/>
        <xsl:text>:&#xa0;</xsl:text>
      </span>
      <xsl:value-of select="$sourceDesc//TITLE[1]"/>

      <xsl:text>&#xa0;/&#xa0;</xsl:text>
      <xsl:if test="$sourceDesc/BIBL/BIBLSCOPE">
        <xsl:apply-templates select="$sourceDesc/BIBL/BIBLSCOPE"/>
        <xsl:text>,&#xa0;</xsl:text>
      </xsl:if>
      <xsl:if test="$sourceDesc/descendant::DATE[1][not(@TYPE='sort')]">
        <xsl:value-of select="$sourceDesc/descendant::DATE[1][not(@TYPE='sort')]"/>
      </xsl:if>
    </div>

  </xsl:template>


  <!-- ********************************************************************** -->
  <!-- OUTPUT HEADER -->
  <!-- ********************************************************************** -->
  <xsl:template name="OutputHeader">
    <xsl:param name="mainTitle"/>
    <xsl:param name="mainAuthors"/>
    <xsl:param name="authorCount"/>
    <xsl:param name="iel"/>
    <xsl:param name="editionStmt"/>
    <xsl:param name="pubinfo"/>
    <xsl:param name="subjectinfo"/>

    <xsl:element name="div">
      <xsl:attribute name="class">
        <xsl:text>itemcitation</xsl:text>
      </xsl:attribute>
      <div>
        <span class="resfieldlabel">
          <xsl:value-of select="key('get-lookup','headerutils.str.title')"/>
          <xsl:text>:&#xa0;</xsl:text>
        </span>
        <xsl:copy-of select="$mainTitle"/>
      </div>
      <xsl:if test="$mainAuthors!=''">
        <div>
          <span class="resfieldlabel">
            <xsl:value-of select="key('get-lookup','headerutils.str.author')"/>
            <xsl:if test="$authorCount &gt; 1">
              <xsl:value-of select="key('get-lookup','headerutils.str.plural')"/>
            </xsl:if>
            <xsl:text>:&#xa0;</xsl:text>
          </span>
          <xsl:value-of select="$mainAuthors"/>
        </div>
      </xsl:if>
      <div>
        <span class="resfieldlabel">
          <xsl:value-of select="key('get-lookup','headerutils.str.publicationinfo')"/>
          <xsl:text>:&#xa0;</xsl:text>
        </span>
        <xsl:copy-of select="$pubinfo"/>
      </div>
      <xsl:copy-of select="$subjectinfo"/>
    </xsl:element>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- RESITEMSUBJECTS -->
  <!-- ********************************************************************** -->
  <xsl:template name="resitemSubjects">
    <xsl:param name="subjParent"/>
    <xsl:variable name="scount" select="count($subjParent//KEYWORDS/child::TERM)"/>
    <xsl:variable name="label">
      <xsl:value-of select="key('get-lookup','results.str.33')"/>
    </xsl:variable>
    <xsl:variable name="plural">
      <xsl:if test="not($scount = 1)">
        <xsl:value-of select="key('get-lookup','results.str.32')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="subjectsListNode">
      <div class="subjects">
        <span class="resfieldlabel">
          <xsl:value-of select="concat($label,$plural,':')"/>
        </span>
        <xsl:text>&#xa0;</xsl:text>
        <xsl:for-each select="$subjParent//KEYWORDS/TERM">
          <xsl:value-of select="concat('[',dlxs:stripEndingChars(.,'.,:;'),']')"/>
          <xsl:if test="position()!=last()">
            <xsl:value-of select="'&#xa0;'"/>
          </xsl:if>
        </xsl:for-each>
      </div>
    </xsl:variable>
    <xsl:copy-of select="$subjectsListNode"/>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- BIBLFULL -->
  <!-- ********************************************************************** -->
  <xsl:template match="BIBLFULL">
    <xsl:apply-templates select="TITLESTMT|PUBLICATIONSTMT"/>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- IMPRINT or PUBLICATIONSTMT -->
  <!-- ********************************************************************** -->
  <xsl:template match="IMPRINT|PUBLICATIONSTMT">
    <xsl:for-each select="PUBPLACE">
      <xsl:value-of select="."/>
      <xsl:choose>
        <xsl:when test="position()!=last()">
          <xsl:text>,&#xa0;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <!-- supply a colon only if the current string doesn't already end in one. -->
          <xsl:if test="substring(., string-length(.) ) != ':'">
            <xsl:text>:</xsl:text>
          </xsl:if>
          <xsl:text>&#xa0;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:for-each select="PUBLISHER">
      <xsl:value-of select="."/>
      <xsl:choose>
        <xsl:when test="position()!=last()">
          <xsl:text>,&#xa0;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <!-- supply a comma only if the current string doesn't already end in one. -->
          <xsl:if test="substring(., string-length(.) ) != ','">
            <xsl:text>,</xsl:text>
          </xsl:if>
          <xsl:text>&#xa0;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:for-each>
    <xsl:apply-templates select="DATE" mode="hdrdate"/>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- BIBLSCOPE -->
  <!-- ********************************************************************** -->
  <xsl:template match="BIBLSCOPE">
    <xsl:choose>
      <xsl:when test="@TYPE='vol'">
        <xsl:value-of select="key('get-lookup','headerutils.str.volume')"/>
        <xsl:text>&#xa0;</xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='volno'">
        <xsl:value-of select="key('get-lookup','headerutils.str.abbrevvolume')"/>
        <xsl:text>&#xa0;</xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='iss'">
        <xsl:value-of select="key('get-lookup','headerutils.str.18')"/>
        <xsl:text>:&#xa0;</xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='issno'">
        <xsl:value-of select="key('get-lookup','headerutils.str.abbrevnumber')"/>
        <xsl:text>&#xa0;</xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='pg'">
        <xsl:value-of select="concat(key('get-lookup','headerutils.str.abbrevpages'),'&#xa0;')"/>
      </xsl:when>
      <xsl:when test="@TYPE='pageno'">
        <xsl:value-of select="concat(key('get-lookup','headerutils.str.abbrevpages'),'&#xa0;')"/>
      </xsl:when>
      <xsl:when test="@TYPE='col'">
        <xsl:value-of select="concat(key('get-lookup','headerutils.str.25'),'&#xa0;')"/>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="@TYPE='issuetitle'">
        <div class="issuetitle">
          <xsl:value-of select="key('get-lookup','headerutils.str.issue.title')"/>
          <xsl:text>:&#xa0;</xsl:text>
          <xsl:call-template name="stripleadingzeros">
            <xsl:with-param name="str" select="."/>
          </xsl:call-template>
        </div>
      </xsl:when>
      <!-- serial will duplicate sourcedesc title -->
      <xsl:when test="@TYPE='ser'"/>
      <xsl:otherwise>
        <xsl:call-template name="stripleadingzeros">
          <xsl:with-param name="str" select="."/>
        </xsl:call-template>
        <xsl:if test="following-sibling::BIBLSCOPE">, </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- PROCNEWSPAPERTITLE -->
  <!-- ********************************************************************** -->
  <xsl:template name="procNewsPaperTitle">
    <xsl:variable name="titleNode">
      <xsl:value-of select="HEADER/FILEDESC/TITLESTMT/TITLE[not(@TYPE='sort')][1]"/>
    </xsl:variable>
    <xsl:variable name="clip" select="string-length($titleNode)"/>
    <xsl:variable name="TitleStrEnd">
      <!--
        $TitleStrEnd is appended onto title:
        $clip is the title length by default, and so only if a clip shorter than
        the actual title is given do we add the elipses.  Otherwise we add nothing
      -->
      <xsl:if test="$clip&lt;string-length($titleNode)">
        <xsl:text>&#xa0;...</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="concat(substring($titleNode,1,$clip),$TitleStrEnd)"/>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- PROCTITLE -->
  <!-- ********************************************************************** -->
  <xsl:template name="procTitle">
    <xsl:choose>
      <xsl:when test="HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245']
        and
        contains(HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245'], '/')">
        <xsl:value-of select="normalize-space(substring-before(HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245'],'/'))"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- apply templates to handle any HI1 elements -->
        <xsl:apply-templates select="HEADER/FILEDESC/TITLESTMT/TITLE[not(@TYPE='sort')][1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="BIBL[ancestor::HEADER]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- DESCRIP -->
  <!-- ********************************************************************** -->
  <xsl:template match="DESCRIP"/>


  <!-- ********************************************************************** -->
  <!-- define mainAuthors -->
  <!-- ********************************************************************** -->
  <xsl:template name="defineMainAuthors">
    <xsl:param name="articleCite"/>

    <xsl:choose>
      <xsl:when test="$articleCite/AUTHORIND">
        <xsl:for-each select="$articleCite/AUTHORIND">
          <!-- may contain DESCRIPs -->
          <xsl:apply-templates select="."/>
          <xsl:if test="position()!=last()">; </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$articleCite/AUTHOR and not($articleCite/AUTHORIND)">
        <xsl:for-each select="$articleCite/AUTHOR">
          <!-- may contain DESCRIPs -->
          <xsl:apply-templates select="."/>
          <xsl:if test="position()!=last()">, </xsl:if>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- ********************************************************************** -->
  <!-- define authorCount -->
  <!-- ********************************************************************** -->
  <xsl:template name="defineAuthorCount">
   <xsl:param name="articleCite"/>
    
    <xsl:choose>
      <xsl:when test="$articleCite/AUTHORIND">
        <xsl:value-of select="count($articleCite/AUTHOR)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count($articleCite/AUTHOR)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ********************************************************************** -->
  <!-- define authorCount -->
  <!-- ********************************************************************** -->
  <xsl:template name="definePubInfoForSerialIssue">
    <xsl:param name="serIssSrc"/>
    <xsl:param name="articleCite"/>
    
    <xsl:value-of select="$serIssSrc/descendant::TITLE[1]"/>
    <xsl:text>&#xa0;/&#xa0;</xsl:text>
    <xsl:if test="$serIssSrc/BIBL/BIBLSCOPE">
      <xsl:apply-templates select="$serIssSrc/BIBL/BIBLSCOPE"/>
      <xsl:text>,&#xa0;</xsl:text>
    </xsl:if>
    <xsl:if test="$serIssSrc/descendant::DATE[1][not(@TYPE='sort')]">
      <xsl:value-of select="$serIssSrc/descendant::DATE[1][not(@TYPE='sort')]"/>
      <xsl:text>,&#xa0;</xsl:text>
    </xsl:if>
    <xsl:if test="$articleCite/BIBLSCOPE[@TYPE='pg']">
      <xsl:apply-templates select="$articleCite/BIBLSCOPE"/>
    </xsl:if>
  </xsl:template>  
  
</xsl:stylesheet>
