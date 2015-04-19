<%
    ui.decorateWith("appui", "standardEmrPage")

    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("uicommons", "angular-ui/ui-bootstrap-tpls-0.6.0.min.js")
    ui.includeJavascript("reportingui", "reportHistory.js")

    def interactiveClass = context.loadClass("org.openmrs.module.reporting.report.renderer.InteractiveReportRenderer")
    def isInteractive = {
        interactiveClass.isInstance(it.renderer)
    }
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.message("reportingui.reportHistory.title") }", link: "${ ui.escapeJs(ui.thisUrl()) }" }
    ];

    var highlight = <%= param.request ? """ "${ ui.escapeJs(param.request[0])}" """ : "null" %>
</script>

<div ng-app="reportHistoryApp" ng-controller="ReportHistoryController" ng-init="refreshHistory()">

    <fieldset ng-show="queue" class="report-list">
        <legend>${ ui.message("reportingui.runReport.queue.legend") }</legend>
        <table>
            <thead>
            <tr>
                <th></th>
                <th>${ ui.message("reportingui.reportRequest.status") }</th>
                <th>${ ui.message("reportingui.reportRequest.parameters") }</th>
                <th>${ ui.message("reportingui.reportRequest.requested") }</th>
                <th>${ ui.message("reportingui.reportRequest.actions") }</th>
            </tr>
            </thead>
            <tbody>
            <tr ng-repeat="request in queue" ng-class="{ selected: request.uuid == highlight }">
                <td>
                    {{ request.reportDefinition.name }}
                </td>
                <td>
                    <img class="right small" ng-show="request.status=='PROCESSING'" src="${ ui.resourceLink("uicommons", "images/spinner.gif") }"/>
                    {{request.status | translate:'reportingui.reportRequest.Status.'}}
                    <span ng-show="request.status=='REQUESTED'">
                        <br/>
                        ${ ui.message("reportingui.reportRequest.priority") }: {{request.priority | translate:'reportingui.ReportRequest.Priority.'}} <br/>
                        ${ ui.message("reportingui.reportRequest.position") }: {{request.positionInQueue}}
                    </span>
                    <span ng-hide="request.status=='REQUESTED'">
                        <br/>
                        {{request.evaluateCompleteDatetime}}
                    </span>
                </td>
                <td>
                    <span ng-repeat="param in request.reportDefinition.mappings">
                        {{ param.value }} <br/>
                    </span>
                </td>
                <td>
                    {{request.requestedBy}} <br/>
                    {{request.requestDate}}
                </td>
                <td>
                    <a ng-show="request.status=='REQUESTED'" ng-click="cancelRequest(request)">
                        <i class="small icon-remove"></i>
                        ${ ui.message("emr.cancel") }
                    </a>
                </td>
            </tr>
            </tbody>
        </table>
    </fieldset>

    <fieldset class="report-list">
        <legend>${ ui.message("reportingui.runReport.completed.legend") }</legend>

        <span ng-show="loading" ng-bind="${ ui.escapeAttribute(ui.message("uicommons.loading.placeholder") + " <img src=\"" + ui.resourceLink("uicommons", "images/spinner.gif") + "\"/>") }"></span>

        <span ng-show="hasNoResults()" ng-bind="${ ui.escapeAttribute(ui.message("emr.none")) }"></span>

        <table ng-show="hasResults()">
            <thead>
            <tr>
                <th></th>
                <th>${ ui.message("reportingui.reportRequest.status") }</th>
                <th>${ ui.message("reportingui.reportRequest.parameters") }</th>
                <th>${ ui.message("reportingui.reportRequest.requested") }</th>
                <th>${ ui.message("reportingui.reportRequest.actions") }</th>
            </tr>
            </thead>
            <tbody>
            <tr ng-repeat="request in completed" ng-class="{ selected: request.uuid == highlight }">
                <td>
                    {{ request.reportDefinition.name }}
                </td>
                <td>
                    <a ng-click="viewStatus(request)">
                        {{request.status | translate:'reportingui.reportRequest.Status.'}} <br/>
                        {{request.evaluateCompleteDatetime}}
                    </a>
                </td>
                <td>
                    <span ng-repeat="param in request.reportDefinition.mappings">
                        {{ param.value }} <br/>
                    </span>
                </td>
                <td>
                    {{request.requestedBy}} <br/>
                    {{request.requestDate}}
                </td>
                <td>
                    <span class="download" ng-show="request.status == 'COMPLETED' || request.status == 'SAVED'">
                        <a href="${ ui.pageLink("reportingui", "viewReportRequest") }?request={{ request.uuid }}">
                            <span ng-show="request.renderingMode.interactive">
                                <i class="icon-eye-open small"></i>
                                ${ ui.message("reportingui.reportHistory.open") }
                            </span>
                            <span ng-hide="request.renderingMode.interactive">
                                <i class="icon-download small"></i>
                                ${ ui.message("uicommons.downloadButtonLabel") }
                            </span>
                        </a>
                        <br/>
                        <a ng-show="canSave(request)" ng-click="saveRequest(request)">
                            <i class="icon-save small"></i>
                            ${ ui.message("reportingui.reportRequest.save.action") }
                        </a>
                    </span>
                    <span ng-show="request.errorMessage">
                        <a popover="{{ request.errorMessage }}" popover-placement="bottom">
                            Error details
                        </a>
                    </span>
                    <span>

                    </span>
                </td>
            </tr>
            </tbody>
        </table>
    </fieldset>

</div>