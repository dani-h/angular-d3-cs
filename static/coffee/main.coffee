appModule = angular.module("app", [])

appModule.controller("ChartController", ["$scope", "$interval", ($scope, $interval) ->
  $scope.interval_running = false
  $scope.stacked_barchart_data = window.gen_stackedbarchart_data()

  $scope.start_update = ->
    if $scope.interval_running == false
      $scope.interval_running = $interval(
        -> $scope.stacked_barchart_data = window.gen_stackedbarchart_data()
        750)

  $scope.stop_update = ->
    if $scope.interval_running?
      $interval.cancel($scope.interval_running)
      $scope.interval_running = false
])

appModule.directive("stackedBarChart", -> {
  restrict: "E"
  link: ($scope, el, attrs) ->
    chart = new window.StackedBarChart()
    # Rerender when data changes
    $scope.$watch("stacked_barchart_data", -> chart.render(el[0], $scope.stacked_barchart_data))
})

