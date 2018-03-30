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
    <xsl:param name="newline"><xsl:text>
</xsl:text></xsl:param>
    <!-- grammar from https://tools.ietf.org/html/rfc4180-->  
    <xsl:include href="rfc4180.xsl"/>
    <xsl:output indent="yes"/> 
    <xsl:variable name="string"> "       test""           , test1","test2
""             test3"
    1,2,3,4,5,"six"</xsl:variable>
    <xsl:strip-space elements="*"/>
    <xsl:template match="/"> 
        <xsl:sequence select="flub:parse-csv('file:/home/oyvind/repos/systemer/unpaywall2rdf/xsl/csv-xsl3/test/csv-spectrum/csvs/utf8.csv')"/>
        
  </xsl:template>    
    
    <xsl:function name="flub:not-in-quote" as="xs:boolean" expand-text="1">
        <xsl:param name="string" as="xs:string?"/>        
        {if(((string-length($string) - string-length(replace($string, $quote, ''))) mod 2 = 0)
        or string-length($string) = string-length(replace($string, $quote, '')))
        then true() 
        else false()
        }
    </xsl:function>
        
    <xsl:function name="flub:parse-csv" expand-text="1">       
        <xsl:param name="csv-uri" as="xs:string"/>
            <xsl:iterate select="unparsed-text-lines($csv-uri)">
            <xsl:param name="preceding-lines" as="xs:string?"/>
            <xsl:on-completion>
                <xsl:if test="exists($preceding-lines)">
                    <xsl:message>Unable to parse csv, last line unclosed.</xsl:message>
                </xsl:if>
                <xsl:if test="flub:isCompleteRecord($preceding-lines)">
                    <xsl:message>test</xsl:message>
                </xsl:if>
            </xsl:on-completion>
            <xsl:variable name="csv-record" as="xs:string"><xsl:text>{$preceding-lines}{if ($preceding-lines) then $newline else ''}{.}</xsl:text></xsl:variable>
            <xsl:choose>
                <xsl:when test="string-length($preceding-lines) &gt; 10000">
                    <xsl:message terminate="yes"></xsl:message>
                </xsl:when>
                <xsl:when test="flub:isCompleteRecord($csv-record)">
                    <xsl:text>{$csv-record}{if (position()!=last()) then $newline else ''}</xsl:text>
                     <xsl:next-iteration>
                         <xsl:with-param name="preceding-lines" select="()"></xsl:with-param>
                     </xsl:next-iteration>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:next-iteration>
                        <xsl:with-param name="preceding-lines" select="$csv-record"/>
                    </xsl:next-iteration>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:iterate>
    </xsl:function>
    
    <xsl:function name="flub:get-field" as="xs:string*">
        <xsl:param name="record" as="xs:string"/>
        <xsl:analyze-string select="$record" regex="{$FIELD}">
            <xsl:matching-substring>
                <xsl:sequence select="."/>
            </xsl:matching-substring>
        </xsl:analyze-string>        
    </xsl:function>
    
    <!--<xsl:function name="flub:parse-csv-to-xml" expand-text="1">
        <xsl:param name="string"/>
        <csv>
        <xsl:iterate select="flub:parse-csv-rows($string)">
            <row>
            <xsl:iterate select="flub:parse-csv-fields(.)">
                <field>{.}</field>
            </xsl:iterate>
            </row>
        </xsl:iterate>
        </csv>
    </xsl:function>-->
    <!--
    <xsl:function name="flub:parse-csv-rows" as="xs:string*">
        <xsl:param name="string" as="xs:string"/>
        
        <xsl:sequence select="flub:parse-csv-rows($string,())"/>
    </xsl:function>
    -->
<!--    
    <xsl:function name="flub:parse-csv-rows" as="xs:string*">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="to-row" as="xs:integer?"/>
        
         
        <xsl:iterate select="$tokens">            
            <xsl:param name="segment" as="xs:string?"/>
            <xsl:param name="row-position" select="1" as="xs:integer"/>            
            <xsl:variable name="position" select="position()" as="xs:integer"/>            
            <xsl:variable name="current-string" select="concat($segment,.)" as="xs:string?"/>
            
            <xsl:choose>            
                <xsl:when test="exists($to-row) and ($row-position &gt; $to-row ) ">
                    <xsl:break/>                    
                </xsl:when>
                <xsl:when test="not(flub:not-in-quote($current-string))">                   
                    <!-\- adding segment to prepend to next iteration -\->                       
                        <xsl:next-iteration>
                        <xsl:with-param name="segment" select="if ($segment) then 
                            concat($segment,$newline,.)
                            else concat(.,$newline)
                            "/>
                        </xsl:next-iteration>                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$current-string"/>
                    <xsl:next-iteration>
                        <xsl:with-param name="row-position" select="$row-position +1"/>
                        <xsl:with-param name="segment" select="()"></xsl:with-param>
                    </xsl:next-iteration>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:iterate>    
    </xsl:function>
-->    
    <xsl:variable name="record-regex" expand-text="1" as="xs:string"><xsl:text>^{$RECORD}$</xsl:text></xsl:variable>
    <xsl:function name="flub:isCompleteRecord" as="xs:boolean">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:sequence select="matches($string,$record-regex)"/>
    </xsl:function>
    
    <xsl:function name="flub:parse-csv-fields" as="xs:string*">
        <xsl:param name="string" as="xs:string?"/>      
        <xsl:variable name="tokens" select="tokenize($string,$separator-regex)"/>
            <xsl:iterate select="$tokens">
                <xsl:param name="segment" as="xs:string?"/>
                <xsl:variable name="position" select="position()"/>
                <xsl:variable name="current-string" select="replace(concat($segment,.),'^\s+|\s+$','')"/>
                <xsl:choose>
                    <xsl:when test="flub:not-in-quote($current-string)">
                        <xsl:sequence select="$current-string"/>
                        <xsl:next-iteration>
                            <xsl:with-param name="segment" select="()"/>
                        </xsl:next-iteration>
                    </xsl:when>
                    <xsl:otherwise>
                         <xsl:next-iteration>
                             <xsl:with-param name="segment" select="flub:segment-helper($current-string,$segment,$separator-regex)"/>
                        </xsl:next-iteration>
                    </xsl:otherwise>
                </xsl:choose>             
            </xsl:iterate>
    </xsl:function>
    
    <xsl:function expand-text="1" name="flub:segment-helper" as="xs:string?">        
        <xsl:param name="string" as="xs:string?"/>
        <xsl:param name="segment" as="xs:string?"/>
        <xsl:param name="separator" as="xs:string"/>
        <xsl:sequence select="if ($segment)
        then concat($segment,$separator,$string,$separator)
        else concat($string,$separator)"/>
        </xsl:function>
   
</xsl:stylesheet>