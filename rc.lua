-- Requires {{{
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- widgit library
require("vicious")
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/mvisser/.config/awesome/themes/visser3/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,        --  1
    awful.layout.suit.tile,            --  2
    awful.layout.suit.tile.left,       --  3
    awful.layout.suit.tile.bottom,     --  4
    awful.layout.suit.tile.top,        --  5
    awful.layout.suit.fair,            --  6
    awful.layout.suit.fair.horizontal, --  8
    awful.layout.suit.spiral,          --  9
    awful.layout.suit.spiral.dwindle,  -- 10
    awful.layout.suit.max,             -- 11
    awful.layout.suit.max.fullscreen,  -- 12
    awful.layout.suit.magnifier        -- 13
}

-- {{{ Calendar Setup
local calendar = nil
local offset = 0

function remove_calendar()
    if calendar ~= nil then
        naughty.destroy(calendar)
        calendar = nil
        offset = 0
    end
end
function add_agenda()
    remove_calendar()
    local cal = awful.util.pread("gcalcli --nc agenda")
    cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
    calendar = naughty.notify({
        text = string.format('<span font_desc="%s">%s</span>', "monospace", os.date("%a, %d %B %Y") .. "\n" .. cal),
        timeout = 0, hover_timeout = 0.5,
        width = 300,
    })
end
function add_calendar(inc_offset)
    local save_offset = offset
    remove_calendar()
    offset = save_offset + inc_offset
    local datespec = os.date("*t")
    datespec = datespec.year * 12 + datespec.month - 1 + offset
    datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
    local cal = awful.util.pread("cal -m " .. datespec)
    cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
    calendar = naughty.notify({
        text = string.format('<span font_desc="%s">%s</span>', "monospace", os.date("%a, %d %B %Y") .. "\n" .. cal),
        timeout = 0, hover_timeout = 0.5,
        width = 160,
    })
end
--}}}

-- {{{ MPD info
--local mpd_info_state    = nil
--local mpd_info = nil
--
--function remove_mpd_info()
--    if mpd_info ~= nil then
--        naughty.destroy(mpd_info)
--        mpd_info = nil
--        mpd_info_state = nil
--    end
--end
--
--function add_mpd_info()
--    mpd_info_state = 1
--    while mpd_info_state ~= nil do
--        local txt_info = awful.util.pread("mpc | head -3")
--        mpd_info = naughty.notify({
--            text = txt_info,
--            timeout = 5, hover_timeout = 0.5,
--            width = 200
--        })
--        os.execute("sleep 1")
--        remove_mpd_info() 
--    end
--end
-- }}}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    names  = {"α","β","γ","δ","ε","ζ","η","θ","ι"},
    layout = { 
        layouts[2], layouts[2], layouts[2], layouts[2],
        layouts[2] ,layouts[2],layouts[2],layouts[2],layouts[2] } }

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
    --tags[s] = awful.tag({1,2,3,4,5}, s, layouts[5])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "manual", terminal .. " -e man awesome" },
   { "quit", awesome.quit },
   { "restart", awesome.restart }
}

mymainmenu = awful.menu({
    items = { -- {{{
      --{
      --    "name",
      --    command,
      --    optional image
      --}
        {
            "awesome",
            myawesomemenu,
            beautiful.awesome_icon
        },
        {
            "mutt",
            terminal .. " -e mutt",
            image(awful.util.getdir("config") .. "/icons/gmail.png")
        },
        {
            "firefox",
            "firefox",
            image( "/usr/lib/firefox-3.6/chrome/icons/default/default16.png" )
        },
        {
            "uzbl",
            "uzbl-browser",
            image( "/home/mvisser/.config/awesome/icons/uzbl.png" )
        },
        {
            "ranger",
            terminal .. " -e ranger"
        },
        {
            "htop",
            terminal .. " -e htop"
        },
        {
            "irssi",
            terminal .. " -n irssi -e irssi "
        },
        {
            "ncmpcpp",
            terminal .. " -e ncmpcpp"
        },
        {
            "open terminal" ,
            terminal
        }
    } -- }}}
})

mylauncher = awful.widget.launcher({
    image = image(beautiful.awesome_icon),
    menu  = mymainmenu
})

-- }}}

-- {{{ Wibox

--  widgets {{{
-- clock widget {{{
mytextclock = awful.widget.textclock()
--}}}

-- GMAIL {{{
-- create a Gmail widget
mygmailicon = widget({type = "imagebox"})
mygmailicon.image = image(awful.util.getdir("config") .. "/icons/gmail.png")

mygmailwidget = widget({type = "textbox"})
vicious.register(mygmailwidget, vicious.widgets.mdir, " $1", 120, { "/home/mvisser/Mail/INBOX/" } )
--}}}

-- RTM{{{
rtmwidget  = widget({type = "textbox"})
vicious.register(rtmwidget, vicious.widgets.rtm, "${count}", 120)
--}}}

-- spacer {{{
mytextspacer = widget({type = "textbox" })
mytextspacer.text = " "
--}}}

-- battery {{{
batwidget = awful.widget.progressbar()
batwidget:set_width(8)
batwidget:set_height(20)
batwidget:set_vertical(true)
batwidget:set_background_color("#000000")
batwidget:set_border_color(nil)
batwidget:set_color( beautiful.fg_focus )
batwidget:set_gradient_colors({ beautiful.fg_focus, beautiful.border_focus, "#00ff00" })
vicious.register(batwidget, vicious.widgets.bat, "$2", 60, "BAT0")

-- battery state
batstatetxt = widget({type = "textbox" })
vicious.register(batstatetxt, vicious.widgets.bat, "<span font_size='xx-large' > $1 </span>", 10, "BAT0")
--}}}

-- cpu {{{
cpuwidget = awful.widget.graph()
-- properties
cpuwidget:set_width(50)
cpuwidget:set_background_color( beautiful.bg_normal )
cpuwidget:set_color( beautiful.fg_focus )
cpuwidget:set_gradient_colors({ beautiful.fg_focus, beautiful.bg_focus, "#ff0000" })
-- register with vicious
vicious.register(cpuwidget, vicious.widgets.cpu, '$1')
--}}}

-- mpd {{{
mpdwidget = widget({type = "textbox" })
--mpdwidget = awful.widget.textbox()
--vicious.register(mpdwidget, vicious.widgets.mpd, "${state}: ${Artist} - ${Title}")
  vicious.register(mpdwidget, vicious.widgets.mpd,
    function (widget, args)
      if   args["{state}"] == "Stop" then return ""
      else return '<span color="' .. beautiful.fg_focus .. '">MPD:</span> '..
             args["{Artist}"]..' - '.. args["{Title}"]
      end
    end)
--}}}

-- memory {{{
memwidget = awful.widget.progressbar()
-- Progressbar properties
memwidget:set_width(20)
memwidget:set_height(20)
memwidget:set_vertical(true)
memwidget:set_background_color( beautiful.bg_normal)
memwidget:set_border_color(nil)
memwidget:set_color( beautiful.fg_focus )
memwidget:set_gradient_colors({ beautiful.fg_focus, beautiful.border_focus, "#000000" })
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, "$1", 13)
-- }}}
--}}}

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytextspacer,
            mytaglist[s],
            mytextspacer,
            mypromptbox[s],
            mytextspacer,
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        mytextspacer,
        mygmailwidget,
        mygmailicon,
        cpuwidget.widget,
        mytextspacer,
        memwidget.widget,
        mytextspacer,
        batwidget.widget,
        batstatetxt,
        mytextspacer,
        mpdwidget,
        mytextspacer,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
function floats(c)
  local ret = false
  local l = awful.layout.get(c.screen)
  if awful.layout.getname(l) == 'floating' or awful.client.floating.get(c) then
    ret = true
  end
  return ret
end

globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "p",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "n",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),




    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x", 
        function ()
            awful.prompt.run({ prompt = "Run Lua code: " },
            mypromptbox[mouse.screen].widget,
            awful.util.eval, nil,
            awful.util.getdir("cache") .. "/history_eval")
        end),

    -- call the screensaver
    awful.key({ modkey, "Mod1" }, "l", function () 
        os.execute( "xscreensaver-command --lock" )
    end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    -- Commented out because there is no way to unminimize without the mouse...
    --awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),


    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)

)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        if tags[screen][i] then
            awful.tag.viewonly(tags[screen][i])
        end
    end),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
    function ()
        local screen = mouse.screen
        if tags[screen][i] then
            awful.tag.viewtoggle(tags[screen][i])
        end
    end),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
    function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.movetotag(tags[client.focus.screen][i])
        end
    end),
    awful.key({ modkey, "Mod1"}, "#" .. i + 9,
    function ()
        if client.focus and tags[client.focus.screen][i] then
            awful.client.toggletag(tags[client.focus.screen][i])
        end
    end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = true,
            keys = clientkeys,
            buttons = clientbuttons 
        }
    },
    {
        rule = {
            class = "pinentry" 
        },
        properties = {
            floating = true }
        },
        -- let the gimp float
        {
            rule = {
                class = "gimp" 
            },
            properties = {
                floating = true 
            }
        },
        -- Set mplayer to float at startup
        {
            rule = {
                class = "MPlayer" 
            },
            properties = {
                floating = true 
            }
        },
        -- set gxmessage to float always
        {
            rule = {
                class =  "Gxmessage" 
            },
            properties = {
                floating = true 
            }
        },
        -- want the clock to always float
        {
            rule = {
                class = "XClock"
            },
            properties = {
                floating = true,
                ontop = true
            }
        }
    }

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar

    -- if c.class == "Namoroka" then
    --     awful.titlebar.add(c, { modkey = modkey })
    -- end

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
         awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

mytextclock:add_signal("mouse::leave", remove_calendar)
--mpdwidget:add_signal("mouse::leave", function()
--    mpd_info_state = nil
--    remove_mpd_info()
--end)

mytextclock:buttons({
    button({ }, 3, function()
        add_agenda()
    end),
    button({ }, 1, function()
        add_calendar(0)
    end),
    button({ }, 4, function()
        add_calendar(-1)
    end),
    button({ }, 5, function()
        add_calendar(1)
    end)
})

--mpdwidget:buttons({
--    button({ }, 1, function()
--        add_mpd_info()
--    end)
--})

-- }}}
