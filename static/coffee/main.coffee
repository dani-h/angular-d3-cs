appModule = angular.module('app', [])

appModule.controller('ChartController', ['$scope', ($scope) ->
  $scope.data = window.generate_data()
])

# Todo: Read up on how angular deals with the directive api functions
# It seems like `link` is called when `$scope` changes (?). Make it optimized for
# d3's enter/update/exit
appModule.directive('chart', ->
  {
    link: (scope, el, attrs) ->
      new window.Chart().render(el[0], scope.data)
  }
)



