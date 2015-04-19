<%@ include file="/WEB-INF/template/include.jsp" %>
<%@ include file="/WEB-INF/template/header.jsp" %>

<openmrs:require privilege="View Drugs" otherwise="/login.htm" redirect="/module/drughistory/regimen.list"/>

<script>
    $j(document).ready(function(){
        toggleRowVisibilityForClass('regimenTable', 'voided');
    });
</script>

<style>
    a.drug { display: block; }
</style>

<%@ include file="template/localHeader.jsp" %>

<h2>Manage Regimens</h2>

<a href="regimen.form">Add a new regimen</a>

<br /> <br />

<div class="boxHeader">
	<span style="float: right">
		<a href="#" id="showRetired" onClick="return toggleRowVisibilityForClass('regimenTable', 'voided');"><spring:message code="general.toggle.retired"/></a>
	</span>
    <b>All Regimens</b>
</div>
<div class="box">
    <table cellpadding="2" cellspacing="0" id="regimenTable" width="98%">
        <tr>
            <th> <spring:message code="general.name" /> </th>
            <th> <spring:message code="general.description" /> </th>
            <th> Line </th>
            <th> Age Group </th>
            <th> Regimen Drugs </th>

        </tr>
        <c:forEach var="regimen" items="${regimens}" varStatus="status">
            <tr class='${status.index % 2 == 0 ? "evenRow" : "oddRow"} ${regimen.retired ? "voided" : ""}'>
                <td valign="top" style="white-space: nowrap">
                    <a href="regimen.form?id=${regimen.id}">
                        <c:if test="${empty regimen.name}"><em>None Provided</em></c:if>
                        <c:if test="${not empty regimen.name}">${regimen.name}</c:if>
                    </a>
                </td>
                <td valign="top">${regimen.description}</td>
                <td valign="top">${regimen.line}</td>
                <td valign="top">${regimen.age}</td>
                <td valign="top">
                    <c:forEach var="drug" items="${regimen.drugs}">
                        <a class="drug" target="_blank" href="<openmrs:contextPath/>/dictionary/concept.htm?conceptId=${drug.id}">${drug.name} (${drug.id})</a>
                    </c:forEach>
                </td>
            </tr>
        </c:forEach>
    </table>
</div>

<br />

<%@ include file="/WEB-INF/template/footer.jsp" %>
