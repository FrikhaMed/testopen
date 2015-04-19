/*
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */


var app = angular.module('runAdHocExport', ['ui.bootstrap']).

    filter('translate', function() {
        return function(input, prefix) {
            if (input && input.uuid) {
                input = input.uuid;
            }
            var code = prefix ? prefix + input : input;
            return emr.message(code, input);
        }
    }).

    controller('RunAdHocExportController', ['$scope', '$http', function($scope, $http) {

        $scope.outputFormat = 'org.openmrs.module.reporting.report.renderer.CsvReportRenderer';

        $scope.exports = adHocExports;

        _.each($scope.exports, function(item) {
            item.selected = initialSelection.indexOf(item.uuid) >= 0;
        });

        $scope.paramValues = { };

        $scope.requiredParameters = function() {
            var params = [];
            var addParameterSafely = function(p) {
                if (!_.findWhere(params, { name: p.name })) {
                    params.push(p);
                }
            }
            _.each($scope.exports, function(item) {
                if (item.selected) {
                    _.each(item.parameters, function(p) {
                        addParameterSafely(p);
                    });
                }
            });
            return params;
        }

        var missingParameters = function() {
            return _.some($scope.requiredParameters(), function(item) {
                return !($scope.paramValues[item.name]);
            });
        }

        $scope.canRun = function() {
            return _.findWhere($scope.exports, { selected: true }) && !missingParameters();
        }

        function serverFriendly(original) {
            if (original instanceof Date) {
                return moment(original).format("YYYY-MM-DD HH:mm:ss");
            }
            else {
                return original;
            }
        }

        $scope.run = function() {
            var uuids = _.pluck(_.where($scope.exports, { selected: true }), 'uuid');
            var params = {
                dataset: uuids,
                outputFormat: $scope.outputFormat
            };
            for (key in $scope.paramValues) {
                params['param[' + key + ']'] = serverFriendly($scope.paramValues[key]);
            }

            $http.post(emr.fragmentActionLink('reportingui', 'adHocAnalysis', 'runAdHocExport', params)).
                success(function(data) {
                    if (data.uuid) {
                        location.href = emr.pageLink('reportingui', 'reportStatus', { request: data.uuid });
                    }
                    else {
                        emr.errorAlert(data.error);
                    }
                }).
                error(function() {
                    emr.errorAlert('ERROR!');
                });
        }

    }]);