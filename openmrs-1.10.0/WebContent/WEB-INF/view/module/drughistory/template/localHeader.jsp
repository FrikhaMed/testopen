<spring:htmlEscape defaultHtmlEscape="true" />
<ul id="menu">
	<li class="first"><a
		href="${pageContext.request.contextPath}/admin"><spring:message
				code="admin.title.short" /></a></li>

	<li
		<c:if test='<%= request.getRequestURI().contains("/manage") %>'>class="active"</c:if>>
		<a
		href="${pageContext.request.contextPath}/module/drughistory/manage.form"><spring:message
				code="drughistory.manage" /></a>
	</li>

    <li
    <c:if test='<%= request.getRequestURI().contains("/regimen") %>'>class="active"</c:if>>
    <a
            href="${pageContext.request.contextPath}/module/drughistory/regimen.list"><spring:message
            code="drughistory.regimen.manage" /></a>
    </li>
</ul>
<h2>
	<spring:message code="drughistory.title" />
</h2>
