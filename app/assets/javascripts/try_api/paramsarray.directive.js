angular.module('TryApi').directive('paramsarray', [
  '$filter', function($filter) {
    var link;
    link = function(scope, element, attrs, ctrl) {
      scope.parameter.values = [];
      scope.addItem = function() {
        return scope.parameter.values.push(jQuery.extend(true, {}, scope.parameter.parameters));
      };
      return scope.deleteItem = function(index) {
        return scope.parameter.values.splice(index, 1);
      };
    };
    return {
      link: link,
      restrict: 'A',
      require: 'ngModel',
      scope: {
        parameter: '=ngModel'
      },
      template:  '' +
        '<div class="try-api-array-item" ng-repeat="value in parameter.values track by $index">' +
        '  <div params ng-model="value"></div>' +
        '  <div class="try-api-array-item-close" ng-click="deleteItem($index)"><i class="fa fa-close"></i></div>' +
        '</div>' +
        '<div class="try-api-array-item try-api-array-item-add" ng-click="addItem()">' +
        '  <a>Add</a>' +
        '</div>'
    };
  }
]);
