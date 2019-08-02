import bgfxdotnim, bgfxdotnim/platform, os, sdl2 as sdl
import zealpkg / [event, game, simulation, render, script, enims, apiImpl]

const
  SDL_MAJOR_VERSION* = 2
  SDL_MINOR_VERSION* = 0
  SDL_PATCHLEVEL* = 5

var
  quit = false
  prevTickEvents: seq[sdl.Event]

template sdlVersion*(x: untyped) =
  (x).major = SDL_MAJOR_VERSION
  (x).minor = SDL_MINOR_VERSION
  (x).patch = SDL_PATCHLEVEL

when defined(windows):
  type
    SysWMMsgWinObj* = object
      window*: pointer

    SysWMInfoKindObj* = object
      win*: SysWMMsgWinObj 

var
  window: sdl.WindowPtr
  entryPointScript: Script

proc onUserQuit(user: pointer, event: pointer) =
  quit = true

proc processSDLEvents() =
  var event = sdl.default_event

  while sdl.pollEvent(event):
    prevTickEvents.add(event)
    globalNotify(EventKind(event.kind), addr prevTickEvents[len(prevTickEvents) - 1], esEngine)
    case event.kind
    of sdl.KeyDown:
      case event.key.keysym.scancode
      of SDL_SCANCODE_ESCAPE:
        quit = true
        break
      of SDL_SCANCODE_F9:
        entryPointScript = compileScript("main.nims")
        entryPointScript.call("entry")
        break
      else:
        discard
      break
    else:
      discard

proc linkSDL2BGFX() =
  var pd: ptr bgfx_platform_data_t = createShared(bgfx_platform_data_t) 
  var info: sdl.WMinfo
  sdlVersion(info.version)
  assert sdl.getWMInfo(window, info)
  
  case(info.subsystem):
    of SysWM_Windows:
      when defined(windows):
        let info = cast[ptr SysWMInfoKindObj](addr info.padding[0])
        pd.nwh = cast[pointer](info.win.window)
      pd.ndt = nil
    else:
      discard

  pd.backBuffer = nil
  pd.backBufferDS = nil
  pd.context = nil
  bgfx_set_platform_data(pd)
  freeShared(pd)

proc init(): bool =
  prevTickEvents = @[]

  if sdl.init(sdl.INIT_VIDEO or sdl.INIT_TIMER) < sdl.SdlSuccess:
    stderr.writeLine("Failed to initialize SDL: $1\n" % $sdl.getError())
    return false
  
  window = sdl.createWindow(
    "Zeal",
    sdl.SDL_WINDOWPOS_UNDEFINED,
    sdl.SDL_WINDOWPOS_UNDEFINED,
    1920,
    1080,
    SDL_WINDOW_SHOWN
  )

  linkSDL2BGFX()

  var bgfxInit: bgfx_init_t
  bgfx_init_ctor(addr bgfxInit)
  if not bgfx_init(addr bgfxInit):
    stderr.writeLine("Failed to initialize BGFX")
    return false

  
  render.init(paramStr(1))
  event.init()

  event.globalRegister(EventKind(sdl.QuitEvent), onUserQuit, nil, int32(ssRunning) or int32(ssPausedUiRunning) or int32(ssPausedFull))
  
  game.init()

  result = true

proc shutdown() =
  echo "shutting down"
  render.shutdown()
  sdl.destroyWindow(window)
  sdl.quit()

proc run*() =
  var ret = QUIT_SUCCESS

  if not init():
    ret = QUIT_FAILURE
    quit(ret)
  
  #try:
    #entryPointScript = compileScript("main.nims")
    #WentryPointScript.call("entry")
  try:
    newGame("assets/maps", "foo.zmap")
    while not quit:
      processSDLEvents()
      event.serviceQueue()
      # game.update()
      render()
  except:
    echo getCurrentExceptionMsg()
  finally:
    shutdown()

when isMainModule:
  run()