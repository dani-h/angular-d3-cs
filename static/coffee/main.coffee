appModule = angular.module("app", [])

appModule.controller("ChartController", ["$scope", "$interval", ($scope, $interval) ->
  $scope.stacked_barchart_data = window.gen_stackedbarchart_data()
  $interval(
    -> $scope.stacked_barchart_data = window.gen_stackedbarchart_data()
    1000)
])

appModule.directive("stackedBarChart", -> {
  restrict: "E"
  link: ($scope, el, attrs) ->
    chart = new window.StackedBarChart()
    # Rerender when data changes
    $scope.$watch("stacked_barchart_data", -> chart.render(el[0], $scope.stacked_barchart_data))
})

