// Generated by CoffeeScript 1.9.3
(function() {
  var Chart, generate_data,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Chart = (function() {
    function Chart() {
      this.draw_left_axis = bind(this.draw_left_axis, this);
      this.vertical_padding = 100;
      this.horizontal_padding = 60;
      this.width = 1200 - this.vertical_padding * 2;
      this.height = 2000 - this.horizontal_padding * 2;
    }

    Chart.prototype.render = function(el, data) {
      var bottom_svg, colorscale, d3el, layered_data, main_div, main_svg, rounded_xmax, top_svg, x, xmax, y;
      d3el = d3.select(el);
      top_svg = this.create_svg(d3el, this.width, 30, this.vertical_padding, 30);
      main_div = d3el.append('div').attr('class', 'main_div');
      main_svg = this.create_svg(main_div, this.width, this.height, this.vertical_padding, 0);
      bottom_svg = this.create_svg(d3el, this.width, 30, this.vertical_padding, 0);
      layered_data = ["Low activity", "Med activity", "High activity"].map(function(keyword) {
        return data.map(function(entry) {
          return {
            x: entry.key,
            y: entry[keyword],
            name: keyword
          };
        });
      });
      d3.layout.stack()(layered_data);
      xmax = d3.max(layered_data[layered_data.length - 1], function(entry) {
        return entry.y0 + entry.y;
      });
      rounded_xmax = Math.ceil(xmax / 100) * 100;
      x = d3.scale.linear().range([0, this.width]).domain([0, rounded_xmax]);
      y = d3.scale.ordinal().rangeBands([0, this.height], 0.5).domain(data.map(function(entry, idx) {
        return idx;
      }));
      colorscale = d3.scale.ordinal().range(["#B7D5E2", "#29ABE2", "#196687"]);
      this.draw_bottom_axis(bottom_svg, x.copy().domain([0, 100]));
      this.draw_legend(top_svg, layered_data, colorscale);
      this.draw_top_axis(top_svg, x);
      this.draw_left_axis(main_svg, y, layered_data[0]);
      this.draw_horizontal_lines(main_svg, x);
      return this.draw_bars(main_svg, layered_data, x, y, colorscale);
    };

    Chart.prototype.create_svg = function(el, width, height, vpadding, hpadding) {
      return el.append('svg').style('width', width + vpadding * 2).style('height', height + hpadding * 2).append('g').attr('transform', "translate( " + vpadding + ", " + hpadding + " )");
    };

    Chart.prototype.draw_top_axis = function(svg, x) {
      var top_axis;
      top_axis = svg.selectAll('.top_axis').data(x.ticks(10)).enter().append('text').attr('class', 'top_axis').attr('transform', function(d) {
        return "translate(" + (x(d)) + ", 30)";
      }).attr("dx", "-.5em").attr("dy", "-.5em").text(function(d) {
        return d;
      });
      return svg.append('text').attr('transform', "translate(" + this.width + ", 0)").text('# of members').style('font-weight', 'bold');
    };

    Chart.prototype.draw_bottom_axis = function(svg, x) {
      return svg.selectAll('.bottom_axis').data(x.ticks(10)).enter().append('text').attr('transform', function(d) {
        return "translate(" + (x(d)) + ", 20)";
      }).attr("dx", "-.5em").attr("dy", "-.5em").text(function(d) {
        return d + "%";
      });
    };

    Chart.prototype.draw_left_axis = function(svg, y, data) {
      var left_axis;
      left_axis = svg.selectAll('.left_axis').data(data).enter().append('g').attr('class', 'left_axis').attr('transform', (function(_this) {
        return function(d, idx) {
          return "translate(" + (-_this.vertical_padding + 5) + ", " + (y(idx) + 20) + ")";
        };
      })(this));
      return left_axis.append('text').text(function(d) {
        return d.x;
      });
    };

    Chart.prototype.draw_legend = function(svg, data, colorscale) {
      var legends, rect_side;
      rect_side = 20;
      legends = svg.selectAll('.legend').data(data).enter().append('g').attr('class', 'legend').attr('transform', function(d, idx) {
        return "translate(" + (idx * rect_side * 6) + ", " + (-20) + ")";
      });
      legends.append('rect').attr('x', 0).attr('y', 0).attr('width', rect_side).attr('height', rect_side).style('fill', function(d, i) {
        return colorscale(i);
      });
      return legends.append('text').text(function(d) {
        return d[0].name;
      }).attr('x', rect_side + 2).attr('y', rect_side - 5);
    };

    Chart.prototype.draw_bars = function(svg, data, x, y, color) {
      var g_groups, rect;
      g_groups = svg.selectAll('.g_groups').data(data).enter().append('g').attr('class', 'g_groups').style('fill', function(d, i) {
        return color(i);
      });
      return rect = g_groups.selectAll('rect').data(function(d) {
        return d;
      }).enter().append('rect').attr('x', function(d) {
        return x(d.y0);
      }).attr('y', function(d, idx) {
        return y(idx);
      }).attr('width', function(d) {
        return x(d.y);
      }).attr('height', y.rangeBand());
    };

    Chart.prototype.draw_horizontal_lines = function(svg, x) {
      return svg.selectAll('.horizontal_line').data(x.ticks(10)).enter().append('line').attr('transform', function(d) {
        return "translate(" + (x(d)) + ", 0)";
      }).attr('y2', this.height).attr('class', 'horizontal_line').style('stroke', 'gray');
    };

    return Chart;

  })();

  generate_data = function() {
    var data, i, j;
    data = [];
    for (i = j = 0; j < 30; i = ++j) {
      data.push({
        key: "Access group " + (i + 1),
        "Low activity": Math.random() * 10 + 20,
        "Med activity": Math.random() * 50 + 50,
        "High activity": Math.random() * 50 + 20
      });
    }
    return data;
  };

  window.Chart = Chart;

  window.generate_data = generate_data;

}).call(this);
