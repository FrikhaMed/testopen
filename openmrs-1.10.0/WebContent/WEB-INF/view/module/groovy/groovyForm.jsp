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
<openmrs:require privilege="Run Groovy Scripts" otherwise="/login.htm" redirect="/module/groovy/groovy.form"/>

<%@ include file="/WEB-INF/template/header.jsp" %>
<openmrs:htmlInclude file="/dwr/interface/DWRGroovyService.js"/>
<openmrs:htmlInclude file="/dwr/engine.js"/>
<openmrs:htmlInclude file="/dwr/util.js"/>
<openmrs:htmlInclude file="/scripts/jquery-ui/js/jquery-ui.custom.min.js" />
<openmrs:htmlInclude file="/scripts/jquery-ui/js/jquery-ui-1.7.2.custom.min.js" />
<openmrs:htmlInclude file="/scripts/jquery-ui/css/redmond/jquery-ui-1.7.2.custom.css" />
<script type="text/javascript"
        src="${pageContext.request.contextPath}/moduleResources/groovy/js/codemirror.js"></script>
<script type="text/javascript"
        src="${pageContext.request.contextPath}/moduleResources/groovy/js/mirrorframe.js"></script>
<link rel="stylesheet" type="text/css"
      href="${pageContext.request.contextPath}/moduleResources/groovy/css/main.css"/>
<script type="text/javascript"
        src="${pageContext.request.contextPath}/moduleResources/groovy/js/main.js"></script>

<%@ include file="localHeader.jsp" %>

<form:form id="scriptForm" commandName="script" name="scriptForm">
    <form:errors path="*" cssClass="error"/>
    <form:hidden path="name" id="name" /> 
    <div id="script-name" title="<spring:message code="groovy.renameDialogHint"/>">${fn:length(script.name) > 0 ? script.name : "untitled"}</div>
    <div id="textarea-container" class="border">
        <form:textarea path="script" cols="140" rows="40" id="groovyScript"/>
    </div>
    <div id="button-bar">
	    <input id="executeButton" type="button" value="<spring:message code="groovy.execute"/>"/>&nbsp;
        <input id="saveButton" type="submit" value="<spring:message code="groovy.save"/>"/>
    </div>    
</form:form>

<div id="tabs">
    <ul>
    	<li><a href="#tabs-result"><spring:message code="groovy.result-tab"/></a></li>
    	<li><a href="#tabs-output"><spring:message code="groovy.output-tab"/></a></li>
    	<li><a href="#tabs-stacktrace"><spring:message code="groovy.stacktrace-tab"/></a></li>
    </ul>

    <div id="tabs-result">
        <pre id="result" class="border hidden"></pre>
    </div>

    <div id="tabs-output">
        <pre id="output" class="border hidden"></pre>
    </div>                                                                              
    

    <div id="tabs-stacktrace">
        <pre id="stacktrace" class="border hidden"></pre>
    </div>                                      </div>
<div id="running-html" class="hidden"><h1><spring:message code="groovy.running"/></h1></div>
<div id="noPrivileges" class="hidden"><h1><spring:message code="groovy.insufficentPrivileges"/></h1></div>

<ul id="groovy-resources">
    <li><spring:message code="groovy.info"/></li>
    <li><spring:message code="groovy.info2"/></li>
    <li><a href="http://groovy.codehaus.org/Documentation" target="_groovy_doc"><spring:message code="groovy.documentation-link"/></a></li>
</ul>


<div id="invalid-name-length-msg" class="hidden"><spring:message code="groovy.invalidNameLength"/></div>
<div id="invalid-name-pattern-msg" class="hidden"><spring:message code="groovy.invalidNamePattern"/></div>
<div id="rename-dialog-submit" class="hidden"><spring:message code="groovy.renameDialogSubmit"/></div>
<div id="rename-dialog-cancel" class="hidden"><spring:message code="groovy.renameDialogCancel"/></div>
<div id="rename-dialog" title="<spring:message code="groovy.renameDialogTitle"/>">
	<p class="validateTips"></p>
	<form>
	<fieldset>
		<label for="new-name"><spring:message code="groovy.newName"/></label>
		<input type="text" name="new-name" id="new-name" class="text ui-widget-content ui-corner-all" />
	</fieldset>
	</form>
</div>


<script language="javascript">                                                                                                                    
    var editor = CodeMirror.fromTextArea('groovyScript', {
        height: "300px",
        parserfile: ["tokenizejavascript.js", "parsejavascript.js"],
        stylesheet: "${pageContext.request.contextPath}/moduleResources/groovy/css/jscolors.css",
        path: "${pageContext.request.contextPath}/moduleResources/groovy/js/",
        continuousScanning: 500,
        lineNumbers: true,
        textWrapping: false,
        autoMatchParens: true,
        tabMode: "spaces",
        submitFunction: function() {
            $j("#executeButton").click();
        },
        saveFunction:function() {
            document.forms["scriptForm"].submit();
        }
    });
</script>
<%@ include file="/WEB-INF/template/footer.jsp" %>