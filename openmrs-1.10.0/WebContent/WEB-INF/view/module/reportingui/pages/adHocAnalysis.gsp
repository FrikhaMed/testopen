<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "moment.min.js")
    ui.includeJavascript("uicommons", "angular.js")
    ui.includeJavascript("uicommons", "angular-resource.min.js")
    ui.includeJavascript("uicommons", "angular-sanitize.min.js")
    ui.includeJavascript("uicommons", "angular-app.js")
    ui.includeJavascript("uicommons", "filters/display.js")
    ui.includeJavascript("uicommons", "services/encounterTypeService.js")
    ui.includeJavascript("uicommons", "services/locationService.js")

    ui.includeJavascript("reportingui", "app.js")
    ui.includeJavascript("reportingui", "adHocAnalysis.js")
    ui.includeJavascript("uicommons", "angular-ui/ui-bootstrap-tpls-0.6.0.min.js")
    ui.includeCss("reportingui", "adHocReport.css")

    ui.includeJavascript("reportingui", "directives/encounterTypeWidget.js")
    ui.includeJavascript("reportingui", "directives/locationWidget.js")

    def jsString = {
        it ? """ "${ ui.escapeJs(it) }" """ : "null"
    }
%>

<%= ui.includeFragment("appui", "messages", [ codes: [
        "reportingui.adHocReport.timeframe.startDateLabel",
        "reportingui.adHocReport.timeframe.endDateLabel",
        "reportingui.parameter.type.java.util.Date",
        "reportingui.parameter.type.org.openmrs.VisitType",
        "reportingui.parameter.type.org.openmrs.Location",
        "reportingui.parameter.type.org.openmrs.EncounterType",
        context.encounterService.allEncounterTypes.collect { "ui.i18n.EncounterType.name." + it.uuid }
].flatten()
]) %>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.message("reportingui.reportsapp.home.title")) }", link: emr.pageLink("reportingui", "reportsapp/home") },
        { label: "${ ui.escapeJs(ui.message("reportingui.adHocAnalysis.label")) }", link: emr.pageLink("reportingui", "adHocManage") },
        { label: ${ jsString(definition.name ?: ui.message("reportingui.adHocReport.newLabel")) } }
    ];

    window.adHocDataExport = {
        type: "org.openmrs.module.reporting.dataset.definition.PatientDataSetDefinition",
        name: ${ jsString(definition.name) },
        description: ${ jsString(definition.description) },
        uuid: ${ jsString(definition.uuid) }
    };
    <% if (initialStateJson) { %>
        window.adHocDataExport.initialSetup = ${ initialStateJson };
    <% } %>
</script>

<div id="ad-hoc-report" class="ad-hoc-report" ng-app="reportingui" ng-controller="AdHocAnalysisController" ng-init="focusFirstElement()">

    <div class="summary">
        <span class="summary-parameter current" ng-click="changeStep('parameters')" data-step="parameters">
            <span>${ ui.message("reportingui.adHocReport.parameters.label") }: </span>
            {{ dataExport.parameters.length }}
        </span>

        <span class="summary-parameter" ng-click="changeStep('searches')" data-step="searches">
            <span>${ ui.message("reportingui.adHocReport.searches") }: </span>
            {{ dataExport.rowFilters.length }}
        </span>

        <span class="summary-parameter" ng-click="changeStep('columns')" data-step="columns">
            <span>${ ui.message("reportingui.adHocReport.columns") }: </span>
            {{ dataExport.columns.length }}
        </span>

        <span class="summary-parameter" ng-click="changeStep('preview')" data-step="preview">
            <span>${ ui.message("reportingui.adHocReport.preview") }</span>
        </span>

         <span class="summary-parameter" ng-click="changeStep('description')" data-step="description">
            <span>${ ui.message("reportingui.adHocReport.description.label") }</span>
        </span>
    </div>

    <div ng-controller="ModalCtrl" ng-include="adHocAnalysisParameterPopup.page"></div>

    <div id="parameters" class="step" ng-show="currentView == 'parameters'">
        <h2>${ ui.message("reportingui.adHocReport.parameters.label") }</h2>
        <div class="step-content">
            <ul>
                <li class="parameter" ng-repeat="parameter in dataExport.parameters">
                    {{ \$index + 1 }}.
                    {{ parameter.label | omrs.display }}:
                    <span ng-show="parameter.collectionType">{{ parameter.collectionType }} of </span>
                    {{ parameter.type | omrs.display:'reportingui.parameter.type.'}}
                </li>
            </ul>
        </div>
        <div class="navigation">
            <button class="focus-first" ng-click="next()">${ ui.message("reportingui.adHocReport.next") }</button>
        </div>
    </div>

    <div id="searches" class="step" ng-show="currentView == 'searches'">
        <h2>${ ui.message("reportingui.adHocReport.searchCriteria")}</h2>
        <span>${ ui.message("reportingui.adHocReport.searchCriteria.description") }</span>

        <div>
            <ul>
                <div class="ul-header">
                    <input type="text" class="focus-first" id="row-search" placeholder="${ ui.message('reportingui.adHocReport.searchCriteria.filter.placeholder') }" ng-model="searchcriteria" />
                </div>
                <li ng-click="addRow(criteria)" ng-repeat="criteria in availableSearches() | filter:searchcriteria" class="option">
                    <span>{{ criteria.name }}</span>
                    <small class="definition-description" ng-bind-html="criteria.description | insertParameterNames:criteria.parameters:dataExport.parameters"></small>
                </li>
            </ul>
            <i class="icon-chevron-right"></i>
            <ul>
                <div ng-show="dataExport.rowFilters.length > 0" class="ul-header selected" id="searches-header">
                    <span ng-hide="editingCombination">
                        <span ng-hide="dataExport.customRowFilterCombination">${ ui.message("reportingui.adHocReport.searchCriteria.combination") }</span>
                        <span ng-show="dataExport.customRowFilterCombination">${ ui.message("reportingui.adHocReport.searchCriteria.customRowFilterCombination") }</span>
                        <i ng-click="editCombination()" class="icon-edit small" id="edit-button"></i>
                    </span>
                    <span ng-show="editingCombination">
                        ${ ui.message("reportingui.adHocReport.searchCriteria.combination.edit") }:
                        <input type="text" id="custom-combination" placeholder="${ ui.message('reportingui.adHocReport.searchCriteria.combination.example') }"/>
                        <button class="button right" ng-click="applyEditCombination()">${ ui.message("uicommons.apply") }</button>
                        <button class="button cancel" ng-click="cancelEditCombination()">${ ui.message("uicommons.cancel") }</button>
                    </span>
                </div>
                <li class="item" ng-repeat="rowQuery in dataExport.rowFilters">
                    <label>{{ \$index + 1 }}.</label>
                    <span class="definition-name">
                        {{ rowQuery.name }}
                    </span>
                    <span class="actions">
                        <i ng-click="removeRow(\$index)"class="icon-remove small"></i>
                    </span>
                    <span class="definition-param" ng-repeat="param in rowQuery.parameters" ng-hide="isParameterGloballySet(param)">
                        {{ param.name }}: {{ rowQuery.parameterValues[param.name] | omrs.display }}
                    </span>
                </li>
            </ul>
        </div>

        <div class="navigation">
            <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
            <button ng-click="next()">${ ui.message("reportingui.adHocReport.next") }</button>
        </div>
    </div>

    <div id="columns" class="step"  ng-show="currentView == 'columns'">
        <h2>${ ui.message("reportingui.adHocReport.columns") }</h2>
        <span>${ ui.message("reportingui.adHocReport.columns.description") }</span>

        <div>
            <ul>
                <div class="ul-header">
                    <input type="text" class="focus-first" id="column-search" placeholder="${ ui.message('reportingui.adHocReport.columns.filter.placeholder') }" ng-model="columns" />
                </div>
                <li ng-click="addColumn(column)" ng-repeat="column in getColumns() | filter:columns" class="option">
                    <span>{{ column.name }}</span>
                    <small class="definition-description">{{ column.description | insertParameterNames:column.parameters:dataExport.parameters }}</small>
                </li>
            </ul>
            <i class="icon-chevron-right"></i>
            <ul>
                <div ng-show="dataExport.columns.length > 0" class="ul-header selected"><strong>{{ dataExport.columns.length }} </strong>selected columns</div>
                <li ng-repeat="col in dataExport.columns" class="item">
                    <label>
                        {{ \$index + 1 }}.
                    </label>
                    {{ col.name }}

                    <span class="actions">
                        <i ng-click="removeColumn(\$index)" class="icon-remove small"></i>
                        <i ng-hide="\$first" ng-click="moveColumnUp(\$index)" class="icon-chevron-up small"></i>
                        <i ng-hide="\$last" ng-click="moveColumnDown(\$index)"class="icon-chevron-down small"></i>
                    </span>
                    <span class="definition-param" ng-repeat="param in col.parameters" ng-hide="isParameterGloballySet(param)">
                        {{ param.name }}: {{ col.parameterValues[param.name] | omrs.display }}
                    </span>
                </li>
            </ul>
        </div>

        <div class="navigation">
            <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
            <button ng-click="next()">${ ui.message("reportingui.adHocReport.next") }</button>
        </div>
    </div>

    <div class="step" ng-show="currentView == 'preview'">
        <h2>${ ui.message("reportingui.adHocReport.preview") }</h2>

        <div class="step-content">
            <span class="angular-datepicker">
                <div class="form-horizontal">
                    <label>{{ dataExport.parameters[0].label | omrs.display }}</label>
                    <input type="text" class="datepicker-input" datepicker-popup="dd-MMMM-yyyy" ng-model="dataExport.parameters[0].value" is-open="isStartDatePickerOpen" max="maxDay" date-disabled="disabled(date, mode)" ng-required="true" show-weeks="false" placeholder="${ ui.message('reportingui.adHocReport.timeframe.startDateLabel')}" />
                    <i class="icon-calendar btn small" ng-click="openStartDatePicker()"></i>
                </div>
            </span>

            <span class="angular-datepicker">
                <div class="form-horizontal">
                    <label>{{ dataExport.parameters[1].label | omrs.display }}</label>
                    <input type="text" class="datepicker-input" datepicker-popup="dd-MMMM-yyyy" ng-model="dataExport.parameters[1].value" is-open="isEndDatePickerOpen" min="dataExport.parameters[0].value" max="maxDay" date-disabled="disabled(date, mode)" ng-required="true" show-weeks="false" placeholder="${ ui.message('reportingui.adHocReport.timeframe.endDateLabel')}" />
                    <i ng-click="openEndDatePicker()" class="icon-calendar btn small"></i>
                </div>
            </span>

            <img ng-show="results.loading" src="${ ui.resourceLink("uicommons", "images/spinner.gif") }"/>
            <div class="no-results" ng-show="results.rows.length == 0">
                <div class="no-results-message">${ ui.message("reportingui.adHocReport.noResults") }</div>
            </div>
            <div class="big-table" ng-show="results.rows">
                <span>${ ui.message("reportingui.adHocReport.preview.description") }</span>
                <table ng-show="results.rows.length > 0">
                    <thead>
                        <tr>
                            <th></th>
                            <th ng-repeat="col in results.metadata.columns">{{ col.label }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr ng-repeat="row in results.rows">
                            <td>{{ \$index + 1 }}</td>
                            <td ng-repeat="col in row">{{ col }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="navigation">
                <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
                <button ng-click="next()" class="focus-first">${ ui.message("reportingui.adHocReport.next") }</button>
            </div>
        </div>
    </div>

    <div id="description" class="step" ng-show="currentView == 'description'">
        <h2>${ ui.message("reportingui.adHocReport.description.label") }</h2>
        <div class="step-content">
            <p>
                <label>${ ui.message("reportingui.adHocReport.name") }</label>
                <input ng-model="dataExport.name" ng-change="dirty = true"/>
            </p>
            <p>
                <label>${ ui.message("reportingui.adHocReport.description") }</label>
                <textarea ng-model="dataExport.description" ng-change="dirty = true" cols="40" rows="4"></textarea>
            </p>
        </div>
        <div class="navigation">
            <button ng-click="back()">${ ui.message("reportingui.adHocReport.back") }</button>
            
            <span ng-show="dirty">        
                <button ng-click="saveDataExport()" ng-disabled="!canSave()">
                    <i class="icon-save"></i>
                    ${ ui.message("emr.save") }
                </button>
                <span ng-show="!canSave()">${ ui.message("reportingui.adHocReport.save.requirements") }</span>
            </span>
            <span ng-show="!dirty">
                <button ng-disabled="true">
                    <i class="icon-save"></i>
                    ${ ui.message("emr.save") }
                </button>
            </span>
            <span ng-hide="dirty">
                <em>${ ui.message("reportingui.adHocReport.save.success") }<em>
            </span>
            <div class="link" ng-hide="dirty">
                <a ng-click="runDataExport()">${ ui.message("reportingui.adHocReport.runLink") }</a>
            </div>
        </div>
    </div>
</div>
