<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "moment.min.js")
    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("uicommons", "angular-ui/ui-bootstrap-tpls-0.6.0.min.js")
    ui.includeJavascript("reportingui", "adHocRun.js")
%>

<%= ui.includeFragment("appui", "messages", [ codes: [
        "reportingui.adHocReport.timeframe.startDateLabel",
        "reportingui.adHocReport.timeframe.endDateLabel",
        "reportingui.parameter.type.java.util.Date",
        "reportingui.parameter.type.org.openmrs.VisitType",
        "reportingui.parameter.type.org.openmrs.Location",
        "reportingui.parameter.type.org.openmrs.EncounterType"

].flatten()
]) %>

<script type="text/javascript">
    var adHocExports = ${ ui.toJson(exports) };

    var initialSelection = [ <%= selected.collect { "\"${ ui.escapeJs(it) }\"" }.join(", ") %> ];

    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.escapeJs(ui.message("reportingui.adHocAnalysis.label")) }", link: emr.pageLink("reportingui", "adHocManage") },
        { label: "${ ui.escapeJs(ui.message("reportingui.adHocRun.label")) }", link: "${ ui.escapeJs(ui.thisUrl()) }" }
    ];
</script>

<div id="run-ad-hoc" ng-app="runAdHocExport" ng-controller="RunAdHocExportController">

    <h1>${ ui.message("reportingui.adHocRun.label") }</h1>

    <span ng-hide="exports">
        ${ ui.message("reportingui.adHocRun.noneAvailable") }
    </span>

    <div ng-show="exports">
        <form>
            <p>
                <label>${ ui.message("reportingui.adHocRun.dataSets") }</label>
                <ul>
                    <li ng-repeat="export in exports">
                        <input type="checkbox" name="dataset" ng-model="export.selected" id="export-{{\$index}}"/>
                        <label for="export-{{\$index}}">
                            {{ export.name }} <em>{{ export.description }}</em>
                        </label>
                    </li>
                </ul>
            </p>

            <p ng-repeat="param in requiredParameters()">
                <label>{{ param.label | translate }}</label>
                <span ng-include="'paramWidget/' + param.type + '.page'"/>
            </p>

            <p>
                <label for="output-format">${ ui.message("reportingui.reportRequest.outputFormat") }</label>
                <select id="output-format" ng-model="outputFormat">
                    <option value="org.openmrs.module.reporting.report.renderer.CsvReportRenderer">CSV</option>
                    <option value="org.openmrs.module.reporting.report.renderer.XlsReportRenderer">Excel</option>
                </select>
            </p>

            <button class=".confirm" ng-click="run()" ng-disabled="!canRun()">
                <i class="icon-play"></i>
                ${ ui.message("reportingui.adHocRun.runButton") }
            </button>
        </form>
    </div>
</div>