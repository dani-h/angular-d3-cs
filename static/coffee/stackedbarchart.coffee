class StackedBarChart
  constructor: ->
    @vertical_padding = 100
    @horizontal_padding =  60
    @width = 1200 - @vertical_padding * 2
    @height = 2000 - @horizontal_padding * 2


  # Main function for rendering the d3 stacked bar chart.
  # The chart consists of three components: a top svg displaying the top axis and legend, a central svg displaying
  # the bars and a bottom svg displaying the bottom axis. The central svg is wrapped in a div and is made scrollable.
  # The others are always visible. The chart is attached to the passed parameter el.
  #
  # We expect that the data contains a json array where each object has an `xkey` and all the other keys describe the
  # different y layers. See `generate_data()`. Example [{xkey: "foo", y1: "baz", y2: "bar"},...]
  #
  # @param {jqlite object} Object passed from angulars link function
  # @param {Array<{xkey: string, ykeys...: string}>} Data
  render: (el, data) ->
    d3el = d3.select(el)
    d3el.selectAll("*").remove()

    top_svg = @create_svg(d3el, @width, 60, @vertical_padding, 0)
    main_div = d3el.append("div").attr("class", "main_div")
    main_svg = @create_svg(main_div, @width, @height, @vertical_padding, 0)
    bottom_svg = @create_svg(d3el, @width, 30, @vertical_padding, 0)

    # Relevant keys for the different y layers
    relevant_y_keys = Object.keys(data[0]).filter((key) -> key != "xkey")
    layered_data = relevant_y_keys.map((keyword) ->
      data.map((entry) ->
        {x: entry.xkey, y: entry[keyword], name: keyword}))

    # Note: For stack layered charts:
    # y used for thickness, y0 used for baseline
    # d3.layout.stack seems to both return and mutate data in place
    d3.layout.stack()(layered_data)

    # Last entry has the highest baseline
    xmax = d3.max(layered_data[layered_data.length - 1], (entry) -> entry.y0 + entry.y)
    # We need to round xmax, otherwise we get uneven ticks and top and bottom axis are not equal. Therefore we need the
    # value to be rounded to 100 since percentages are divisible by 100
    rounded_xmax = Math.ceil(xmax / 100) * 100
    x = d3.scale.linear().range([0, @width])
      .domain([0, rounded_xmax])

    y = d3.scale.ordinal().rangeBands([0, @height], 0.5)
      .domain(data.map((entry, idx) -> idx))

    colorscale = d3.scale.ordinal().range(["#B7D5E2", "#29ABE2", "#196687"])

    # Order of rendering matters! e.g we want the bars behind the horizontal lines
    @draw_legend(top_svg, layered_data, colorscale)
    @draw_top_axis(top_svg, x)
    @draw_left_axis(main_svg, y, layered_data[0])
    @draw_bottom_axis(bottom_svg, x.copy().domain([0, 100]))
    @draw_horizontal_lines(main_svg, x)
    @draw_bars(main_svg, layered_data, x, y, colorscale)


  # Creates a generic svg with a central g element that is translated for the margin conventions.
  # See: http://bl.ocks.org/mbostock/3019563
  # @param {HTMLEl} el
  # @param {number} width
  # @param {number} height
  # @param {number} vpadding
  # @param {number} hpadding
  #
  # @returns {d3el}
  create_svg: (el, width, height, vpadding=0, hpadding=0) ->
    el.append("svg")
      .style("width", width + vpadding * 2 + "px")
      .style("height", height + hpadding * 2 + "px")
      .append("g")
        .attr("transform", "translate( #{vpadding}, #{hpadding} )")

  # Draws the top axis
  # @param {d3el} svg
  # @param {d3scale} x
  draw_top_axis: (svg, x) ->
    svg_height = parseInt(d3.select(svg.node().parentNode).style("height"))

    top_axis = svg.selectAll(".top_axis")
      .data(x.ticks(10))
      .enter().append("text")
      .attr("class", "top_axis")
      .attr("transform", (d) -> "translate(#{x(d)}, #{svg_height})")
      .attr("dx", "-.5em")
      .attr("dy", "-.5em")
      .text((d) -> d)

    # Standalone top right text `# of members`
    svg.append("text")
      .attr("transform", "translate(#{@width}, #{20})")
      .text("# of members")
      .style("font-weight", "bold")


  # Draws the bottom axis. The dx and dy attributes of the ticks should be the same for the top and bottom axis.
  # @param {d3el} svg
  # @param {d3.scale.linear} x
  draw_bottom_axis: (svg, x) ->
    # Note: I have to hardcode 20 into the y translation here otherwise it"s positioned outside the parent svg.
    # Why? I need to figure out...For other svg elements that are not text this doesn"t happen
    svg.selectAll(".bottom_axis")
      .data(x.ticks(10))
      .enter().append("text")
      .attr("class", "bottom_axis")
      .attr("transform", (d) -> "translate(#{x(d)}, 20)")
      .attr("dx", "-.5em")
      .attr("dy", "-.5em")
      .text((d) -> d + "%")


  # Draws the left axis
  # @param {d3el svg
  # @param {d3.scale.ordinal} y
  # @param {Array{xkey: string, y: number, y0: number}} data
  draw_left_axis: (svg, y, data) =>
    left_axis = svg.selectAll(".left_axis")
      .data(data)
      .enter().append("g")
      .attr("class", "left_axis")
      .attr("transform", (d, idx) => "translate(#{-@vertical_padding + 5}, #{ y(idx) + 20 })")

    left_axis.append("text")
      .text((d) -> d.x)


  draw_legend: (svg, data, colorscale) ->
    rect_side = 20

    legends = svg.selectAll(".legend")
      .data(data)
      .enter().append("g")
      .attr("class", "legend")
      .attr("transform", (d, idx) -> "translate(#{idx * rect_side * 6}, 0)")

    legends.append("rect")
      .attr("x", 0)
      .attr("y", 0)
      .attr("width", rect_side)
      .attr("height", rect_side)
      .style("fill", (d, i) -> colorscale(i))

    legends.append("text")
      .text((d) -> d[0].name)
      .attr("x", rect_side + 2)
      .attr("y", rect_side - 5)


  # Draws the stacked bars of the charts
  # @param {d3el} svg
  # @param {Array<{}>} data
  # @param {d3.scale.linear} x
  # @param {d3.scale.ordinal} y
  # @param {d3.scale.ordinal} colorscale
  draw_bars: (svg, data, x, y, colorscale) ->
    # data = top level arrays
    g_groups = svg.selectAll(".g_groups")
      .data(data)
      .enter().append("g")
      .attr("class", "g_groups")
      .style("fill", (d, i) -> colorscale(i))

    # Magic happens here
    # Note that we access the objects inside the top level arrays arrays
    rect = g_groups.selectAll("rect")
      .data((d) -> d)
      .enter().append("rect")
      .attr("x", (d) -> x(d.y0))
      .attr("y", (d, idx) -> y(idx))
      .attr("width", (d) -> x(d.y))
      .attr("height", y.rangeBand())


  # Draws the horizontal lines that go behind the bar chart
  # @param {d3el} svg
  # @param {d3.scale.linear} x
  draw_horizontal_lines: (svg, x) ->
    svg.selectAll(".horizontal_line")
      .data(x.ticks(10))
      .enter().append("line")
      .attr("transform", (d) -> "translate(#{x(d)}, 0)")
      .attr("y2", @height)
      .attr("class", "horizontal_line")
      .style("stroke", "gray")



# Generates randomized data for the bar charts
# `xkey` and at least one arbitrary y-key must be present. Any key not named xkey will be assumed to be a y-key.
#
# @returns Array{xkey: string, y-keys:number...}
gen_stackedbarchart_data = () ->
  data = []
  for i in [0...30]
    data.push({
      xkey: "Access group #{i + 1}"
      "Low activity": Math.random() * 400 + 200
      "Med activity": Math.random() * 300 + 100
      "High activity": Math.random() * 200 + 50
    })
  data


window.StackedBarChart = StackedBarChart
window.gen_stackedbarchart_data = gen_stackedbarchart_data

