window.adHocAnalysis = {
    queryPromises: {},
    queryResults: {},

    fetchData: function($http, target, type, afterSuccess) {
        var promise = $http.get(emr.fragmentActionLink('reportingui', 'definitionLibrary', 'getDefinitions', { type: type })).
            success(function(data, status, headers, config) {
                _.each(data, function(item) {
                    item.label = item.name + ' (' + item.description + ')';
                });
                target.queryResults[type] = data;
                if (afterSuccess) {
                    afterSuccess.call();
                }
            });
        target.queryPromises[type] = promise;
    }
}

angular.module('reportingui').

    filter('insertParameterNames', ['$filter', function($filter) {
        function escapeRegExp(string) {
            return string.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
        }

        function replaceAll(find, replace, str) {
            return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
        }

        return function(input, localParams, globalParams) {
            input = _.escape(input); // input is a raw description, which might include something like "<= $startDate"
            // first, global parameters
            _.each(globalParams, function(p) {
                input = replaceAll("{{" + p.name + "}}", "<em>" + $filter('omrs.display')(p.label) + "</em>", input);
            });
            // next, parameters specific to this filter/column
            _.each(localParams, function(p) {
                input = replaceAll("{{" + p.name + "}}", "<em>" + $filter('omrs.display')(p.label) + "</em>", input);
            })
            return input;
        }
    }]).

    directive('definitionsearch', function($compile) {
        // expect { type: ..., key: ..., name: ..., description: ..., parameters: [ ... ] }

        return function(scope, element, attrs) {
            var allowedParameters = _.pluck(scope.parameters, 'name');
            var onSelectAction = scope[attrs['action']];
            element.autocomplete({
                source: [ 'Loading...' ],
                select: function(event, ui) {
                    scope.$apply(function() {
                        onSelectAction(ui.item);
                    });
                    element.val('');
                    return false;
                },
                response: function(event, ui) {
                    var i = ui.content.length - 1;
                    while (i >= 0) {
                        var paramNames = _.pluck(ui.content[i].parameters, 'name');
                        var notAllowed = _.without(paramNames, allowedParameters);
                        if (notAllowed.length > 0) {
                            ui.content.splice(i, 1);
                        }
                        --i;
                    }
                },
                change: function(event, ui) {
                    element.val('');
                    return false;
                }
            });
            var definitionType = attrs['definitionType'];
            window.adHocAnalysis.queryPromises[definitionType].success(function() {
                element.autocomplete( "option", "source", window.adHocAnalysis.queryResults[definitionType] );
            });
        };
    }).

    controller('AdHocAnalysisController', ['$scope', '$http', '$timeout', '$filter', function($scope, $http, $timeout, $filter) {

        // ----- private helper functions ----------

        function swap(array, idx1, idx2) {
            if (idx1 < 0 || idx2 < 0 || idx1 >= array.length || idx2 >= array.length) {
                return;
            }
            var temp = array[idx1];
            array[idx1] = array[idx2];
            array[idx2] = temp;
        }

        function filterAvailable(allDefinitions, currentDefinitions) {
            return _.filter(allDefinitions, function(candidate) {
                // if this takes run-time parameters, the user is allowed to add it multiple times
                if ($scope.requiresExtraParameters(candidate)) {
                    return true;
                }
                // otherwise, skip anything we already have selected
                return ! _.findWhere(currentDefinitions, { key: candidate.key });
            });
        }

        function postJSON(url, dataObject) {
            return $http({
                method: 'POST',
                url: url,
                data: dataObject
            });
        }

        function post(url, dataObject) {
            return $http({
                method: 'POST',
                url: url,
                data: $.param(dataObject),
                headers: {'Content-Type': 'application/x-www-form-urlencoded'}
            });
        }

        function stripTimeFromParameters(dataExport) {
            var ret = angular.copy(dataExport);
            _.each(ret.parameters, function(it) {
                if (it.value instanceof Date) {
                    it.value = it.value.toISOString().slice(0,10);
                }
            });
            return ret;
        }

        function setDirty() {
            $scope.dirty = true;
        }

        function copyDefinitionWithParameterValues(definition, paramValues) {
            return $.extend(
                _.pick(definition, 'key', 'type', 'name', 'description', 'label', 'parameters'),
                { parameterValues: paramValues }
            );
        }

        // ----- Model ----------

        $scope.dataExport = window.adHocDataExport; // initialized in the gsp on page load

        var initialSetup = $scope.dataExport.initialSetup;
        delete $scope.dataExport.initialSetup;

        $scope.dirty = !window.adHocDataExport.uuid;

        $scope.editingCombination = false;

        $scope.dataExport.customRowFilterCombination = '';

        $scope.dataExport.parameters = [];

        $scope.dataExport.rowFilters = [];

        $scope.dataExport.columns = [];

        if (initialSetup) {
            $scope.dataExport.uuid = initialSetup.uuid;
            $scope.dataExport.name = initialSetup.name;
            $scope.dataExport.description = initialSetup.description;
            $scope.dataExport.parameters = initialSetup.parameters;
            _.each($scope.dataExport.parameters, function(item) {
                if (item.type == "java.util.Date") {
                    item.value = moment().startOf('day').toDate();
                }
            });
            $scope.dataExport.customRowFilterCombination = initialSetup.customRowFilterCombination;
        }
        else {
            $scope.dataExport.parameters = [
                {
                    name: "startDate",
                    label: "reportingui.adHocReport.timeframe.startDateLabel",
                    type: "java.util.Date",
                    collectionType: null,
                    value: moment().startOf('day').toDate()
                },
                {
                    name: "endDate",
                    label: "reportingui.adHocReport.timeframe.endDateLabel",
                    type: "java.util.Date",
                    collectionType: null,
                    value: moment().startOf('day').toDate()
                }
            ];
        }

        $scope.initialRowSetup = function() {
            if (initialSetup) {
                _.each(initialSetup.rowFilters, function(item) {
                    var rowFilter = _.findWhere(window.adHocAnalysis.queryResults['org.openmrs.module.reporting.cohort.definition.CohortDefinition'], { key: item.key });
                    if (rowFilter) {
                        $scope.addDefinitionWithParameters(copyDefinitionWithParameterValues(rowFilter, item.parameterValues), 'rowFilters');
                        $scope.dirty = false;
                    } else {
                        console.log("Could not find row: " + item.key);
                    }
                });
            }
        }

        $scope.initialColumnSetup = function() {
            if (initialSetup) {
                _.each(initialSetup.columns, function(item) {
                    var column = _.findWhere(window.adHocAnalysis.queryResults['org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition'], { key: item.key });
                    if (column) {
                        $scope.addDefinitionWithParameters(copyDefinitionWithParameterValues(column, item.parameterValues), 'columns');
                        $scope.dirty = false;
                    } else {
                        console.log("Could not find column: " + item.key);
                    }
                });
            }
        }

        window.adHocAnalysis.fetchData($http, window.adHocAnalysis, 'org.openmrs.module.reporting.cohort.definition.CohortDefinition', $scope.initialRowSetup);
        window.adHocAnalysis.fetchData($http, window.adHocAnalysis, 'org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition', $scope.initialColumnSetup);

        $scope.dataExport.valid = function() {
            return $scope.dataExport.name && $scope.dataExport.columns.length > 0;
        }


        $scope.ModalCtrl = function ($scope, $modal, $log) {

            $scope.definition = null;
            $scope.listToAddTo = null;
            $scope.filters = [];

            $scope.$on("OPEN_MODAL", function(event, definition, listToAddTo) {
                $scope.definition = definition;
                $scope.listToAddTo = listToAddTo;
                for(i = 0; i < definition.parameters.length; i++) {
                    var paramName = definition.parameters[i].name;
                    if(!_.contains(_.pluck($scope.$parent.dataExport.parameters, 'name'), paramName)) {
                        $scope.filters.push(paramName);
                    }
                }
                $scope.open();
            });

            $scope.open = function () {
                var modalInstance = $modal.open({
                    templateUrl: 'adHocAnalysisParameterPopup.page',
                    controller: $scope.ModalInstanceCtrl,
                    resolve: {
                        definition: function () {
                            return $scope.definition;
                        },
                        filters: function () {
                            return $scope.filters;
                        }
                    }
                });

                modalInstance.result.then(function(paramValues) {
                    var withParameters = copyDefinitionWithParameterValues($scope.definition, paramValues);
                    $scope.$parent.addDefinitionWithParameters(withParameters, $scope.listToAddTo);
                }, function () {
                    $log.info('Modal dismissed at: ' + new Date());
                });
            };
        };

        $scope.ModalInstanceCtrl = function ($scope, $modalInstance, definition, filters) {
            $scope.definition = definition;
            $scope.filters = filters;
            $scope.paramValues = {};
            $scope.dataExport = window.adHocDataExport; // we use this to access the global parameters

            $scope.paramFilter = function(param) {
                return _.contains(filters, param.name);
            }

            $scope.ok = function () {
                $modalInstance.close($scope.paramValues);
            };

            $scope.cancel = function () {
                $modalInstance.dismiss('cancel');
            };
        };

        $scope.addRow = function(definition) {
            if (jq.inArray(definition, $scope.dataExport.rowFilters) < 0) {
                if($scope.requiresExtraParameters(definition) && $scope.hasMissingParameters(definition)) {
                    $scope.showModal(definition);
                } else {
                    $scope.dataExport.rowFilters.push(definition);
                    setDirty();
                }
            }
        }

        $scope.addDefinitionWithParameters = function(definition, listToAddTo) {
            if(listToAddTo == 'columns') {
                $scope.dataExport.columns.push(definition);
            }
            else if(listToAddTo == 'rowFilters') {
                $scope.dataExport.rowFilters.push(definition);
            }
            setDirty();
        }

        $scope.showModal = function(definition) {
            var listToAddTo = 'rowFilters'
            if($scope.currentView == 'columns') {
                listToAddTo = 'columns';
            }
            // pass a copy of definition to the modal
            $scope.$broadcast("OPEN_MODAL", $.extend(true, {}, definition), listToAddTo);
        }

        $scope.removeRow = function(idx) {
            $scope.dataExport.rowFilters.splice(idx, 1);
            setDirty();
        }

        $scope.addColumn = function(definition) {
            if(jq.inArray(definition, $scope.dataExport.columns) < 0) {
                if($scope.requiresExtraParameters(definition) && $scope.hasMissingParameters(definition)) {
                    $scope.showModal(definition);
                }
                else {
                    $scope.dataExport.columns.push(definition);
                    setDirty();
                }
            }
        }

        $scope.removeColumn = function(idx) {
            $scope.dataExport.columns.splice(idx, 1);
            setDirty();
        }

        $scope.moveColumnUp = function(idx) {
            swap($scope.dataExport.columns, idx - 1, idx);
            setDirty();
        }

        $scope.moveColumnDown = function(idx) {
            swap($scope.dataExport.columns, idx, idx + 1);
            setDirty();
        }

        $scope.editCombination = function() {
            $('#custom-combination').val($scope.dataExport.customRowFilterCombination);
            $scope.editingCombination = true;
        }

        $scope.applyEditCombination = function() {
            $scope.dataExport.customRowFilterCombination = $('#custom-combination').val();
            $scope.editingCombination = false;
            setDirty();
        }

        $scope.cancelEditCombination = function() {
            $scope.editingCombination = false;
        }

        // ----- View and ViewModel ----------

        $scope.currentView = 'parameters';

        $scope.maxDay = moment().startOf('day').toDate();

        $scope.results = null;

        $scope.focusFirstElement = function() {
            $timeout(function() {
                $('#' + $scope.currentView + ' .focus-first').focus();
            });
        }

        $scope.$watch('currentView', $scope.focusFirstElement);

        $scope.$watch('dataExport.parameters', function() {
            if ($scope.currentView == 'preview') {
                $scope.preview();
            }
        }, true);

        $scope.openStartDatePicker = function() {
            $timeout(function() {
                $scope.isStartDatePickerOpen = true;
            });
        };

        $scope.openEndDatePicker = function() {
            $timeout(function() {
                $scope.isEndDatePickerOpen = true;
            });
        };

        // TODO remove this
        $scope.getFormattedStartDate = function() {
            if($scope.dataExport.parameters[0].value == null) { return; }
            return moment($scope.dataExport.parameters[0].value).format("DD MMM YYYY");
        }

        // TODO remove this
        $scope.getFormattedEndDate = function() {
            if($scope.dataExport.parameters[1].value == null) { return; }
            return moment($scope.dataExport.parameters[1].value).format("DD MMM YYYY");
        }

        $scope.availableSearches = function() {
            var allPossible = window.adHocAnalysis.queryResults['org.openmrs.module.reporting.cohort.definition.CohortDefinition'];
            return filterAvailable(allPossible, $scope.dataExport.rowFilters);
        }

        $scope.getColumns = function() {
            var allPossible = window.adHocAnalysis.queryResults['org.openmrs.module.reporting.data.patient.definition.PatientDataDefinition'];
            return filterAvailable(allPossible, $scope.dataExport.columns);
        }

        $scope.requiresExtraParameters = function(definition) {
            var allowedParameters = _.pluck($scope.dataExport.parameters, 'name');
            var paramNames = _.pluck(definition.parameters, 'name');
            var notAllowed = _.difference(paramNames, allowedParameters);
            return notAllowed.length != 0;
        }

        $scope.isParameterGloballySet = function(param) {
            var allowedParameters = _.pluck($scope.dataExport.parameters, 'name');
            return _.contains(allowedParameters, param.name);
        }

        $scope.hasMissingParameters = function(definition) {
            for(i = 0; i < definition.parameters.length; i++) {
                if (!$scope.isParameterGloballySet(definition.parameters[i])
                    && (definition.parameterValues == null || definition.parameterValues[definition.parameters[i].name] == null)) {
                    return true;
                }
            }
            return false;
        }

        $scope.changeStep = function(stepName) {
            var steps = [
                'parameters',
                'searches',
                'columns',
                'preview',
                'description'                
            ];
            var isAfterCurrentStep = false;

            $scope.currentView = stepName;

            if(stepName == 'preview') {
                $scope.preview();
            }

            for(var i=0; i < steps.length; i++) {
                if(!isAfterCurrentStep) {
                    if(steps[i] == stepName) {
                        isAfterCurrentStep = true;
                        $('span[data-step="' + steps[i] + '"]').addClass('current').removeClass('done');
                    } else {
                        $('span[data-step="' + steps[i] + '"]').addClass('done').removeClass('current');
                    }
                } else {
                    $('span[data-step="' + steps[i] + '"]').removeClass('done').removeClass('current');    
                }
            }
        }

        $scope.next = function() {
            if($scope.currentView == 'parameters') {
                $scope.currentView = 'searches';
                $('span[data-step="parameters"]').addClass('done').removeClass('current');
                $('span[data-step="searches"]').addClass('current');
            }

            else if($scope.currentView == 'searches') {
                $scope.currentView = 'columns';
                $('span[data-step="columns"]').addClass('current');
                $('span[data-step="searches"]').addClass('done').removeClass('current');
            }

            else if($scope.currentView == 'columns') {
                $scope.currentView = 'preview';
                $('span[data-step="preview"]').addClass('current');
                $('span[data-step="columns"]').addClass('done').removeClass('current');
                $scope.preview();
            }

            else if($scope.currentView == 'preview') {
                $scope.currentView = 'description';
                $('span[data-step="description"]').addClass('current');
                $('span[data-step="preview"]').addClass('done').removeClass('current');
            }
        }

        $scope.back = function() {
            if($scope.currentView == 'searches') {
                $scope.currentView = 'parameters';
                $('span[data-step="searches"]').removeClass('current');
                $('span[data-step="parameters"]').addClass('current').removeClass('done');
            }

            else if($scope.currentView == 'columns') {
                $scope.currentView = 'searches';
                $('span[data-step="columns"]').removeClass('current');
                $('span[data-step="searches"]').addClass('current').removeClass('done');
            }

            else if($scope.currentView == 'preview') {
                $scope.currentView = 'columns';
                $('span[data-step="preview"]').removeClass('current');
                $('span[data-step="columns"]').addClass('current').removeClass('done');
            }

            else if($scope.currentView == 'description') {
                $scope.currentView = 'preview';
                $('span[data-step="description"]').removeClass('current');
                $('span[data-step="preview"]').addClass('current').removeClass('done');
                $scope.preview();
            }
        }

        $scope.preview = function() {
            $scope.results = { loading: true };

            postJSON('/' + OPENMRS_CONTEXT_PATH + '/ws/rest/v1/reportingrest/adhocquery?v=preview', stripTimeFromParameters($scope.dataExport)).
                success(function(data, status, headers, config) {
                    $scope.results = data;
                }).
                error(function(data, status, headers, config) {
                    emr.handleParsedError(data);
                });
        }

        $scope.canSave = function() {
            return $scope.dataExport.valid();
        }

        $scope.saveDataExport = function() {
            $scope.dirty = { saving: true };
            post(emr.fragmentActionLink('reportingui', 'adHocAnalysis', 'saveDataExport'),
                    {
                        dataSet: angular.toJson($scope.dataExport)
                    }).
                success(function(data, status, headers, config) {
                    $scope.dataExport.uuid = data.uuid;
                    $scope.dataExport.name = data.name;
                    $scope.dataExport.description = data.description;
                    $scope.dirty = false;
                });
        }

        $scope.canRun = function() {
            return $scope.dataExport.uuid && !$scope.dirty;
        }

        $scope.runDataExport = function() {
            var data = {
                dataset: $scope.dataExport.uuid
            };
            _.each($scope.parameters, function(item) {
                data["parameterValues[" + item.name + "]"] = item.value;
            });
            location.href = emr.pageLink('reportingui', 'adHocRun', data);
        }
    }]);

