import Chart from "chart.js/auto";
import 'chartjs-adapter-moment';
import moment from 'moment';

const MonitorHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        labels: [1,2,3],
        datasets: [{
          label: 'Duration',
          borderColor: "rgb(6, 182, 212, 0.8)",
          backgroundColor: "rgb(14, 116, 144, 0.8)",
          lineTension: 0,
          borderWidth: 2
        }]
      },
      options: {
        responsive: true,
        scales: {
          x: {
            display: true,
            type: 'timeseries',
            min: moment().toISOString(),
            ticks: {
              color: "rgb(14, 165, 233, 0.8)",
            },
            
          },
          y: {
            display: true,
            beginAtZero: false,
            ticks: {
              color: "rgb(14, 165, 233, 0.8)",
            },
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

const ChartHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        datasets: []
      },
      options: {
        responsive: true,
        scales: {
          x: {
            display: true,
            type: 'timeseries',
            min: moment().toISOString(),
            ticks: {
              color: "rgb(14, 165, 233, 0.8)",
            },
            
          },
          y: {
            display: true,
            ticks: {
              color: "rgb(14, 165, 233, 0.8)",
            },
          }
        }
      }
    });

    this.handleEvent(`init-chart-${this.el.id}`, (data) => {
      if(data.type) chart.config.type = data.type
      chart.data.datasets = data.datasets;
      if(data.options.stacked) chart.options.scales.y.stacked = data.options.stacked;
      if(data.options.beginAtZero) chart.options.scales.y.beginAtZero = data.options.beginAtZero;
      chart.update();
    });

    this.handleEvent(`update-chart-${this.el.id}`, (data) => {
      chart.data.labels.push(data.x_axis);
      data.results.forEach((result, index) => {
        chart.data.datasets[index].data.push(result);
      })
      chart.update();
    });
  }
}

export {MonitorHook, ChartHook};