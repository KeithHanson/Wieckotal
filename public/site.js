var graph = {
  data: {},
  init: function () {
    $("span.owner").each(function(index, domElement) {
      var owner = $(this);
      var owner_name = owner.text();
      var points = parseInt(jQuery.trim(owner.parent().siblings(".points").text()));
      
      if(graph.data[owner_name] == undefined || graph.data[owner_name] == null)
      {
        graph.data[owner_name] = 0;
      }

      if(!isNaN(points))
      {
        graph.data[owner_name] += points;
      }
    })
  },
  plot: function () {
    data = [];
    ticks = [];

    $.each(graph.data, function(name) { 
      data[data.length] = [data.length, this];
      ticks[ticks.length] = [ticks.length, name];
    });

    $.plot($(".graph"), [
      { label: "Points Per Owner", data: data }
    ], {
      series: { bars: { show: true, align: "center" } },
      xaxis: {
        ticks: ticks
      }
    });
  }
}


$(document).ready(function(){
  $("ol li a").click(function() {
    $(this).parent().children("div.description").toggle();
    $(this).parent().children("div.comments").toggle();
    return false;
  });

  $(".comments a").click(function(){
    var story_id = $(this).parents("li").attr("id")
    $(this).parent().load("/comments/" + story_id);
    return false;
  });


  graph.init();
  graph.plot();
});
