<%@ include file="/WEB-INF/template/include.jsp" %>
<%@ include file="/WEB-INF/template/header.jsp" %>

<style>
 table {
 	border-color: black;
 	border-width: 1px;
	border-style: solid;
 	overflow-y: auto;
 	background-color: lightgrey;
 	padding: 1px;
 	height: 2.7em;
 }
input {
autocomplete:off;	
}	
select {
autocomplete:off;	
}
</style>

<form method="post">
	<input type="submit" name="submit" value="Generate Phonetics for All Patients"/>

<Br/><Br/>
<table class="portlet" style="">
	<tr><th>global property</th><th></th><th>value</th></tr>
	<tr>	
		<td><spring:message code="namephonetics.givenNameStringEncoder"/></td>
		<td>&nbsp;&nbsp;</td>
		<td>
			<select name="givenNameSelect">
				<option value="" <c:if test="${gpGivenName == ''}">SELECTED</c:if>>&nbsp;</option>
				<c:forEach items="${processors}" var="processor">
					<option value="${processor}" <c:if test="${processor == gpGivenName}">SELECTED</c:if>>${processor}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td><spring:message code="namephonetics.middleNameStringEncoder"/></td>
		<td>&nbsp;&nbsp;</td>
		<td>
			<select name="middleNameSelect">
				<option value="" <c:if test="${gpMiddleName == ''}">SELECTED</c:if>>&nbsp;</option>
				<c:forEach items="${processors}" var="processor">
					<option value="${processor}" <c:if test="${processor == gpMiddleName}">SELECTED</c:if>>${processor}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td><spring:message code="namephonetics.familyNameStringEncoder"/></td>
		<td>&nbsp;&nbsp;</td>
		<td>
			<select name="familyNameSelect">
				<option value="" <c:if test="${gpFamilyName == ''}">SELECTED</c:if>>&nbsp;</option>
				<c:forEach items="${processors}" var="processor">
					<option value="${processor}" <c:if test="${processor == gpFamilyName}">SELECTED</c:if>>${processor}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td><spring:message code="namephonetics.familyName2StringEncoder"/></td>
		<td>&nbsp;&nbsp;</td>
		<td>
			<select name="familyName2Select">
				<option value="" <c:if test="${gpFamilyName2 == ''}">SELECTED</c:if>>&nbsp;</option>
				<c:forEach items="${processors}" var="processor">
					<option value="${processor}" <c:if test="${processor == gpFamilyName2}">SELECTED</c:if>>${processor}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
</table>
<br/>
<input type="submit" name="submit" value="Save Global Properties"/>
</form>
<%@ include file="/WEB-INF/template/footer.jsp" %>