gulp = require('gulp')
rjs = require('requirejs')
bowerfile = require 'main-bower-files'
path = require 'path'
gulpCoffee = require 'gulp-coffee'
gulpJade = require 'gulp-jade'
gulpAddSrc = require 'gulp-add-src'
gulpRev = require 'gulp-rev'
gulpRevReplace = require 'gulp-rev-replace'
rimraf = require 'rimraf'
runSequence = require 'run-sequence'
connect = require 'gulp-connect'

gulp.task 'default',->
  console.log 'default'

gulp.task 'cp:bower',->
  gulp.src bowerfile(),{base:"public/js/vendor"}
    .pipe gulp.dest 'dist/temp/js/vendor'

gulp.task 'cp:js',->
  gulp.src 'public/js/app/**/*.coffee'
    .pipe gulpCoffee({bare:true})
    .pipe gulpAddSrc 'public/js/app/**/*.js'
    .pipe gulpAddSrc 'public/js/app/**/*.jade'
    .pipe gulp.dest 'dist/temp/js/app'

gulp.task 'cp:css',->
  gulp.src 'public/css/*.css'
    .pipe gulp.dest 'dist/temp/css'

gulp.task 'rjs',['cp:css','cp:js','cp:bower'],(cb)->
  conf = 
    appDir:'dist/temp'
    baseUrl:'./js/'
    dir:'dist/src'
    stubModules: ['cs','jade']
    # pragmasOnSave:
    #   excludeJade: true
    modules:[
        name:'app/module1/main1'
        include:['app/module1/module1']
        exclude:['app/common','coffee-script','jquery']
      ,
        name:'app/module2/main2'
        include:['app/module2/module2']
        exclude:['app/common','coffee-script','jade']
     ]
    paths:
      'jquery':'empty:'
      'cs': 'empty:'
      'jade':'vendor/require-jade/jade'
      'coffee-script':'empty:'
    removeCombined: true
    skipDirOptimize: true
    # // 在 RequireJS 2.0.2 中，输出目录的所有资源会在 build 前被删除
    # // 值为 true 时 rebuild 更快，但某些特殊情景下可能会出现无法预料的异常
    # keepBuildDir: true
    # fileExclusionRegExp: /(^\.|^vendor$)/
    onBuildRead: (fname, path, cnt) ->
      cnt = cnt.replace /(cs|lcs)!/g, ''
      # cnt
    optimizeCss: "standard"
  rjs.optimize conf,->
    console.log 'rjs end'
    rimraf 'dist/temp',cb

gulp.task 'cp:html',(cb)->
  gulp.src ['views/*.jade','!views/layout.jade']
    .pipe gulpJade({pretty: true})
    .pipe gulp.dest 'dist/src'

gulp.task 'add:rev',['rjs'],()->
  gulp.src ['dist/src/**/**.+(js|css)',"!dist/src/js/vendor/**","!dist/src/js/app/common.js"]
    .pipe gulpRev()
    .pipe gulpAddSrc 'dist/src/**/vendor/**'
    .pipe gulpAddSrc 'dist/src/**/**/common.js'
    .pipe gulp.dest 'dist/'
    .pipe gulpRev.manifest()
    .pipe gulp.dest 'dist/src/rev'
    .on 'end',->
      console.log 'rev:end'
    #   cb()

gulp.task 'build:html',['cp:html'],(cb)->
  mft = gulp.src 'dist/src/rev/rev-manifest.json'
  gulp.src 'dist/src/*.html'
    .pipe gulpRevReplace({manifest:mft})
    .pipe gulp.dest 'dist/'

gulp.task "del:dist",(cb)->
  console.log 'del:dist'
  rimraf 'dist',cb

gulp.task "del:src",(cb)->
  console.log 'del:dist'
  rimraf 'dist/src',cb

gulp.task 'build:all',["del:dist"],(cb)->
  runSequence ["add:rev"],["build:html"],["del:src"],->
    # rimraf 'dist/src',cb
    console.log 'all done'    

gulp.task 'test:dist',->
  connect.server
    root:'dist'
    port: 9100