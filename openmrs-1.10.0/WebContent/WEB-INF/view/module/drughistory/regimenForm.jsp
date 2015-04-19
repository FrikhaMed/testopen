<%@ include file="/WEB-INF/template/include.jsp" %>
<%@ include file="/WEB-INF/template/header.jsp" %>

<openmrs:require privilege="View Concepts" otherwise="/login.htm" redirect="/module/drughistory/regimen.form"/>

<openmrs:htmlInclude file="/scripts/dojo/dojo.js" />
<openmrs:htmlInclude file="/dwr/util.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRConceptService.js" />

<openmrs:htmlInclude file="/scripts/jquery/autocomplete/OpenmrsAutoComplete.js" />

<style>
    #addDrugError { margin-bottom: 0.5em; border: 1px dashed black; background: #FAA; line-height: 2em; text-align: center; display: none; }
</style>

<script>

    (function( $ ) {
        // Added for selectFirst to work (as its not availble in jquery-ui.1.8.2).
        $( ".ui-autocomplete-input" ).live( "autocompleteopen", function() {
            var autocomplete = $( this ).data( "autocomplete" ),
                    menu = autocomplete.menu;
            menu.activate( $.Event({ type: "mouseenter" }), menu.element.children().first() ); // Activates the mouseenter event, over the first element in menu
        });
    }( jQuery ));

    $j(document).ready(function(){
        // create the Add Drug dialog
        $j('#addDrug').dialog({
            autoOpen: false,
            modal: true,
            title: '<spring:message code="Concept.find" javaScriptEscape="true"/>',
            width: 'auto',
            open: function() {
                $j("#newDrug").val("");
                $j("input[name=newDrugId]").val(""); },
            close: function() {
                $j("#addDrugError").hide();
                $j("#newDrug").autocomplete("close"); },
            buttons: { '<spring:message code="general.add"/>': function() { handleAddDrug(); },
                '<spring:message code="general.cancel"/>': function() { $j(this).dialog("close"); }
            }
        });

        // concept drug autocompletes
        var callback = new CreateCallback({includeClasses:["Drug"]}).conceptCallback();

        var autoAddDrug = new AutoComplete("newDrug", callback, {
            select: function(event, ui) {
                $j("input[name=newDrugId]").val(ui.item.object.conceptId);
            }
        });
    });

    function addDrug() {
        $j('#addDrug').dialog('open');
    }

    function handleNewDrugObject(newDrug) {
        var nameListBox = document.getElementById("drugNames");
        var idListBox = document.getElementById("drugIds");
        var options = nameListBox.options;
        addOption(newDrug, options);
        copyIds(nameListBox.id, idListBox.id, ' ');
        $j("#addDrug").dialog('close');
    }

    function handleAddDrug() {
        var newDrugId = $j("input[name=newDrugId]").val();
        if (newDrugId == "") {
            $j("#addDrugError").show('highlight', 1000);
            return;
        }
        DWRConceptService.getConcept(newDrugId, handleNewDrugObject);
    }

    // functions below stolen from conceptForm.js

    function listKeyPress(from, to, delim, event) {
        var keyCode = event.keyCode;
        if (keyCode == 8 || keyCode == 46) {
            removeItem(from, to, delim);
            window.Event.keyCode = 0;	//attempt to prevent backspace key (#8) from going back in browser
        }
    }

    function addOption(obj, options) {
        var objId = obj.conceptId;
        var objName =  (obj.drugId != null ? obj.fullName : obj.name) + ' ('+objId+')';

        if (obj.drugId != null) //if obj is actually a drug object
            objId = objId + "^" + obj.drugId;

        if (isAddable(objId, options)==true) {
            var opt = new Option(objName, objId);
            opt.selected = true;
            options[options.length] = opt;
        }
    }

    function isAddable(value, options) {
        for (x=0; x<options.length; x++)
            if (options[x].value == value)
                return false;

        return true;
    }

    function copyIds(from, to, delimiter)
    {
        var sel = document.getElementById(from);
        var input = document.getElementById(to);
        var optList = sel.options;
        var remaining = new Array();
        var i=0;
        while (i < optList.length)
        {
            remaining.push(optList[i].value);
            i++;
        }
        input.value = remaining.join(delimiter);
    }

    function removeItem(nameList, idList, delim)
    {
        var sel   = document.getElementById(nameList);
        var input = document.getElementById(idList);
        var optList   = sel.options;
        var lastIndex = -1;
        var i = 0;
        while (i<optList.length) {
            // loop over and erase all selected items
            if (optList[i].selected) {
                optList[i] = null;
                lastIndex = i;
            }
            else {
                i++;
            }
        }
        copyIds(nameList, idList, delim);
        while (lastIndex >= optList.length)
            lastIndex = lastIndex - 1;
        if (lastIndex >= 0) {
            optList[lastIndex].selected = true;
            return optList[lastIndex];
        }
        return null;
    }

</script>

<%@ include file="template/localHeader.jsp" %>

<c:if test="${empty regimen.id}">
    <h2>Add ART Regimen</h2>
</c:if>

<c:if test="${not empty regimen.id}">
    <h2>Edit ART Regimen</h2>
</c:if>

<spring:hasBindErrors name="regimen">
    <spring:message code="fix.error"/>
    <br />
</spring:hasBindErrors>

<form method="post">
    <fieldset>
        <table>
            <tr>
                <td><spring:message code="general.name"/></td>
                <td>
                    <spring:bind path="regimen.name">
                        <input type="text" name="name" value="${status.value}" size="35" />
                        <c:if test="${status.errorMessage != ''}"><c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if></c:if>
                    </spring:bind>
                </td>
            </tr>
            <tr>
                <td valign="top"><spring:message code="general.description"/></td>
                <td valign="top">
                    <spring:bind path="regimen.description">
                        <textarea name="description" rows="3" cols="40" onkeypress="return forceMaxLength(this, 1024);" >${status.value}</textarea>
                        <c:if test="${status.errorMessage != ''}"><c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if></c:if>
                    </spring:bind>
                </td>
            </tr>
            <tr>
                <td valign="top">Line</td>
                <td valign="top">
                    <spring:bind path="regimen.line">
                        <select name="line">
                            <c:forEach var="l" items="${allLines}">
                                <option label="${l}" value="${l}" <c:if test="${status.value == l}">selected="selected"</c:if>></option>
                            </c:forEach>
                        </select>
                        <c:if test="${status.errorMessage != ''}"><c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if></c:if>
                    </spring:bind>
                </td>
            </tr>
            <tr>
                <td valign="top">Age Group</td>
                <td valign="top">
                    <spring:bind path="regimen.age">
                        <select name="age">
                            <c:forEach var="l" items="${allAges}">
                                <option label="${l}" value="${l}" <c:if test="${status.value == l}">selected="selected"</c:if>></option>
                            </c:forEach>
                        </select>
                        <c:if test="${status.errorMessage != ''}"><c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if></c:if>
                    </spring:bind>
                </td>
            </tr>
            <tr>
                <td valign="top">Regimen Drugs</td>
                <td valign="top">
                    <spring:bind path="regimen.drugs">
                        <input type="hidden" name="${status.expression}" id="drugIds" size="40" value='<c:forEach items="${regimen.drugs}" var="drug">${drug.conceptId} </c:forEach>' />
                        <c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if>
                    </spring:bind>
                    <table cellspacing="0" cellpadding="0">
                        <tr>
                            <td valign="top">
                                <select class="largeWidth" size="6" id="drugNames" multiple="multiple" onKeyUp="listKeyPress('drugNames', 'drugIds', ' ', event)">
                                    <c:forEach items="${regimen.drugs}" var="drug">
                                        <option value="<c:out value="${drug.conceptId}" />"><c:out value="${drug.name}" /> (${drug.conceptId})</option>
                                    </c:forEach>
                                </select>
                            </td>
                            <td valign="top" class="buttons">
                                <input type="button" value="<spring:message code="general.add"/>" class="smallButton" onClick="addDrug();"/><br/>
                                <input type="button" value="<spring:message code="general.remove"/>" class="smallButton" onClick="removeItem('drugNames', 'drugIds', ' ');"/>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <c:if test="${!(regimen.creator == null)}">
                <tr>
                    <td><spring:message code="general.createdBy" /></td>
                    <td>
                        ${regimen.creator.personName} -
                        <openmrs:formatDate date="${regimen.dateCreated}" type="long" />
                    </td>
                </tr>
            </c:if>
            <c:if test="${!(regimen.changedBy == null)}">
                <tr>
                    <td><spring:message code="general.changedBy" /></td>
                    <td>
                        ${regimen.changedBy.personName} -
                        <openmrs:formatDate date="${regimen.dateChanged}" type="long" />
                    </td>
                </tr>
            </c:if>
        </table>
        <br />

        <input type="submit" value="<spring:message code="general.save"/>" name="save">

    </fieldset>
</form>

<br/>

<c:if test="${not regimen.retired && not empty regimen.id}">
    <form method="post">
        <fieldset>
            <h4><spring:message code="general.retire"/></h4>

            <b><spring:message code="general.reason"/></b>
            <input type="text" value="" size="40" name="retireReason" />
            <spring:hasBindErrors name="regimen">
                <c:forEach items="${errors.allErrors}" var="error">
                    <c:if test="${error.code == 'retireReason'}"><span class="error"><spring:message code="${error.defaultMessage}" text="${error.defaultMessage}"/></span></c:if>
                </c:forEach>
            </spring:hasBindErrors>
            <br/>
            <input type="submit" value='<spring:message code="general.retire"/>' name="retire"/>
        </fieldset>
    </form>
</c:if>

<c:if test="${regimen.retired && not empty regimen.id}">
    <form method="post">
        <fieldset>
            <h4><spring:message code="general.unretire"/></h4>
            <br/>
            <input type="submit" value='<spring:message code="general.unretire"/>' name="unretire"/>
        </fieldset>
    </form>
</c:if>

<br/>

<c:if test="${not empty regimen.id}">
    <form id="purge" method="post" onsubmit="return confirmPurge()">
        <fieldset>
            <h4><spring:message code="general.purge"/></h4>
            <input type="submit" value='<spring:message code="general.purge"/>' name="purge" />
        </fieldset>
    </form>
</c:if>

<div id="addDrug" style="display: none">
    <div id="addDrugError"><spring:message code="Concept.noConceptSelected"/></div>
    <input type="text" name="newDrug" id="newDrug" size="20"/>
    <input type="hidden" name="newDrugId" id="newDrugId"/>
</div>

<%@ include file="/WEB-INF/template/footer.jsp" %>
