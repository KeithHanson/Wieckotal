function create_graph(id, raw_data, label_text)
{
  data = [];
  ticks = [];

  $.each(raw_data, function(label) {

    data[data.length] = [data.length, this];
    ticks[ticks.length] = [ticks.length, label];

  });

  $.plot($(id), [
      { label: label_text, data: data },
    ], {
      series: { bars: { show: true, align: "center" } },
      xaxis: {
        ticks: ticks
      }
  });

}

$(document).ready(function(){
    create_graph("#done_stories", done_stories_points, "Points by Project");
    create_graph("#done_stories_ams", done_stories_points_ams, "Points by Owner");
    create_graph("#finished_stories", finished_stories_points, "Points by Project");
    create_graph("#finished_stories_ams", finished_stories_points_ams, "Points by AM");
    create_graph("#finished_stories_devs", finished_stories_points_devs, "Points by Dev");
});

