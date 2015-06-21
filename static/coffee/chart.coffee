class Chart
  constructor: ->
    @vertical_padding = 100
    @horizontal_padding =  60
    @width = 1200 - @vertical_padding * 2
    @height = 2000 - @horizontal_padding * 2

  render: (el, data) ->
    # Main function for rendering the d3 stacked bar chart.
    # Note that the chart consists of two independent `svg` components. One that contains most of the chart (bars, top
    # axis, left axis) and another one which contains the bottom axis. The main svg is wrapped in a div and is made
    # scrollable. The bottom axis is positioned below that div and is visible at all times.
    main_div = d3.select(el)
      .append('div')
      .attr('class', 'main_div')

    svg = main_div.append('svg')
      .style('width', @width + @vertical_padding * 2)
      .style('height', @height + @horizontal_padding * 2)
      .append('g')
        .attr('transform', "translate( #{@vertical_padding}, #{@horizontal_padding} )")

    layered_data = ["Low activity", "Med activity", "High activity"].map((keyword) ->
      data.map((entry) ->
        {x: entry.key, y: entry[keyword], name: keyword}))

    # Note: For stack layered charts:
    # y used for thickness, y0 used for baseline
    # d3.layout.stack seems to both return and mutate data in place
    d3.layout.stack()(layered_data)

    # Last entry has the highest baseline
    xmax = d3.max(layered_data[layered_data.length - 1], (entry) -> entry.y0 + entry.y)
    # We need to round xmax, otherwise we get uneven ticks and top and bottom axis are not equal. Therefore we need the
    # value to be rounded to 100 since percentages are divisible by 100
    rounded_xmax = Math.round(xmax / 100) * 100
    x = d3.scale.linear().range([0, @width])
      .domain([0, rounded_xmax])

    y = d3.scale.ordinal().rangeBands([0, @height], 0.5)
      .domain(data.map((entry, idx) -> idx))

    colorscale = d3.scale.ordinal().range(["#B7D5E2", "#29ABE2", "#196687"])

    # Bottom axis is detached from the svg chart as the svg chart is scrollable while the
    # bottom axis is always visible
    @draw_bottom_axis(el, x.copy().domain([0, 100]))
    @draw_top_axis(svg, x)
    @draw_left_axis(svg, y, layered_data[0])
    @draw_legend(svg, layered_data, colorscale)
    @draw_bars(svg, layered_data, x, y, colorscale)


  draw_top_axis: (svg, x, ticks) ->
    # Top axis
    # --------------------------------------
    # Draw the axis first as I'm not sure if there is an alternative to `render-order`
    # that is supported by the major browsers
    top_axis = svg.selectAll('.top_axis')
      .data(x.ticks(10))
      .enter().append('g')
      .attr('class', 'top_axis')
      .attr('transform', (d) -> "translate(#{x(d)}, 0)")

    # Horizontal lines that go through the chart
    top_axis.append('line')
      .attr('y2', @height)
      .style('stroke', 'gray')

    top_axis.append('text')
      .attr("dx", "-.5em")
      .attr("dy", "-.5em")
      .text((d) -> d)

    # Standalone top right text `# of members`
    svg.append('text')
      .attr('transform', "translate(#{@width}, -20)")
      .text('# of members')
      .style('font-weight', 'bold')


  draw_bottom_axis: (el, x) ->
    # Draws the bottom axis
    # @Todo: Fix comment below when I get some sleep.
    # There are a couple of gotchas here. First, the percentage axis will use the 0, 100 for the domain while the top
    # axis that displays exact numbers use the max from random data for the domain. The horizontal lines on the chart
    # are made based on the random data from the top axis and will therefore not overlap with the bottom axis because of
    # the different domain. This is a question of how you want to visualize the data, but I'll leave it for now since it
    # looks ok.
    bottom_axis_area = d3.select(el).append('svg')
      .style('width', @width + @vertical_padding * 2)
      .style('height', 30)
      .style('margin', '0 auto')
      .append('g')
        .attr('transform', "translate( #{@vertical_padding}, 0)")

    bottom_axis_area.selectAll('.bottom_axis')
      .data(x.ticks(10))
      .enter().append('text')
      .attr('transform', (d) -> "translate(#{x(d)}, 20)")
      .text((d) -> d + "%")


  draw_left_axis: (svg, y, data) =>
    # Left axis
    # --------------------------------------
    left_axis = svg.selectAll('.left_axis')
      .data(data)
      .enter().append('g')
      .attr('class', 'left_axis')
      .attr('transform', (d, idx) => "translate(#{-@vertical_padding + 5}, #{ y(idx) + 20 })")

    left_axis.append('text')
      .text((d) -> d.x)


  draw_legend: (svg, data, colorscale) ->
    rect_side = 20

    legends = svg.selectAll('.legend')
      .data(data)
      .enter().append('g')
      .attr('class', 'legend')
      .attr('transform', (d, idx) => "translate(#{idx * rect_side * 5}, #{-@horizontal_padding + 10})")

    legends.append('rect')
      .attr('x', 0)
      .attr('y', 0)
      .attr('width', rect_side)
      .attr('height', rect_side)
      .style('fill', (d, i) -> colorscale(i))

    legends.append('text')
      .text((d) -> d[0].name)
      .attr('x', rect_side + 2)
      .attr('y', rect_side - 5)


  draw_bars: (svg, data, x, y, color) ->
    # Bars
    # --------------------------------------
    # Shared attrs for the rects
    # Note that we the data is only the different top level arrays that
    # distinguish the color of the bars
    g_groups = svg.selectAll('.g_groups')
      .data(data)
      .enter().append('g')
      .attr('class', 'g_groups')
      .style('fill', (d, i) -> color(i))

    # Magic happens here
    # Note that we access the objects inside the arrays of layered data
    rect = g_groups.selectAll('rect')
      .data((d) -> d)
      .enter().append('rect')
      .attr('x', (d) -> x(d.y0))
      .attr('y', (d, idx) -> y(idx))
      .attr('width', (d) -> x(d.y))
      .attr('height', y.rangeBand())


generate_data = () ->
  data = []
  for i in [0...30]
    data.push({
      key: "Access group #{i + 1}"
      "Low activity": Math.random() * 10 + 10
      "Med activity": Math.random() * 50 + 50
      "High activity": Math.random() * 50 + 20
    })
  data


window.Chart = Chart
window.generate_data = generate_data

