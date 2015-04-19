<div class="modal-header">${ ui.message('reportingui.adHocReport.modal.header') }</div>

<div class="modal-body">
    <div class="modal-definition">
        <p class="modal-definition-name"> {{ definition.name }} </p>
        <p ng-bind-html="definition.description | insertParameterNames:definition.parameters:dataExport.parameters"></p>
    </div>
    <div class="modal-params">
        <div ng-repeat="param in definition.parameters | filter:paramFilter">
            <label>{{ param.label | omrs.display }}</label>
            <span ng-include="'paramWidget/' + param.type + '.page?collectionType=' + param.collectionType"/>
        </div>
    </div>
</div>

<div class="modal-footer">
    <p class="button-left"><button class="cancel-button" ng-click="cancel()">${ ui.message('reportingui.adHocReport.modal.cancel') }</button></p>
    <p class="button-right"><button class="add-button" ng-click="ok()">${ ui.message('reportingui.adHocReport.modal.add') }</button></p>
</div>
