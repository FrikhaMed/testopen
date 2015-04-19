<%
    def multiple = "java.util.List" == param.collectionType[0] || "java.util.Set" == param.collectionType[0]
%>
<location-widget multiple="${ multiple }" target="paramValues[param.name]"/>