<ul id="menu">
	<li class="first">
		<a href="${pageContext.request.contextPath}/admin"><spring:message code="admin.title.short"/></a>
	</li>
	<li <c:if test='<%= request.getRequestURI().contains("groovyForm") %>'>class="active"</c:if>>
		<a href="groovy.form">
			<spring:message code="groovy.scripting-form"/>
		</a>
	</li>
	<li <c:if test='<%= request.getRequestURI().contains("groovyScriptList") %>'>class="active"</c:if>>
		<a href="groovy.list">
			<spring:message code="groovy.manage"/>
		</a>
	</li>
</ul>