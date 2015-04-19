<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "moment.min.js")
    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeCss("reportingui", "adHocReport.css")
    ui.includeJavascript("uicommons", "angular-ui/ui-bootstrap-tpls-0.6.0.min.js")

    def patientDataExports = exports.findAll { it.type == "PatientDataSetDefinition" }
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.escapeJs(ui.message("reportingui.adHocAnalysis.label")) }", link: "${ ui.escapeJs(ui.thisUrl()) }" }
    ];

    jq(function() {
        jq('.purge-ad-hoc-definition').click(function(event) {
            var uuid = jq(event.target).closest('.purge-ad-hoc-definition').data('uuid');
            var dialog = emr.setupConfirmationDialog({
                selector: '#dialog-confirm',
                actions: {
                    confirm: function() {
                        jq.ajax('/' + OPENMRS_CONTEXT_PATH + '/ws/rest/v1/reportingrest/adhocdataset/' + uuid + '?purge=true', {
                            type: 'DELETE',
                            dataType: 'json',
                            success: function(data, status, xhr) {
                                console.log(data);
                                console.log(status);
                                console.log(xhr);
                                location.href = location.href;
                            },
                            error: function(xhr) {
                                emr.handleError(xhr);
                                dialog.close();
                            }
                        });
                    },
                    cancel: function() {
                        dialog.close();
                    }
                }
            });
            dialog.show();
        });
    });
</script>

<h1>${ ui.message("reportingui.adHocManage.title") }</h1>

<div class="report-header">
    <h3>${ ui.message("reportingui.adHocManage.group.title.org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition") }</h3>

    <a class="button confirm" href="${ui.pageLink("reportingui", "adHocAnalysis", [ definitionClass: "org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition" ]) }">
        <i class="icon-plus"></i>
        ${ ui.message("reportingui.adHocManage.new") }
    </a>
</div>

<table class="manage-adhoc-reports">
    <thead>
        <tr>
            <th>${ ui.message("reportingui.adHocReport.name") }</th>
            <th>${ ui.message("reportingui.adHocReport.description") }</th>
            <th>${ ui.message("reportingui.adHocManage.actions") }</th>
        </tr>
    </thead>
    <tbody>
    <% if (patientDataExports.size() == 0) { %>
        <tr>
            <td colspan="3">${ ui.message("emr.none") }</td>
        </tr>
    <% } %>
    <% patientDataExports.each { %>
        <tr>
            <td>${ it.name }</td>
            <td>${ it.description ?: "" }</td>
            <td>
                <a href="adHocRun.page?dataset=${ it.uuid }"><i class="icon-play small"></i></a>
                <a href="adHocAnalysis.page?definition=${ it.uuid }"><i class="icon-pencil small"></i></a>
                <a class="purge-ad-hoc-definition" data-uuid="${ it.uuid }"><i class="icon-remove-sign"></i></a>
            </td>
        </tr>
    <% } %>
    </tbody>
</table>

<div class="dialog" id="dialog-confirm" style="display: none">
    <div class="dialog-header">
        ${ ui.escapeAttribute(ui.message("reportingui.adHocManage.confirmDeleteTitle")) }
    </div>
    <div class="dialog-content">
        <p>
            ${ ui.message("reportingui.adHocManage.confirmDeleteMessage") }
        </p>

        <div>
            <button class="button confirm right">${ ui.message("emr.delete") }</button>
            <button class="button cancel">${ ui.message("emr.cancel") }</button>
        </div>
    </div>
</div>