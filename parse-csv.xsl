<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:flub="http://data.ub.uib.no/ns/xsl/function-library"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs flub math"
    version="3.0">
    <xsl:param name="strict" as="xs:boolean" select="false()"/>
    <xsl:param name="quote" select="'&quot;'"/>
    <xsl:param name="separator-regex" select="','"/>
    <xsl:param name="newline-regex" select="'\n'"/>
    
    <xsl:variable name="newline" select="'&#x0D;&#x0A;'"/>
    <!-- grammar from https://tools.ietf.org/html/rfc4180-->  
    <xsl:include href="rfc4180.xsl"/>
    <xsl:output indent="yes"/> 
    <xsl:variable name="string"> "       test""           , test1","test2
""             test3"
    1,2,3,4,5,"six"</xsl:variable>    
    <xsl:variable name="field-regex"><xsl:text expand-text="1">((({$FIELD.ONEORMORENON_ESPACED}),?|({$FIELD}),)|,)</xsl:text></xsl:variable>
    <xsl:variable name="record-regex" expand-text="1" as="xs:string"><xsl:text>^{$RECORD}$</xsl:text></xsl:variable>
    
    <xsl:variable name="header-size"  as="xs:integer?"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="/"> 
        <xsl:variable name="text">10.1016/0167-4781(85)90058-2,f,2,,,,,,,,Normal rate of DNA breakage in xeroderma pigmentosum complementation group E cells treated with 8-methoxypsoralen plus near-ultraviolet radiation,0167-4781,Biochimica et Biophysica Acta (BBA) - Gene Structure and Expression,f,Elsevier BV,1985,journal-article,2018-01-21 07:37:13.422973</xsl:variable>
      <xsl:sequence select="flub:get-field($text)"></xsl:sequence>
  </xsl:template>    
    
    <xsl:function name="flub:get-header" as="map(xs:string,xs:integer)">
        <xsl:param name="line" as="xs:string"/>
        <xsl:if test="not(flub:isCompleteRecord($string))">
            <xsl:message terminate="yes">flub:get-header unable to parse header-row.</xsl:message>
        </xsl:if>
        <xsl:map>
            <xsl:for-each select="flub:get-field($string)">
                <xsl:map-entry key="(string(.)[string(.)],concat('_',position()))[1]"  select="position()"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:function>
    
    <xsl:template name="filter-csv">
        
    </xsl:template>
    
    <xsl:function name="flub:filter-csv" expand-text="1" as="xs:string">       
        <xsl:param name="csv-uri" as="xs:string"/>
        <xsl:param name="get-filtered-items" 
            as="function(xs:string?) as xs:boolean"/>        
            <xsl:iterate select="unparsed-text-lines($csv-uri)">
            <xsl:param name="preceding-lines" as="xs:string?"/>
            <xsl:param name="preceding-position" as="xs:integer?"/>
            <xsl:on-completion>
                <xsl:if test="exists($preceding-lines)">
                    <xsl:message>Unable to parse csv, last line unclosed. rest {$preceding-lines}</xsl:message>
                </xsl:if>
            </xsl:on-completion>
            <xsl:variable name="csv-record" as="xs:string"><xsl:text>{$preceding-lines}{if ($preceding-lines) then $newline else ''}{.}</xsl:text></xsl:variable>
            <xsl:if test="(position() mod 100000) = 0">
                <xsl:message select="position()"/>
            </xsl:if>
                <xsl:choose>
                <xsl:when test="string-length($preceding-lines) &gt; 100000">
                    <xsl:message terminate="yes"><xsl:value-of select="$preceding-position"/></xsl:message>
                </xsl:when>
                <xsl:when test="flub:isCompleteRecord($csv-record)">
                    <xsl:if test="$get-filtered-items($csv-record)">        
                        <xsl:text>{$csv-record}{if (position()!=last()) then $newline else ''}</xsl:text>
                    </xsl:if>
                    <xsl:next-iteration>
                         <xsl:with-param name="preceding-lines" select="()"></xsl:with-param>
                     </xsl:next-iteration>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:next-iteration>
                        <xsl:with-param name="preceding-position" select="if (empty($preceding-lines)) then position() else $preceding-position"/>
                        <xsl:with-param name="preceding-lines" select="$csv-record"/>
                    </xsl:next-iteration>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:iterate>
    </xsl:function>
    
    <!-- get-field depends on $record string flub:isCompleteRecord($record)-> true()-->
    <xsl:function name="flub:get-field" as="xs:string*">
        <xsl:param name="record" as="xs:string"/> 
           <xsl:variable name="fields" as="xs:string*">
                <xsl:choose>
            <!-- simplify parsing if no $DQOUTE-->
            <xsl:when test="not(contains($record,$DQUOTE))">
                <xsl:sequence select="tokenize($record,',')"/>
            </xsl:when>
                    <xsl:otherwise>  
                        <xsl:analyze-string select="$record" regex="{$field-regex}" flags="m">
                            <xsl:matching-substring>
                            <xsl:sequence select="if (string(regex-group(3)))
                                then regex-group(3)
                                else if (string(regex-group(8)))
                                then regex-group(8) 
                                else ''"/>              
                            </xsl:matching-substring>
                        </xsl:analyze-string></xsl:otherwise>
        </xsl:choose>              
           </xsl:variable>
    <!--    <xsl:if test="$header-size != count($fields)">
            <xsl:message><xsl:value-of select="$fields[1]"/> irregular size</xsl:message>
        </xsl:if>-->
        <xsl:sequence select="$fields"/>
    </xsl:function>
    
    <xsl:function name="flub:isCompleteRecord" as="xs:boolean">
        <xsl:param name="string" as="xs:string?"/>
        
        <!--assume line is Complete if no DQUOTE-->
        <xsl:sequence select="if (not(contains($string,$DQUOTE))) then true() 
            else matches($string,$record-regex)"/>
    </xsl:function>
    
</xsl:stylesheet>