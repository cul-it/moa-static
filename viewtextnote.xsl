<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:key match="Lookup/Item" name="get-lookup" use="@key"/>
  <xsl:template match="/Top">

    <xsl:comment>Using viewtextnote.xsl</xsl:comment>

    <!-- start HTML page -->
    <html>
      <head>
        <xsl:apply-templates select="DlxsGlobals" mode="BuildHeadDefaults"/>
      </head>

      <body bgcolor="#ffffff" class="defaultbody">
        <div class="maincontent">

              <h1>Viewing the entire text</h1>
              <p class="paragraph"><span class="red bold">Please be aware</span> that viewing the entire
              text means loading the entire &quot;volume&quot; in your browser as one block
              of text without page breaks. Some of these texts are as long as 1,000 pages
              and will take a long time to download, particularly over a modem. Such a large
              download may also crash your web browser.</p>
    
              <p class="paragraph bold">
                <xsl:element name="a">
                  <xsl:attribute name="href">
                    <xsl:value-of select="/Top/ViewTextConfirmedLink"/>
                  </xsl:attribute>
                  <xsl:value-of select="key('get-lookup','viewtextnote.str.1')"/>
                </xsl:element>
              </p>

      </div>
    </body>
  </html>

</xsl:template>
</xsl:stylesheet>
