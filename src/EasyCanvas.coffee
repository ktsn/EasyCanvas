###
  Dependent: jQuery
###

class EasyCanvas
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
    .mousedown(@beginFreeHand)
    .mousemove(@moveFreeHand)
    .mouseup(@endFreeHand)
    .appendTo(@$container)

  ###
    Drawing
  ###

  beginFreeHand: (e) =>
    if @dragging then return

    @realtime_ctx.save()
    @realtime_ctx.globalAlpha *= 0.5

    canvas_rect = e.target.getBoundingClientRect()
    mouse_x = e.clientX - canvas_rect.left
    mouse_y = e.clientY - canvas_rect.top

    @realtime_ctx.beginPath()
    @realtime_ctx.moveTo(mouse_x, mouse_y)

    @mutable_ctx.beginPath()
    @mutable_ctx.moveTo(mouse_x, mouse_y)

    @dragging = true

  moveFreeHand: (e) =>
    if !@dragging then return

    canvas_rect = e.target.getBoundingClientRect()
    mouse_x = e.clientX - canvas_rect.left
    mouse_y = e.clientY - canvas_rect.top

    @realtime_ctx.clearRect(0, 0, @$realtime_canvas[0].width, @$realtime_canvas[0].height)
    @realtime_ctx.lineTo(mouse_x, mouse_y)
    @realtime_ctx.stroke()

    @mutable_ctx.lineTo(mouse_x, mouse_y)

  endFreeHand: (e) =>
    if !@dragging then return

    @dragging = false

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

