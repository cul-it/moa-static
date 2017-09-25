<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:str="http://exslt.org/strings" 
    xmlns:exsl="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions" 
    xmlns:dlxs="http://dlxs.org"
    extension-element-prefixes="str exsl dlxs func" 
    exclude-result-prefixes="str exsl dlxs func">

    <xsl:template name="ItemHeaderFilter">
        <xsl:param name="encodingType"/>
        <xsl:param name="iel"/>
        <!-- context is 'Item' -->
        <xsl:for-each select="ItemHeader">
            <xsl:call-template name="ProcessHeader">
                <xsl:with-param name="iel" select="$iel"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="ItemHeaderFilterSerialArticle">
        <xsl:param name="iel"/>
        <xsl:for-each select="FullTextResults/DocContent/DLPSTEXTCLASS">
            <xsl:call-template name="ProcessHeader">
                <xsl:with-param name="iel" select="$iel"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    
    <!-- ########### -->   
    <xsl:template name="ProcessHeader">
        <xsl:param name="iel"/>
        <xsl:variable name="sourcedesc" select="HEADER/FILEDESC/SOURCEDESC"/>
        <xsl:variable name="sourcetitlePath" select="($sourcedesc//TITLESTMT|$sourcedesc/BIBLFULL|$sourcedesc/BIBL)"/>
        <xsl:variable name="filedesc" select="HEADER/FILEDESC"/>
        <xsl:variable name="monotitlePath" select="$filedesc/TITLESTMT"/>
        <xsl:variable name="biblSrc" select="($sourcedesc/BIBLFULL|$sourcedesc/BIBL)"/>
        <xsl:variable name="mainPubStPath" select="$filedesc/PUBLICATIONSTMT"/>
        <xsl:variable name="SrcPubStPath" select="($biblSrc/PUBLICATIONSTMT|$biblSrc/IMPRINT|$biblSrc)"/>
        <xsl:variable name="mainTitle">
            <xsl:call-template name="procTitle"/>
        </xsl:variable>
        <xsl:variable name="mainAuthors">
            <xsl:choose>
                <xsl:when test="HEADER/FILEDESC/TITLESTMT/AUTHOR">
                    <xsl:for-each select="HEADER/FILEDESC/TITLESTMT/AUTHOR">
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="HEADER/FILEDESC/TITLESTMT/EDITOR">
                    <xsl:for-each select="HEADER/FILEDESC/TITLESTMT/EDITOR">
                        <xsl:apply-templates select="."/>
                        <xsl:if test="following-sibling::EDITOR">, </xsl:if>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="authorCount">
          <xsl:choose>
            <xsl:when test="HEADER/FILEDESC/TITLESTMT/AUTHOR">
              <xsl:value-of select="count(HEADER/FILEDESC/TITLESTMT/AUTHOR)"/>
            </xsl:when>
            <xsl:when test="HEADER/FILEDESC/TITLESTMT/EDITOR">
              <xsl:value-of select="count(HEADER/FILEDESC/TITLESTMT/EDITOR)"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="availability">
            <xsl:copy-of select="HEADER/FILEDESC/PUBLICATIONSTMT/AVAILABILITY/P"/>
        </xsl:variable>
        
        <xsl:variable name="mainPublStmt">
        	<xsl:if test="$mainPubStPath/PUBPLACE">
        		<xsl:value-of select="$mainPubStPath/PUBPLACE"/>
        		<xsl:text>:&#xa0;</xsl:text>
        	</xsl:if>
        	<xsl:if test="$mainPubStPath/PUBLISHER">
        		<xsl:value-of select="$mainPubStPath/PUBLISHER"/>
        	</xsl:if>
        	<xsl:if test="$mainPubStPath/SERIES">
        	<br />
        		<i><xsl:value-of select="$mainPubStPath/SERIES[1]"/></i>
        	</xsl:if>
        	<xsl:if test="$mainPubStPath/DATE[not(@TYPE='sort')]">
        	<br />
        		<xsl:value-of select="$mainPubStPath/DATE[not(@TYPE='sort')][1]"/>
        	</xsl:if>
        </xsl:variable>
        
        <xsl:variable name="printSrcStmt">
            <xsl:if test="$monotitlePath/EDITOR">
                <xsl:for-each select="$monotitlePath/EDITOR">
                    <xsl:value-of select="concat(.,', ed.')"/>
                    <br/>
                </xsl:for-each>
            </xsl:if>
            <xsl:for-each select="$SrcPubStPath/PUBPLACE">
                <xsl:value-of select="dlxs:stripEndingChars(.,'.,:;')"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>,&#xa0;</xsl:text>
                </xsl:if>
                <xsl:if test="position()=last()">
                    <xsl:text>:&#xa0;</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="$SrcPubStPath/PUBLISHER">
                <xsl:value-of select="dlxs:stripEndingChars(.,'.,:;')"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>,&#xa0;</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="$sourcetitlePath/BIBLSCOPE[not(@TYPE='issuetitle')]">
                 <br />
            	<xsl:apply-templates select="$sourcetitlePath/BIBLSCOPE[not(@TYPE='issuetitle')]"/>
            </xsl:if>
            
            <xsl:if test="$SrcPubStPath/DATE">
            	<xsl:text>,&#xa0;</xsl:text>
                <xsl:apply-templates select="$SrcPubStPath/DATE[1]"/>
            </xsl:if>
            <xsl:if test="$sourcetitlePath/BIBLSCOPE[@TYPE='issuetitle']">
                 <br />
            	<xsl:apply-templates select="$sourcetitlePath/BIBLSCOPE[@TYPE='issuetitle']"/>
            </xsl:if>


            <xsl:if test="$SrcPubStPath/IDNO[@TYPE='ISBN']">
                <xsl:call-template name="docISBN">
                    <xsl:with-param name="srcbiblpath" select="$biblSrc"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$sourcetitlePath/following-sibling::BIBL">
            	<xsl:apply-templates select="$sourcetitlePath/following-sibling::BIBL"/>
            </xsl:if>            
        </xsl:variable>
        <xsl:variable name="subjectinfo">
            <xsl:if test="child::HEADER/PROFILEDESC/TEXTCLASS/KEYWORDS/TERM">
                <xsl:for-each select="HEADER/PROFILEDESC/TEXTCLASS/KEYWORDS/TERM">
                    <div class="kwterm">
                        <xsl:value-of select="."/>
                    </div>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        <xsl:call-template name="OutputHeader">
            <xsl:with-param name="mainTitle" select="$mainTitle"/>
            <xsl:with-param name="mainAuthors" select="$mainAuthors"/>
            <xsl:with-param name="mainPublStmt" select="$mainPublStmt"/>
            <xsl:with-param name="authorCount" select="$authorCount"/>
            <xsl:with-param name="availability" select="$availability"/>
            <xsl:with-param name="printSrcStmt" select="$printSrcStmt"/>
            <xsl:with-param name="iel" select="$iel"/>
            <xsl:with-param name="subjectinfo" select="$subjectinfo"/>
        </xsl:call-template>
    </xsl:template>
    <!-- ########### -->   
    <xsl:template name="OutputHeader">
        <xsl:param name="mainTitle"/>
        <xsl:param name="mainAuthors"/>
        <xsl:param name="mainPublStmt"/>
        <xsl:param name="authorCount"/>
        <xsl:param name="availability"/>
        <xsl:param name="printSrcStmt"/>
        <xsl:param name="iel"/>
        <xsl:param name="subjectinfo"/>
        <!-- *** -->
        <xsl:variable name="filedesc" select="descendant-or-self::HEADER/FILEDESC"/>
        <xsl:variable name="sourcedesc" select="descendant-or-self::HEADER/FILEDESC/SOURCEDESC"/>
        <xsl:variable name="biblSrc" select="($sourcedesc/BIBLFULL|$sourcedesc/BIBL)"/>
        <xsl:variable name="sertitlePath" select="($biblSrc/TITLESTMT|$biblSrc)"/>
        <xsl:variable name="monotitlePath" select="$filedesc/TITLESTMT"/>
        <xsl:variable name="sourcetitlePath" select="($sourcedesc//TITLESTMT|$sourcedesc/BIBLFULL|$sourcedesc/BIBL)"/>
        <xsl:variable name="authorPath" select="$filedesc/TITLESTMT"/>
        <xsl:variable name="SrcPubStPath" select="($biblSrc/PUBLICATIONSTMT|$biblSrc/IMPRINT|$biblSrc)"/>
        <xsl:if test="$mainAuthors!=''">
            <xsl:call-template name="BuildHeaderRow">
                <xsl:with-param name="label">
                  <xsl:choose>
                    <xsl:when test="HEADER/FILEDESC/TITLESTMT/AUTHOR">
                      <xsl:value-of select="key('get-lookup','headerutils.str.author')"/> 
                  </xsl:when>
                  <xsl:when test="HEADER/FILEDESC/TITLESTMT/EDITOR">
                     <xsl:value-of select="key('get-lookup','headerutils.str.editor')"/> 
                  </xsl:when>
                </xsl:choose>
                <xsl:if test="$authorCount &gt; 1">
                  <xsl:value-of select="concat(key('get-lookup','headerutils.str.plural'),'&#xa0;')"/>
                </xsl:if>
              </xsl:with-param>
              <xsl:with-param name="value" select="$mainAuthors"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="BuildHeaderRow">
            <xsl:with-param name="label">
              <xsl:value-of select="key('get-lookup','headerutils.str.title')"/>
            </xsl:with-param>
            <xsl:with-param name="value" select="$mainTitle"/>
        </xsl:call-template>
        <xsl:if test="$mainPublStmt!=''">
            <xsl:call-template name="BuildHeaderRow">
                <xsl:with-param name="label">
                    <xsl:value-of select="key('get-lookup','headerutils.str.publicationinfo')"/>
                </xsl:with-param>
                <xsl:with-param name="value">
                    <xsl:copy-of select="$mainPublStmt"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$availability!=''">
            <xsl:call-template name="BuildHeaderRow">
                <xsl:with-param name="label">
                    <xsl:value-of select="key('get-lookup','headerutils.str.22')"/>
                </xsl:with-param>
                <xsl:with-param name="value">
                    <xsl:copy-of select="$availability"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$printSrcStmt!=''">
            <xsl:call-template name="BuildHeaderRow">
                <xsl:with-param name="label">
                    <xsl:value-of select="key('get-lookup','headerutils.str.printsource')"/>
                </xsl:with-param>
                <xsl:with-param name="value">
                    <xsl:copy-of select="$printSrcStmt"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$subjectinfo!=''">
            <xsl:call-template name="BuildHeaderRow">
                <xsl:with-param name="label">
                    <xsl:value-of select="key('get-lookup','headerutils.str.subjectterms')"/>
                </xsl:with-param>
                <xsl:with-param name="value" select="$subjectinfo"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="BuildHeaderRow">
            <xsl:with-param name="label">
                <xsl:value-of select="key('get-lookup','headerutils.str.23')"/>
            </xsl:with-param>
            <xsl:with-param name="value">
                <xsl:value-of select="/Top/DlxsGlobals/BookmarkableUrl"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <!-- ########### -->
    <xsl:template name="BuildHeaderRow">
        <xsl:param name="label"/>
        <xsl:param name="value"/>
        <xsl:param name="valuetype" select="'single'"/>
        <tr valign="top">
            <td id="labelcell" width="50" class="nobreak">
                <span class="hdrrowlabel">
                    <xsl:value-of select="$label"/>
                    <xsl:text>: </xsl:text>
                </span>
            </td>
            <td valign="top">
                <xsl:copy-of select="$value"/>
            </td>
        </tr>
    </xsl:template>
    <!-- ########### -->
    <xsl:template match="BIBLFULL">
        <xsl:apply-templates select="TITLESTMT|PUBLICATIONSTMT"/>
    </xsl:template>      
    <!-- ########### -->
    <xsl:template match="IMPRINT|PUBLICATIONSTMT">
            <xsl:for-each select="PUBPLACE">
                <xsl:value-of select="dlxs:stripEndingChars(.,'.,:;')"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>,&#xa0;</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>.&#xa0;</xsl:text>
            <xsl:for-each select="PUBLISHER">
                <xsl:value-of select="dlxs:stripEndingChars(.,'.,:;')"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>,&#xa0;</xsl:text>
                </xsl:if>
                <xsl:if test="position()=last()">
                    <xsl:text>.&#xa0;</xsl:text>
                </xsl:if>
            </xsl:for-each>
            <xsl:apply-templates select="DATE"/>
    </xsl:template>
<!-- ########### -->
    <xsl:template match="TITLESTMT|BIBL">
        <xsl:if
            test="not(name()='TITLESTMT') and not(ancestor::Item[1]/DocEncodingType='monograph')">
            <xsl:if test="TITLE">
                <div>
                    <strong>
                        <xsl:value-of select="key('get-lookup','headerutils.str.title')"/>
                        <xsl:text>&#xa0;</xsl:text>
                    </strong>
                    <xsl:apply-templates select="TITLE" mode="hdrtitle"/>
                    <xsl:if test="../EDITIONSTMT">
                        <xsl:value-of select="concat(', ',../EDITIONSTMT)"/>
                    </xsl:if>
                </div>
            </xsl:if>
        </xsl:if>
        <xsl:if test="AUTHOR">
            <div>
                <strong>
                    <xsl:value-of select="key('get-lookup','headerutils.str.author')"/>
                    <xsl:if test="count(AUTHOR) &gt; 1">
                        <xsl:value-of select="key('get-lookup','headerutils.str.plural')"/>
                    </xsl:if>
                    <xsl:text>:&#xa0;</xsl:text>
                </strong>
                <xsl:apply-templates select="AUTHOR" mode="hdrauthor"/>
            </div>
        </xsl:if>
        <xsl:if test="EDITOR">
            <div>
                <strong>
                    <xsl:value-of select="key('get-lookup','headerutils.str.editor')"/>
                    <xsl:if test="count(EDITOR) &gt; 1">
                        <xsl:value-of select="key('get-lookup','headerutils.str.plural')"/>
                    </xsl:if>
                    <xsl:text>:&#xa0;</xsl:text>
                </strong>
                <xsl:apply-templates select="EDITOR" mode="hdreditor"/>
            </div>
        </xsl:if>
        <xsl:apply-templates select="PUBLISHER|PUBPLACE|DATE|IMPRINT"/>
    </xsl:template>
    <!-- ########### -->
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
                 <xsl:if test="following-sibling::BIBLSCOPE[not(@TYPE='issuetitle')]">, </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ########### -->
    <xsl:template name="procTitle">
        <!-- apply templates to handle any HI1 elements -->
        <xsl:choose>
            <xsl:when test="HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245'] ">
                <xsl:apply-templates select="HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="HEADER/FILEDESC/TITLESTMT/TITLE[not(@TYPE='sort')][1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ########### -->
    <xsl:template name="docISBN">
        <xsl:param name="srcbiblpath"/>
        <xsl:variable name="isbncheck"
            select="translate($srcbiblpath/PUBLICATIONSTMT/IDNO[@TYPE='ISBN'],'0123456789','xxxxxxxxxx')"/>
        <xsl:if test="$isbncheck='xxxxxxxxxx'">
            <br/>
            <xsl:value-of select="key('get-lookup','headerutils.str.isbn')"/>
            <xsl:text>:&#xa0;</xsl:text>
            <xsl:value-of select="$srcbiblpath/PUBLICATIONSTMT/IDNO[@TYPE='ISBN']"/>
        </xsl:if>
    </xsl:template>
    <!-- ########### -->

    <xsl:template match="EDITIONSTMT">
        <div>
            <strong>
                <xsl:value-of select="key('get-lookup','headerutils.str.edition')"/>
                <xsl:text>:&#xa0;</xsl:text>
            </strong>
            <xsl:value-of select="EDITION"/>
        </div>
    </xsl:template>
    <!-- ########### -->
    <xsl:template match="DATE">
        <xsl:value-of select="."/>
    </xsl:template>
     <!-- ########### -->
    <xsl:template match="DATES">
   <xsl:text> (</xsl:text><xsl:value-of select="."/><xsl:text>)</xsl:text>
     </xsl:template>
     <!-- ########### -->
    <xsl:template match="ALIAS">
   <xsl:text> (a.k.a. </xsl:text><xsl:value-of select="."/><xsl:text>)</xsl:text>
     </xsl:template>
   <!-- ########### -->
    <xsl:template match="AUTHOR" mode="hdrauthor">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::AUTHOR">, </xsl:if>
    </xsl:template>
    <!-- ########### -->
    <xsl:template match="EDITOR">
        <xsl:value-of select="."/>
        <xsl:if test="following-sibling::EDITOR">, </xsl:if>
    </xsl:template>
    <!-- ########### -->
    <xsl:template match="TERM[ancestor::HEADER]">
        <xsl:variable name="termtype">
            <xsl:call-template name="normAttr">
                <xsl:with-param name="attr" select="./@TYPE"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- ########### -->
    <xsl:template match="BIBL">
        <br/>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="DATE[@TYPE='sort']"/>

    <!-- Render DESCRIP elements at the collection level -->
    <xsl:template match="DESCRIP"/>


</xsl:stylesheet>
