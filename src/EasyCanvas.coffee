###
  Dependent: jQuery
###

class EasyCanvas
  config:
    draw:
      preview_alpha_ratio: 0.5
  $container: null
  $mutable_canvas: null
  mutable_ctx: null
  $realtime_canvas: null
  realtime_ctx: null

  $listener: null

  dragging: false

  constructor: (@$container) ->
    @$container.addClass("ec-container")
    @$mutable_canvas = $("<canvas class='ec-canvas'></canvas>")
    .attr("width", @$container.width())
    .attr("height", @$container.height())
    .appendTo(@$container)
    @mutable_ctx = @$mutable_canvas[0].getContext("2d")

    @$realtime_canvas = $("<canvas class='ec-canvas'></canvas>")
    .attr("width", @$container.width())
    .attr("height", @$container.height())
    .appendTo(@$container)
    @realtime_ctx = @$realtime_canvas[0].getContext("2d")

    @setLinejoin("round")
    @setLineCap("round")

    @$listener = $("<div class='ec-listener'></div>")
    .mousedown(@beginDrag)
    .mousemove(@moveDrag)
    .mouseup(@endDrag)
    .appendTo(@$container)

  ###
    Canvas Listener
  ###

  beginDrag: (e) =>
    return if @dragging

    @dragging = true

    canvas_rect = e.target.getBoundingClientRect()
    mouse_x = e.clientX - canvas_rect.left
    mouse_y = e.clientY - canvas_rect.top

    @beginFreeHand(mouse_x, mouse_y)

  moveDrag: (e) =>
    return if !@dragging

    canvas_rect = e.target.getBoundingClientRect()
    mouse_x = e.clientX - canvas_rect.left
    mouse_y = e.clientY - canvas_rect.top

    @moveFreeHand(mouse_x, mouse_y)

  endDrag: (e) =>
    return if !@dragging

    @endFreeHand()

    @dragging = false

  ###
    Drawing
  ###

  beginFreeHand: (x, y) ->
    @realtime_ctx.save()
    @realtime_ctx.globalAlpha *= @config.draw.preview_alpha_ratio
    @realtime_ctx.beginPath()
    @realtime_ctx.moveTo(x, y)

    @mutable_ctx.beginPath()
    @mutable_ctx.moveTo(x, y)

  moveFreeHand: (x, y) ->
    @realtime_ctx.clearRect(0, 0, @$realtime_canvas[0].width, @$realtime_canvas[0].height)
    @realtime_ctx.lineTo(x, y)
    @realtime_ctx.stroke()

    @mutable_ctx.lineTo(x, y)

  endFreeHand: () ->
    @realtime_ctx.clearRect(0, 0, @$realtime_canvas[0].width, @$realtime_canvas[0].height)
    @mutable_ctx.stroke()

    @realtime_ctx.restore()

    @onDrawEnd(@$mutable_canvas)

  ###
    Configure Canvas
  ###

  setAlpha: (alpha) ->
    @mutable_ctx.globalAlpha = @realtime_ctx.globalAlpha = alpha

  setLineWidth: (width) ->
    @mutable_ctx.lineWidth = @realtime_ctx.lineWidth = width

  setStrokeColor: (css_color) ->
    @mutable_ctx.strokeStyle = @realtime_ctx.strokeStyle = css_color

  setFillColor: (css_color) ->
    @mutable_ctx.fillStyle = @realtime_ctx.fillStyle = css_color

  setLinejoin: (type) ->
    @mutable_ctx.lineJoin = @realtime_ctx.lineJoin = type

  setLineCap: (type) ->
    @mutable_ctx.lineCap = @realtime_ctx.lineCap = type

  ###
    Event Listener
  ###

  onDrawEnd: (canvas) ->

