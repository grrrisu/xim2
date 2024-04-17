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

const SummaryHook = {
  mounted() {
    const chart = new Chart(this.el, {
      type: 'line',
      data: {
        labels: [1,2,3],
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
            stacked: true,
            display: true,
            beginAtZero: true,
            ticks: {
              color: "rgb(14, 165, 233, 0.8)",
            },
          }
        }
      }
    });

    this.handleEvent(`init-chart-${this.el.id}`, (data) => {
      chart.data.datasets = data.datasets;
      chart.update();
    });

    this.handleEvent(`update-chart-${this.el.id}`, (data) => {
      chart.data.labels.push(data.x_axis);
      chart.data.datasets[0].data.push(data.vegetation);
      chart.data.datasets[1].data.push(data.herbivore);
      chart.data.datasets[2].data.push(data.predator);
      chart.update();
    });
  }
}

export {MonitorHook, SummaryHook};