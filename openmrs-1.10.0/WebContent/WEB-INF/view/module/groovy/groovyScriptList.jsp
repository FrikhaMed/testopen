<%--
  The contents of this file are subject to the OpenMRS Public License
  Version 1.0 (the "License"); you may not use this file except in
  compliance with the License. You may obtain a copy of the License at
  http://license.openmrs.org

  Software distributed under the License is distributed on an "AS IS"
  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
  License for the specific language governing rights and limitations
  under the License.

  Copyright (C) OpenMRS, LLC.  All Rights Reserved.

--%>
<%@ include file="/WEB-INF/template/include.jsp" %>
<openmrs:require privilege="List Groovy Scripts" otherwise="/login.htm" redirect="/module/groovy/groovy.list"/>
<%@ include file="/WEB-INF/template/header.jsp" %>
<link rel="stylesheet" type="text/css"
      href="${pageContext.request.contextPath}/moduleResources/groovy/css/main.css"/>

<%@ include file="localHeader.jsp" %>

<p>
    <spring:message code="groovy.list.info"/>
</p>

<c:choose>
    <c:when test="${ fn:length(scripts) > 0}">
        <table style="border: dashed 1px #000;" border="1px; " >
            <tr>
                <td>Name</td>                
                <td>Creator</td>
                <td>Date Created</td>
                <td>Last Modified By</td>
                <td>Date Last Modifed</td>
                <td>Action</td>

            </tr>
            <c:forEach var="script" items="${scripts}" varStatus="status">
                <form method="post">
                    <tr>
                        <td>
                            <a href="groovy.form?id=${script.id}">${script.name}</a>
                        </td>
                        <td>${script.creator}</td>
                        <td>${script.created}</td>
                        <td>${script.modifiedBy}</td>
                        <td>${script.modified}</td>
                        <input type="hidden" value="${script.id}" name="id"/>
                        <td>
                            <input type="submit" value="<spring:message code="groovy.delete"/>"/>
                        </td>
                    </tr>
                </form>              
            </c:forEach>          
        </table>
    </c:when>
    <c:otherwise>
        <h1 style="color:#fff;border:1px dashed #000"><a href="groovy.form"><spring:message code="groovy.list.noscripts"/></a></h1>
    </c:otherwise>
</c:choose>
<%@ include file="/WEB-INF/template/footer.jsp" %>