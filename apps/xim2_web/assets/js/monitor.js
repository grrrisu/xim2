import Chart from "chart.js/auto";

MonitorHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        labels: [1,2,3],
        datasets: [{
          label: 'Duration',
          borderColor: "rgb(6, 182, 212, 0.8)",
          backgroundColor: "rgb(14, 116, 144, 0.8)",
          //fill: true,
          lineTension: 0,
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        scales: {
          // xAxis: {
          //   type: 'time'
          // },
          x: {
            display: true,
          },
          y: {
            display: true,
            beginAtZero: false
          }
        }
      }
    })

    this.handleEvent("update-duration-chart", (data) => {
      chart.data.labels.push(data.x_axis);
      chart.data.datasets[0].data.push(data.duration);
      chart.update();
    });
  }
}

export default MonitorHook;