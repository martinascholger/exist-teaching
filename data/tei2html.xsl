<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="tei xs math"
    version="3.0">
    
    <xsl:template match="/">
        <div>
            <xsl:apply-templates select="tei:TEI/tei:text/tei:body/tei:div[@type='writingSession']" />
        </div>
    </xsl:template>
    
    <xsl:template match="tei:opener | tei:closer | tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="tei:choice">
        <xsl:apply-templates select="tei:expan"/>
    </xsl:template>
    
    <xsl:template match="tei:abbr"/>
    
    <xsl:template match="tei:persName">
        <a href="{@ref}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
        
</xsl:stylesheet>