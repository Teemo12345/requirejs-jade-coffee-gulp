gulp = require('gulp')
rjs = require('requirejs')
bowerfile = require 'main-bower-files'
preen = require 'preen'
gulp.task 'default',->
  console.log 'default'

gulp.task 'rjs',()->
  conf = 
    appDir:'public'
    baseUrl:'./js/'
    dir:'dist/temp'
    stubModules: ['cs']
    pragmasOnSave:
      excludeJade: true
    modules:[
        name:'app/module1/main1'
        include:'cs!app/module1/module1'
        exclude:['app/common','coffee-script','jquery']
      ,
        name:'app/module2/main2'
        include:'cs!app/module2/module2'
        exclude:['app/common','coffee-script','jade']
     ]
    paths:
      'jquery':'vendor/jquery/dist/jquery.min'
      'cs':'vendor/require-cs/cs'
      'jade':'vendor/require-jade/jade'
      'coffee-script':'vendor/coffeescript/extras/coffee-script'
    removeCombined: true
    fileExclusionRegExp: /(^\.|^vendor$)/
    onBuildRead: (fname, path, cnt) ->
      cnt = cnt.replace /(cs)!/g, ''
      cnt
  rjs.optimize conf,->
    console.log 'end'

gulp.task 'copy:vendor',->
  gulp.src ['public/js/vendor/bootstrap/dist/**/*.*']
    .pipe gulp.dest 'dist/temp/js/vendor/bootstrap/dist'

gulp.task 'bower',->
  gulp.src bowerfile()
    .pipe gulp.dest 'dist/temp/js/vendor'

gulp.task 'preen',(cb)->
  return preen({}, cb)