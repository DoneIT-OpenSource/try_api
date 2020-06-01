angular.module('TryApi').directive('url', [
  '$filter', '$sce', function($filter, $sce) {

    var link = function(scope, element, attrs, ctrl) {

      scope.isParameter = function(value) {
        return typeof value == 'string' && value.indexOf(':') >= 0;
      };

      scope.parts = scope.pattern.split('/').filter(Boolean).map(function(i) {
        return {
          value: scope.isParameter(i) ? '' : i,
          placeholder: i
        };
      });

      scope.$watch('parts', function() {
        return scope.url = scope.parts.map(function(i) {
          return i.value === '' ? '0' : i.value;
        }).join('/');
      }, true);

      return scope.inputStyle = function(part) {
        var charWidth = 11.5;
        return {
          "width": (part.value.length + 1) * charWidth + "px",
          "min-width": part.placeholder.length * charWidth + "px"
        };
      };
    };

    return {
      link: link,
      restrict: 'A',
      require: 'ngModel',
      scope: {
        url: '=ngModel',
        pattern: '=pattern'
      },
      template: '' +
        '<span ng-repeat="part in parts track by $index">' +
          '/' +
          '<span ng-if="!isParameter(part.placeholder)">{{ part.value }}</span>' +
          '<input ng-if="isParameter(part.placeholder)" ng-model="part.value" class="url-input" ng-style="inputStyle(part)" placeholder="{{ part.placeholder }}" scope="max-width: 90%; font-family:monospace;"/>' +
        '</span>'
    };
  }
]);
