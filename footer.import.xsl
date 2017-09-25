<?xml version="1.0" encoding="UTF-8" ?>



<xsl:stylesheet 

  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

  version="1.0">



  <!-- ********************************************************************** -->

  <!-- BUILDFOOTER -->

  <!-- ********************************************************************** -->

  <xsl:template name="BuildFooter">

    <br />

    <br />



    <xsl:element name="div">

      <xsl:attribute name="id">footer</xsl:attribute>

	  	<div id="footer-content">
			<p><xsl:text>&#xa9;2016 </xsl:text>

                <xsl:element name="a">

                <xsl:attribute name="href">http://www.library.cornell.edu</xsl:attribute>

                <xsl:text>Cornell University Library</xsl:text>

                </xsl:element>

                <xsl:text> | </xsl:text>

                <xsl:element name="a">

                <xsl:attribute name="href">/m/moa/moa_mail.html</xsl:attribute>

                <xsl:text>Contact</xsl:text>

                </xsl:element></p>
		</div>





    </xsl:element>




  </xsl:template>

  

  <!-- ********************************************************************** -->

  <!-- secondLevelTemplates -->

  <!-- ********************************************************************** -->



  <xsl:template match="GraphicsPathUparrow">

    <xsl:copy-of select="."/>

  </xsl:template>



  <xsl:template match="ContactText">

    <xsl:value-of select="."/>

  </xsl:template>



  <xsl:template match="OrgInfoText">

    <xsl:value-of select="."/>

  </xsl:template>



</xsl:stylesheet>

