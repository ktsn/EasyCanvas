###
  Dependent: jQuery
###

EasyCanvasDrawMode =
  Disabled: "disabled"
  FreeHand: "freehand"
  Eraser: "eraser"

class EasyCanvas
  config:
    draw:
      preview_alpha_ratio: 0.5
    eraser:
      width: 30
      preview_stroke_width: 2
      preview_fill_color: "white"
      preview_stroke_color: "black"

  $container: null
  $mutable_canvas: null
  mutable_ctx: null
  $realtime_canvas: null
  realtime_ctx: null

  $listener: null

  dragging: false
  mode_schedule: EasyCanvasDrawMode.FreeHand
  mode: EasyCanvasDrawMode.FreeHand

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
    .bind("mousedown touchstart", @beginDrag)
    .bind("mousemove touchmove", @moveDrag)
    .bind("mouseup touchend", @endDrag)
    .appendTo(@$container)

  getJpegDataURL: () ->
    return @$mutable_canvas[0].toDataURL("image/jpeg")

  getPngDataURL: () ->
    return @$mutable_canvas[0].toDataURL("image/png")

  setDataURL: (data) ->
    image = new Image()
    image.src = data

    image.onload = () =>
      canvas = @$mutable_canvas[0]
      @clearDrawing()
      @mutable_ctx.drawImage(image, 0, 0, canvas.width, canvas.height)

  ###
    Canvas Listener
  ###

  beginDrag: (e) =>
    return if @dragging

    @dragging = true
    rect = e.target.getBoundingClientRect()
    mouse_x = (if e.originalEvent.touches then e.originalEvent.touches[0].clientX else e.clientX) - rect.left
    mouse_y = (if e.originalEvent.touches then e.originalEvent.touches[0].clientY else e.clientY) - rect.top

    switch @mode
      when EasyCanvasDrawMode.FreeHand
        @beginFreeHand(mouse_x, mouse_y)
      when EasyCanvasDrawMode.Eraser
        @beginEraser(mouse_x, mouse_y)
      else

  moveDrag: (e) =>
    e.preventDefault()
    return if !@dragging

    rect = e.target.getBoundingClientRect()
    mouse_x = (if e.originalEvent.touches then e.originalEvent.touches[0].clientX else e.clientX) - rect.left
    mouse_y = (if e.originalEvent.touches then e.originalEvent.touches[0].clientY else e.clientY) - rect.top

    switch @mode
      when EasyCanvasDrawMode.FreeHand
        @moveFreeHand(mouse_x, mouse_y)
      when EasyCanvasDrawMode.Eraser
        @moveEraser(mouse_x, mouse_y)
      else

  endDrag: (e) =>
    return if !@dragging

    switch @mode
      when EasyCanvasDrawMode.FreeHand
        @endFreeHand()
      when EasyCanvasDrawMode.Eraser
        @endEraser()
      else

    @dragging = false

    # apply scheduled mode
    @changeDrawMode(@mode_schedule)

  ###
    Drawing
  ###

  changeDrawMode: (mode) ->
    # to prevent to change mode when the dragging is continuing
    @mode_schedule = mode

    if !@dragging
      @mode = mode
      if @mode == EasyCanvasDrawMode.Disabled
        @$listener.hide()
      else
        @$listener.show()


  beginFreeHand: (x, y) ->
    @realtime_ctx.beginPath()
    @realtime_ctx.moveTo(x, y)

    @mutable_ctx.beginPath()
    @mutable_ctx.moveTo(x, y)

  moveFreeHand: (x, y) ->
    @allClear(@$realtime_canvas)
    @realtime_ctx.lineTo(x, y)
    @realtime_ctx.stroke()

    @mutable_ctx.lineTo(x, y)

  endFreeHand: () ->
    @allClear(@$realtime_canvas)
    @mutable_ctx.stroke()

    @onDrawEnd(@$mutable_canvas)

  beginEraser: (x, y) ->
    @mutable_ctx.save()
    @realtime_ctx.save()

    @mutable_ctx.globalCompositeOperation = "destination-out"
    @mutable_ctx.lineWidth = @config.eraser.width
    @mutable_ctx.beginPath()
    @mutable_ctx.moveTo(x, y)

    @realtime_ctx.fillStyle = @config.eraser.preview_fill_color
    @realtime_ctx.strokeStyle = @config.eraser.preview_stroke_color
    @realtime_ctx.lineWidth = @config.eraser.preview_stroke_width

  moveEraser: (x, y) ->
    @mutable_ctx.lineTo(x, y)
    @mutable_ctx.stroke()

    radius = (@config.eraser.width - @config.eraser.preview_stroke_width) / 2
    @allClear(@$realtime_canvas)
    @realtime_ctx.beginPath()
    @realtime_ctx.arc(x, y, radius, 0, 2 * Math.PI, false)
    @realtime_ctx.fill()
    @realtime_ctx.stroke()

  endEraser: () ->
    @allClear(@$realtime_canvas)

    @mutable_ctx.restore()
    @realtime_ctx.restore()

    @onDrawEnd(@$mutable_canvas)

  clearDrawing: () ->
    @allClear(@$mutable_canvas)
    @onClear(@$mutable_canvas)

  allClear: ($canvas) ->
    canvas = $canvas[0]
    ctx = canvas.getContext("2d")
    ctx.clearRect(0, 0, canvas.width, canvas.height)

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
  onClear: (canvas) ->

