<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="View Data Exports" otherwise="/login.htm" redirect="/admin/reports/dataExport.list" />

<%@ include file="/WEB-INF/template/header.jsp" %>
<%@ include file="localHeader.jsp" %>

<h2><spring:message code="reportingcompatibility.DataExport.manage.title"/></h2>	

<a href="dataExport.form"><spring:message code="reportingcompatibility.DataExport.add"/></a> <br />

<br />

<openmrs:hasPrivilege privilege="Manage Global Properties">
<b class="boxHeader"><spring:message code="reportingcompatibility.DataExport.list.properties"/></b>
<form method="post" class="box">
	
	<spring:message code="reportingcompatibility.DataExport.speed"/>:
	<select name="dataExportBatchSize">
		<option value=""></option>
		<option value="12000" <c:if test="${batchSize == '12000'}">selected</c:if>><spring:message code="reportingcompatibility.DataExport.speed.fastest"/></option>
		<option value="10000" <c:if test="${batchSize == '10000'}">selected</c:if>><spring:message code="reportingcompatibility.DataExport.speed.fast"/></option>
		<option value="7500" <c:if test="${batchSize == '7500'}">selected</c:if>><spring:message code="reportingcompatibility.DataExport.speed.medium"/></option>
		<option value="4000" <c:if test="${batchSize == '4000'}">selected</c:if>><spring:message code="reportingcompatibility.DataExport.speed.slow"/></option>
		<option value="2500" <c:if test="${batchSize == '2500'}">selected</c:if>><spring:message code="reportingcompatibility.DataExport.speed.slowest"/></option>
	</select>
	
	<input type="hidden" name="action" value="saveProperties"/>
	<input type="submit" value='<spring:message code="general.save"/>'>
</form>

<br/>
</openmrs:hasPrivilege>

<b class="boxHeader"><spring:message code="reportingcompatibility.DataExport.list.title"/></b>
<form method="post" class="box">
	<table cellpadding="2" cellspacing="0">
		<tr>
			<th> </th>
			<th> <spring:message code="general.name" /> </th>
			<th> <spring:message code="general.description" /> </th>
			<th> </th>
		</tr>
		<c:forEach var="dataExport" items="${dataExportList}" varStatus="varStatus">
			<tr class="<c:choose><c:when test="${varStatus.index % 2 == 0}">evenRow</c:when><c:otherwise>oddRow</c:otherwise></c:choose>">
				<td valign="top"><input type="checkbox" name="dataExportId" value="${dataExport.reportObjectId}"></td>
				<td valign="top">
					<a href="dataExport.form?dataExportId=${dataExport.reportObjectId}">${dataExport.name}</a>
				</td>
				<td valign="top">${dataExport.description}</td>
				<td>
					<c:if test="${generatedDates[dataExport] != null}">
						<a href="${pageContext.request.contextPath}/moduleServlet/reportingcompatibility/dataExportServlet?dataExportId=${dataExport.reportObjectId}"><spring:message code="general.download"/></a>
						<span class="smallMessage">(${generatedSizes[dataExport]} <spring:message code="reportingcompatibility.DataExport.generatedOn"/> <openmrs:formatDate date="${generatedDates[dataExport]}" type="long" />)</span>
					</c:if>
				</td>
			</tr>
		</c:forEach>
	</table>
	
	<input type="submit" value='<spring:message code="reportingcompatibility.DataExport.generate"/>' name="action">
	&nbsp;
	<input type="submit" value='<spring:message code="reportingcompatibility.DataExport.delete"/>' name="action" onclick="return confirm('Are you sure you want to DELETE these Exports?')">
</form>

<%@ include file="/WEB-INF/template/footer.jsp" %>