require(['../common'],function(_config){
  require(['cs!./app/module1/module1'],function(module1){
   module1.init()
  })
})