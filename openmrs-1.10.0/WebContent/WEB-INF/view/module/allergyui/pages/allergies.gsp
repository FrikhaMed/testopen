<%
    ui.decorateWith("appui", "standardEmrPage")
%>
<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.format(patient.familyName) }, ${ ui.format(patient.givenName) }" , link: '${ui.pageLink("coreapps", "clinicianfacing/patient", [patientId: patient.id])}'},
        { label: "${ ui.message("allergyui.allergies") }" }
    ];
    
    var patient = { id: ${ patient.id } };
</script>

${ ui.includeFragment("coreapps", "patientHeader", [ patient: patient ]) }

<% ui.includeJavascript("allergyui", "allergies.js") %>

${ ui.includeFragment("uicommons", "infoAndErrorMessage")}
<h2>
	${ ui.message("allergyui.allergies") }
</h2>

<table id="allergies" width="100%" border="1" cellspacing="0" cellpadding="2">
    <thead>
	    <tr>
	        <th>${ ui.message("allergyui.allergen") }</th>
	        <th>${ ui.message("allergyui.reaction") }</th>
	        <th>${ ui.message("allergyui.severity") }</th>
	        <th>${ ui.message("allergyui.comment") }</th>
	        <th>${ ui.message("allergyui.lastUpdated") }</th>
	        <th>${ ui.message("coreapps.actions") }</th>
	    </tr>
    </thead>
    
    <tbody>
    	<% if (allergies.size() == 0) { %>
            <tr>
                <td colspan="6" align="center">
                <% if (allergies.allergyStatus != "No known allergies") { %>
                    ${ allergies.allergyStatus }
                <% } else { %>
                    <form method="POST">
                        ${ allergies.allergyStatus }
                        <input type="hidden" name="patientId" value="${patient.id}"/>
                        <input type="hidden" name="action" value="deactivate"/>
                        <button class="small" type="submit">${ ui.message("allergyui.deactivate") }</button>
                    </form>
                <% } %>
                </td>
            </tr>
        <% } %>
        
        <% allergies.each { allergy -> %>
            <tr>
                <td> ${ allergy.allergen } </td>
                <td> 
                	<% allergy.reactions.eachWithIndex { reaction, index -> %>
	               		<% if (index > 0) { %>,<% } %> ${reaction}	
	                <% } %>
                </td>
                <td> ${ allergy.severity.name } </td>
                <td> ${ allergy.comment } </td>
                <td> ${ ui.formatDatetimePretty(allergy.dateLastUpdated) } </td>
                <td>
                	<i class="icon-pencil edit-action" title="${ ui.message("coreapps.edit") }"></i>
                	<i class="icon-remove delete-action" title="${ ui.message("coreapps.delete") }"></i>
                </td>
            </tr>
        <% } %>
    </tbody>
</table>

<br/>

<button class="confirm">
    ${ ui.message("allergyui.addNewAllergy") }
</button>

<button id="allergyui-confirm-no-known-allergy" class="confirm" style="float:right; <% if (allergies.allergyStatus != "Unknown") { %> display:none; <% } %>"
    onclick="showConfirmNoKnownAllergyDialog()">
    ${ ui.message("allergyui.noKnownAllergy") }
</button>


<%/* DIALOGS */%>
<div id="allergyui-confirm-no-known-allergy-dialog" class="dialog" style="display: none">
    <div class="dialog-header">
        <h3>${ ui.message("allergyui.noKnownAllergy") }</h3>
    </div>
    <div class="dialog-content">
        <ul>
            <li class="info">
                <span>${ ui.message("allergyui.noKnownAllergy.message") }</span>
            </li>
        </ul>
        <form method="POST">
            <input type="hidden" name="patientId" value="${patient.id}"/>
            <input type="hidden" name="action" value="confirmNoKnownAllergies"/>
            <button class="confirm right" type="submit">${ ui.message("general.yes") }</button>
            <button class="cancel">${ ui.message("general.no") }</button>
        </form>
    </div>
</div>