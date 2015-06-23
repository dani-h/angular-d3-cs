appModule = angular.module("app", [])

appModule.controller("ChartController", ["$scope", ($scope) ->
  $scope.stacked_barchart_data = window.gen_stackedbarchart_data()
])

appModule.directive("stackedBarChart", -> {
  restrict: "E"
  link: (scope, el, attrs) ->
    new window.StackedBarChart().render(el[0], scope.stacked_barchart_data)
})

