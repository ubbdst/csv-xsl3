<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0" expand-text="1">
    <!-- adding additonal unicode-ranges to 4180.
         Adding full range for the extended, not removing 'open codes'-->
    <xsl:variable name="EXTENDED_UNICODE" as="xs:string">&#x0080;-&#xFFFD;&#x10000;-&#x1FFFF;&#xF0000;-&#xFFFFD;</xsl:variable>
    <!--<xsl:variable name="TEXTDATA" as="xs:string">&#x20;-&#x21;&#x23;-&#x2B;\&#x2D;-&#x7E;&#x0250;-&#x02AF;{$EXTENDED_UNICODE}</xsl:variable>-->
    <xsl:variable name="TEXTDATA" as="xs:string">^{$DQUOTE}{$COMMA}&#x0D;&#x0A;</xsl:variable>
    <xsl:variable name="COMMA" as="xs:string">&#x2c;</xsl:variable>
    <!-- optional CR-->
    <xsl:variable name="CRLF" as="xs:string" select="'&#x0D;?&#x0A;'"/>
    <xsl:variable name="DQUOTE" as="xs:string" select="'&#x22;'"/>
    <xsl:variable name="TWODQUOTE" as="xs:string">{$DQUOTE}{$DQUOTE}</xsl:variable>
    <xsl:variable name="NON_ESCAPED" as="xs:string">[{$TEXTDATA}]</xsl:variable>
    
    <xsl:variable name="ESCAPED" as="xs:string">{$DQUOTE}({$TWODQUOTE}|[^{$DQUOTE}])*{$DQUOTE}</xsl:variable>
    <xsl:variable name="FIELD" as="xs:string">(({$NON_ESCAPED}*)|({$ESCAPED}))</xsl:variable>
    <!-- empty regex  '' match disallowed in xslt, using for first row combined with |^,-->
    <xsl:variable name="FIELD.ONEORMORENON_ESPACED" as="xs:string">(({$NON_ESCAPED}+)|({$ESCAPED}))</xsl:variable>
    <xsl:variable name="NAME" as="xs:string">{$FIELD}</xsl:variable>
    <xsl:variable name="HEADER" as="xs:string">{$NAME}({$COMMA}{$NAME})*</xsl:variable>
    <xsl:variable name="RECORD" as="xs:string">({$FIELD.ONEORMORENON_ESPACED}|^{$COMMA})({$COMMA}{$FIELD})*</xsl:variable>
    
</xsl:stylesheet>