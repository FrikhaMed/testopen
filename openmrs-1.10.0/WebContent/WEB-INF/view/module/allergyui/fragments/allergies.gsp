<div class="info-section allergies">
    <div class="info-header" onclick="location.href='${ui.pageLink("allergyui", "allergies", [patientId: patient.patient.id])}';" style="cursor: pointer;">
        <i class="icon-medical"></i>
        <h3>${ ui.message("allergyui.allergies").toUpperCase() }</h3>
    </div>
    <div class="info-body">
        <% if (allergies.allergyStatus != "See list") { %>
			 ${ ui.message(allergies.allergyStatus) }
		<% } else { %>
        <ul>
            <% allergies.each { allergy -> %>
	            <li style="display: inline-block; font-size: 0.8em;">
	            	${ allergy.allergen } =>
	            	<% allergy.reactions.eachWithIndex { reaction, index -> %>
	               		<% if (index > 0) { %>,<% } %> ${reaction}	(${ allergy.severity.name })
	                <% } %>
	            </li>
            <% } %>
        </ul>
		<% } %>
    </div>
</div>