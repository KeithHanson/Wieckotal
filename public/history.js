$(document).ready(function() {

  $.plot($("#history"), [
      { label: "Number of Tickets Created", data: ticketed_results },
      { label: "Number of Tickets Completed", data: completed_results }
    ], {
      series: { bars: { show: true, align: "center", barWidth: 0.5 } },
      xaxis: {
        ticks: week_labels
      },
      legend: { show: true, position: "ne"}
  });

  $.plot($("#points_history"), [
      { label: "Number of Points Created", data: points_ticketed },
      { label: "Number of Points Completed", data: points_completed }
    ], {
      series: { bars: { show: true, align: "center", barWidth: 0.5 } },
      xaxis: {
        ticks: week_labels
      },
      legend: { show: true, position: "ne"}
  });

});
