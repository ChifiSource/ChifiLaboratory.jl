module ChifiSource
using Toolips
using ToolipsSession

function logomenu(c::Connection)
    logobox = div("logobox", align = "center")
    topbox = div("topbox", align = "center")
    barbox = div("barbox")
    push!(logobox, barbox, topbox)
    style!(barbox, "background" => "transparent", "width" => 350px)
    style!(topbox, "background-color" => "black", "width" => 350px, "height" => 120px)
    chitext = a("ex", text = "chifi")
    style!(chitext, "font-weight" => "bold", "font-size" => 50pt, "color" => "white")
    push!(topbox, chitext)
    colors = Dict("toolips" => "#79B7CE", "olive" => "#FE86C7", "gattino" => "#C178B5", "algia" => "#F9C800", "tumble" => "#E24E40")
    barbox[:children] = Vector{Servable}([begin
        comp = div("$econame")
        style!(comp, "background-color" => colors[econame], "width" => 20percent, "height" => 40px, 
        "display" => "inline-block", "transition" => 1seconds)
        on(c, comp, "click") do cm::ComponentModifier
            style!(cm, comp, "height" => 70px)
        end
        comp
    end for econame in ("toolips", "olive", "gattino", "algia", "tumble")])
    logobox
end

function home(c::Connection)
    mainbod = body("mainbod")
    style!(mainbod, "margin-top" => 40percent, "overflow" => "hidden")
    logom = logomenu(c)
    footdiv = div("chifoot")
    style!(footdiv, "position" => "absolute", "background" => "transparent", "top" => 95percent, "left" => 85percent, 
    "opacity" => 50percent, "display" => "flex")
    footlicense = a("chifooter", text = "creative commons (attribution)")
    push!(footdiv, footlicense)
    [push!(footdiv, img("lice", src = src, width = 20)) for src in ("/images/icons/cc.png", "/images/icons/by.png")]
    push!(mainbod, logom, footdiv)
    write!(c, mainbod)
end

fourofour = route("404") do c
    write!(c, p("404message", text = "404, not found!"))
end

routes = [route("/", home), fourofour]
extensions = Vector{ServerExtension}([Logger(), Files(), Session(), ])
"""
start(IP::String, PORT::Integer, ) -> ::ToolipsServer
--------------------
The start function starts the WebServer.
"""
function start(IP::String = "127.0.0.1", PORT::Integer = 8000)
     ws = WebServer(IP, PORT, routes = routes, extensions = extensions)
     ws.start(); ws
end
end # - module
        