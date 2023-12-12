module ChifiSource
using Toolips
using ToolipsSession
using ToolipsMarkdown

mutable struct Ecosystem{T <: Any}
    name::String
    Ecosystem(T::String) = new{Symbol(T)}(T)
end

ecocolor(eco::Ecosystem{:toolips}) = "#79B7CE"

ecocolor(eco::Ecosystem{:olive}) = "#FE86C7"

ecocolor(eco::Ecosystem{:gattino}) = "#C178B5"

ecocolor(eco::Ecosystem{:algia}) = "#F9C800"

ecocolor(eco::Ecosystem{:tumble}) = "#E24E40"

ecocolor(eco::Ecosystem{:chifi}) = "#232b2b"

function welcome_page(c::Connection, eco::Ecosystem{<:Any})
    econame = eco.name
    rawmd = read("text/main/$econame/$econame.md", String) 
    tmd("$econame-main", rawmd)
end

function logomenu(c::Connection, width::Int64 = 350)
    logobox = div("logobox", align = "center")
    topbox = div("topbox", align = "center")
    barbox = div("barbox")
    style!(logobox, "transition" => 2seconds)
    push!(logobox, topbox, barbox)
    style!(barbox, "background" => "transparent", "width" => width * px, "transition" => 1seconds)
    style!(topbox, "background-color" => "black", "width" => width * px, "height" => 120px, "border-top-left-radius" => 5px, "border-top-right-radius" => 5px, 
    "transition" => 1seconds)
    chitext = a("ex", text = "chifi")
    style!(chitext, "font-weight" => "bold", "font-size" => 50pt, "color" => "white")
    push!(topbox, chitext)
    ecos::Vector{Ecosystem{<:Any}} = [Ecosystem(s) for s in ("tumble", "gattino", "algia", "olive", "toolips", "chifi")]
    ecow::Number = 100 / length(ecos)
    barbox[:children] = Vector{Servable}([begin
        name::String = eco.name
        color::String = ecocolor(eco)
        comp::Component{:div} = div("$name", align = "center", class = "menublock")
        style!(comp, "background-color" => color, "width" => "$ecow%", "height" => 40px, 
        "display" => "inline-block", "transition" => 1seconds)
        innerimg = img("$(name)icon", src = "/images/icons/$name.png", width = "40", class = "menuicon")
        push!(comp, innerimg)
        on(c, comp, "click") do cm::ComponentModifier
            style!(cm, topbox, "background-color" => color)
            set_text!(cm, chitext, name)
            style!(cm, "mainbod", "background-color" => color)
            page_content = welcome_page(c, eco)
            append!(cm, "mainbod", page_content)
        end
        comp
    end for eco in ecos])
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
        