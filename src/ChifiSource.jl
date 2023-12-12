module ChifiSource
using Toolips
using ToolipsSession

mutable struct Ecosystem{T <: Any}
    Ecosystem(T::String) = new{T}()
end

color(eco::Ecosystem{:toolips}) = "#79B7CE"

color(eco::Ecosystem{:olive}) = "#FE86C7"

color(eco::Ecosystem{:gattino}) = "#79B7CE"

color(eco::Ecosystem{:algia}) = "#79B7CE"

color(eco::Ecosystem{:tumble}) = "#79B7CE"

function welcome_page(c::Connection, eco::Ecosystem{:toolips})

end

function welcome_page(c::Connection, eco::Ecosystem{:olive})

end

function welcome_page(c::Connection, eco::Ecosystem{:gattino})

end

function welcome_page(c::Connection, eco::Ecosystem{:algia})

end

function welcome_page(c::Connection, eco::Ecosystem{:tumble})

end

function logomenu(c::Connection)
    logobox = div("logobox", align = "center")
    topbox = div("topbox", align = "center")
    barbox = div("barbox")
    style!(logobox, "transition" => 2seconds)
    push!(logobox, topbox, barbox)
    style!(barbox, "background" => "transparent", "width" => 350px, "transition" => 1seconds)
    style!(topbox, "background-color" => "black", "width" => 350px, "height" => 120px, "border-top-left-radius" => 5px, "border-top-right-radius" => 5px, 
    "transition" => 1seconds)
    chitext = a("ex", text = "chifi")
    style!(chitext, "font-weight" => "bold", "font-size" => 50pt, "color" => "white")
    push!(topbox, chitext)
    colors = Dict("toolips" => "#79B7CE", "olive" => "#FE86C7", "gattino" => "#C178B5", "algia" => "#F9C800", "tumble" => "#E24E40")
    barbox[:children] = Vector{Servable}([begin
        comp = div("$econame", align = "center", class = "menublock")
        style!(comp, "background-color" => colors[econame], "width" => 20percent, "height" => 40px, 
        "display" => "inline-block", "transition" => 1seconds)
        innerimg = img("$(econame)icon", src = "/images/icons/$econame.png", width = "40", class = "menuicon")
        push!(comp, innerimg)
        on(c, comp, "click") do cm::ComponentModifier
            style!(cm, topbox, "background-color" => colors[econame])
            set_text!(cm, chitext, econame)
            style!(cm, "mainbod", "background-color" => colors[econame])
        end
        comp
    end for econame in ("toolips", "olive", "gattino", "algia", "tumble")])
    logobox
end

function home(c::Connection)
    menblocks = Style("div.menublock")
    ico = Style("img.menuicon")
    menblocks:"hover":["transform" => "matrix(1, 0, 0, 1, 0, 3)"]
    ico:"hover":["transform" => "scale(1.1)"]
    write!(c, menblocks, ico)
    mainbod = body("mainbod")
    style!(mainbod, "margin-top" => 10percent, "overflow" => "hidden", "transition" => 1seconds)
    logom = logomenu(c)
    footdiv = div("chifoot")
    style!(footdiv, "position" => "absolute", "background" => "transparent", "top" => 95percent, "left" => 82percent, 
    "opacity" => 50percent, "display" => "flex")
    footlicense = a("chifooter", text = "creative commons (attribution) |   ")
    push!(footdiv, footlicense)
    [push!(footdiv, img("lice", src = src, width = 20)) for src in ("/images/icons/cc.png", "/images/icons/by.png")]
    srclnk = a("chisrc", href = "https://github.com/ChifiSource/ChifiSource.jl",text = " | source")
    style!(srclnk, "color" => "green")
    push!(footdiv, srclnk)
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
        