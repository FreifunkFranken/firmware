#!/usr/bin/haserl
<%
echo -en "content-type: text/javascript\r\n\r\n"

zcat /www/ssl/leaflet.js.gz

%>
