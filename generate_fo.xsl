<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:output method="xml" indent="yes"/>

    <!-- Variables para márgenes -->
    <xsl:variable name="page-width" select="'21cm'"/>
    <xsl:variable name="page-height" select="'29.7cm'"/>
    <xsl:variable name="margin-left" select="'1.5cm'"/>
    <xsl:variable name="margin-right" select="'1.5cm'"/>
    <xsl:variable name="margin-top" select="'1cm'"/>
    <xsl:variable name="margin-bottom" select="'2cm'"/>

    <xsl:template match="/handball_data">
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="A4-portrait"
                                       page-width="{$page-width}" page-height="{$page-height}"
                                       margin-left="{$margin-left}" margin-right="{$margin-right}"
                                       margin-top="{$margin-top}" margin-bottom="{$margin-bottom}">
                    <fo:region-body margin-top="1cm" margin-bottom="1cm"/>
                    <fo:region-before extent="1cm"/>
                    <fo:region-after extent="2cm"/>
                </fo:simple-page-master>
            </fo:layout-master-set>

            <fo:page-sequence master-reference="A4-portrait">
                <fo:static-content flow-name="xsl-region-before">
                    <fo:block font-size="10pt" font-family="sans-serif" text-align="right" color="black">
                        <xsl:value-of select="concat(season/category, ' Handball season for ', season/gender, ' - ', season/year)"/>
                    </fo:block>
                </fo:static-content>

                <fo:flow flow-name="xsl-region-body">

                    <!-- Texto de 16 pt -->
                    <fo:block font-size="16pt" font-family="sans-serif" space-after.optimum="10pt" font-weight="bold">
                        <xsl:text>Competitors of </xsl:text>
                        <xsl:value-of select="season/name"/>
                    </fo:block>

                    <!-- Para cada competidor -->
                    <xsl:for-each select="competitors/competitor">
                        <!-- Nombre y país -->
                        <fo:block font-size="12pt" font-family="sans-serif" space-before.optimum="10pt" space-after.optimum="5pt">
                            <xsl:value-of select="@name"/>
                            <xsl:if test="@country and string-length(normalize-space(@country)) > 0">
                                <xsl:text> (</xsl:text>
                                <xsl:value-of select="@country"/>
                                <xsl:text>)</xsl:text>
                            </xsl:if>
                        </fo:block>

                        <!-- Tabla -->
                        <fo:table text-align="center" table-layout="fixed" width="100%" border="1pt solid black" font-size="8pt" font-family="sans-serif" border-collapse="collapse">
                            <fo:table-column column-width="40%"/>
                            <fo:table-column column-width="7%"/>
                            <fo:table-column column-width="7%"/>
                            <fo:table-column column-width="7%"/>
                            <fo:table-column column-width="7%"/>
                            <fo:table-column column-width="7%"/>
                            <fo:table-column column-width="7%"/>
                            <fo:table-column column-width="7%"/>

                            <!-- Cabecera -->
                            <fo:table-header background-color="rgb(215,245,250)">
                                <fo:table-row>
                                    <fo:table-cell><fo:block>Group</fo:block></fo:table-cell>
                                    <fo:table-cell><fo:block>Rank</fo:block></fo:table-cell>
                                    <fo:table-cell><fo:block>Played</fo:block></fo:table-cell>
                                    <fo:table-cell><fo:block>Wins</fo:block></fo:table-cell>
                                    <fo:table-cell><fo:block>Loss</fo:block></fo:table-cell>
                                    <fo:table-cell><fo:block>Draws</fo:block></fo:table-cell>
                                    <fo:table-cell><fo:block>Goals Diff</fo:block></fo:table-cell>
                                    <fo:table-cell><fo:block>Points</fo:block></fo:table-cell>
                                </fo:table-row>
                            </fo:table-header>

                            <fo:table-body>
                                <!-- Iterar standings ordenados por points desc, luego goals_diff asc -->
                                <xsl:for-each select="standings/standing">
                                    <xsl:sort select="@points" data-type="number" order="descending"/>
                                    <xsl:sort select="@goals_diff" data-type="number" order="ascending"/>
                                    <fo:table-row>
                                        <fo:table-cell><fo:block><xsl:value-of select="@group_name"/></fo:block></fo:table-cell>
                                        <fo:table-cell><fo:block><xsl:value-of select="@rank"/></fo:block></fo:table-cell>
                                        <fo:table-cell><fo:block><xsl:value-of select="@played"/></fo:block></fo:table-cell>
                                        <fo:table-cell><fo:block><xsl:value-of select="@win"/></fo:block></fo:table-cell>
                                        <fo:table-cell><fo:block><xsl:value-of select="@loss"/></fo:block></fo:table-cell>
                                        <fo:table-cell><fo:block><xsl:value-of select="@draw"/></fo:block></fo:table-cell>
                                        <fo:table-cell><fo:block><xsl:value-of select="@goals_diff"/></fo:block></fo:table-cell>
                                        <fo:table-cell><fo:block><xsl:value-of select="@points"/></fo:block></fo:table-cell>
                                    </fo:table-row>
                                </xsl:for-each>
                            </fo:table-body>

                        </fo:table>
                    </xsl:for-each>

                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>
</xsl:stylesheet>
