define ['jade!app/tmpl/testA'], (tmpl)->
  init:->

    document.getElementById('test').innerHTML = tmpl()
    console.log tmpl()