<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeCss("reportingui", "reportsapp/home.css")

    def appFrameworkService = context.getService(context.loadClass("org.openmrs.module.appframework.service.AppFrameworkService"))
    def overviews = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.reportingui.reports.overview")
    def dataQualityReports = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.reportingui.reports.dataquality")
    def dataExports = appFrameworkService.getExtensionsForCurrentUser("org.openmrs.module.reportingui.reports.dataexport")

    def contextModel = [:]
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("reportingui.reportsapp.home.title") }", link: "${ ui.pageLink("reportingui", "reportsapp/home") }" }
    ];
</script>


<div class="reportBox">
    <% if (overviews) { %>
        <p>${ ui.message("reportingui.reportsapp.overviewReports") }</p>
        <ul>
            <% overviews.each { %>
                <li>
                    ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
                </li>
            <% } %>
        </ul>
    <% } %>

    <% if (dataQualityReports) { %>
        <p>${ ui.message("reportingui.reportsapp.dataQualityReports") }</p>
        <ul>
            <% dataQualityReports.each { %>
                <li>
                    ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
                </li>
            <% } %>
        </ul>
    <% } %>
</div>

<div class="reportBox">
    <% if (dataExports) { %>
        <p>${ ui.message("reportingui.reportsapp.dataExports") }</p>
        <ul>
            <% dataExports.each { %>
            <li>
                ${ ui.includeFragment("uicommons", "extension", [ extension: it, contextModel: contextModel ]) }
            </li>
            <% } %>
        </ul>
    <% } %>
</div>