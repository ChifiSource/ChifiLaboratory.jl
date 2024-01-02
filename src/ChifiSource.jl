module ChifiSource
using Toolips
using ToolipsSession
using ToolipsMarkdown
using ToolipsSVG

temp_udata = Dict("emma" => Dict(
    "purl" => "/", "quickstart" => ["creator", "lab0builder"], 
"fi" => 1))

mutable struct User
    username::String
    picture_url::String
    quickstart::Vector{String}
    fi::Int64
end

mutable struct Laboratory <: Toolips.Servable
    name::String
    color::String
    plates::Matrix
    user::User
    level::Int64
end

mutable struct Laboratories <: Toolips.ServerExtension
    type::Symbol
    active::Vector{Laboratory}
    users::Vector{User}
    keys::Dict{String, String}
    Laboratories() = new(:connection, Vector{Laboratory}(), 
    users::Vector{User}, keys::Dict{String, String})
end

struct LabModule{T <: Any}
end

module_color(eco::LabModule{:lab0builder}) = "#79B7CE"

module_color(eco::LabModule{:fi}) = "#C178B5"

module_color(eco::LabModule{:module0deck}) = "#79B7CE"

module_color(eco::LabModule{:share0my0repl}) = "#79B7CE"

module_color(eco::LabModule{:accessories}) = "#79B7CE"

module_color(eco::LabModule{:creator}) = "#FE86C7"

module_color(eco::LabModule{:doc}) = "#FE86C7"

load_module!(s::String) = load_module(LabModule{Symbol(s)}())

function load_module!(lm::LabModule{:fi})

end

function load_module!(lm::LabModule{:lab0builder})
    
end

function load_module!(lm::LabModule{:creator})
    
end


mutable struct UserConnection <: Toolips.AbstractConnection
    hostname::String
    routes::Vector{Toolips.AbstractRoute}
    extensions::Vector{Toolips.ServerExtension}
    user::User
    function UserConnection(c::Connection, name::String)
        usr = User(tempudata[name], tempudata["purl"], 
        tmp_udata["quickstart"], tmpudata["fi"])
        new(c.hostname, c.routes, c.extensions, usr)
    end
end

#==
UI
==#
function chilogo()
    chiwindow = svg("chi", width = 250, height = 135, align = "center")
    chitxt = ToolipsSVG.text("chitxt", x = 70, y = 70, text = "chifi")
    style!(chitxt, "font-weight" => "extra-bold", "fill" => "white", "stroke-width" => 2px, 
    "stroke" => "black", "font-size" => 70pt)
    push!(chiwindow, chitxt)
    style!(chiwindow, "margin-top" => 10percent)
 #   style!(chiwindow, "opacity" => 0percent)
    chiwindow
end

function build_quickstart(c::Connection)
    quickstart_main = circle("labcirc", cx = 93, cy = 105, r = 20)
    style!(quickstart_main, "fill" => "#79B7CE")
    doc = circle("docmodule", cx = 140, cy = 105, r = 20)
    style!(doc, "fill" => module_color(LabModule{:doc}()))
    [quickstart_main, doc]
end

function build_quickstart(c::UserConnection)

end


function quickstart_splash(c::Connection)
    mainbody = body("chimain", align = "center")
    splash_chitext::Component{:svg} = chilogo()
    quicklaunch = build_quickstart(c)
    splash_chitext[:children] = vcat(splash_chitext[:children], quicklaunch)
    push!(mainbody, splash_chitext, br(), chi_footer())
    mainbody::Component{:body}
end

function chi_footer()
    footdiv = div("chifoot")
    style!(footdiv, "position" => "absolute", "background" => "transparent", "top" => 95percent, "left" => 82percent, 
    "opacity" => 50percent, "display" => "flex")
    footlicense = a("chifooter", text = "creative commons (attribution) |   ")
    push!(footdiv, footlicense)
    [push!(footdiv, img("lice", src = src, width = 20)) for src in ("/images/icons/cc.png", "/images/icons/by.png")]
    srclnk = a("chisrc", href = "https://github.com/ChifiSource/ChifiSource.jl",text = " | source")
end

function login_container()

end

function build_lab(c::Connection)

end

function save_lab(s::String, lab::Laboratory)

end

function home(c::Connection)
    args = getargs(c)
    if ~(:key in keys(args))
        initbody::Component{:body} = quickstart_splash(c)
    else
        try
            name = c[:Laboratories][args[:key]]
            uc = UserConnection(c, name)
            initbody = quickstart_splash(uc)
        catch
            initbody = quickstart_splash(c)
        end
    end
    write!(c, initbody)
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
        