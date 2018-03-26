<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:flub="http://data.ub.uib.no/ns/xsl/function-library"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs flub math"
    version="3.0">
    
    <xsl:param name="quote" select="'&quot;'"/>
    <xsl:param name="separator-regex" select="','"/>
    <xsl:param name="newline-regex" select="'\n'"/>
    <xsl:param name="newline"><xsl:text>
</xsl:text></xsl:param>
   <xsl:output indent="yes"/> 
    <xsl:variable name="string"> "       test""           , test1","test2
""             test3"
    1,2,3,4,5,"six"</xsl:variable>
    <xsl:strip-space elements="*"/>
    <xsl:template match="/"> 
        <xsl:sequence select="flub:parse-csv-to-xml($string)"/>
        
  </xsl:template>    
    
    <xsl:function name="flub:not-in-quote" as="xs:boolean" expand-text="1">
        <xsl:param name="string" as="xs:string?"/>        
        <xsl:variable name="string-length" as="xs:integer" select="string-length($string)"/>
        <xsl:variable name="string-length-quote" select="string-length(replace($string, $quote, ''))" as="xs:integer"/>
        {if(($string-length=$string-length-quote) or ($string-length - $string-length-quote) mod 2 = 0)
        then true() 
        else false()
        }
    </xsl:function>
    
    <xsl:function name="flub:parse-csv-to-xml" expand-text="1">
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
    </xsl:function>
    
    <xsl:function name="flub:parse-csv-rows" as="xs:string*">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="flub:parse-csv-rows($string,())"/>
    </xsl:function>
    
    <xsl:function name="flub:parse-csv-rows" as="xs:string*">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="to-row" as="xs:integer?"/>        
        <xsl:variable name="tokens" select="tokenize($string,$newline-regex)"/> 
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
                    <!-- adding segment to prepend to next iteration -->                       
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
                        <xsl:with-param name="segment" select="()"/>
                    </xsl:next-iteration>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:iterate>    
    </xsl:function>
    
    <xsl:function name="flub:parse-csv-fields" as="xs:string*">
        <xsl:param name="string" as="xs:string?"/>      
        <xsl:variable name="tokens" select="tokenize($string,$separator-regex)" as="xs:string+"/>
            <xsl:iterate select="$tokens">
                <xsl:param name="segment" as="xs:string?"/>
                <xsl:variable name="position" select="position()" as="xs:integer"/>
                <xsl:variable name="current-string" select="replace(concat($segment,.),'^\s+|\s+$','')" as="xs:string"/>
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