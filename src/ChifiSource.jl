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

module_color(eco::LabModule{:doc}) = "#444444"

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

function make_styles()
    stylebody = Component("chisheet", "sheet")
    stylebody
end

function chilogo()
    chiwindow = svg("chi", width = 100percent, height = 210, align = "center")
    chitxt = Component("chimin", "image")
    style!(chitxt, "transition" => 500ms)
    chitxt[:href] = "/images/chimin.png"
    chitxt[:x], chitxt[:y] = 1, 1
    push!(chiwindow, chitxt)
    style!(chiwindow, "margin-top" => 10percent, "opacity" => 0percent, "transform" => "translateY(10%)", 
    "transition" => 2seconds, "margin-left" => 40percent)
    chiwindow
end

function lines_bg()
    lines = svg("linesbg", width = 8000, height = 1800, align = "center")
    style!(lines, "position" => "absolute", "top" => 0px, "left" => 0px, "pointer-events" => "none", 
    "z-index" => "-7", "opacity" => 20percent, "transition" => 600seconds)
    division_amountx::Int64 = round(5000 / 50)
    division_amounty::Int64 = round(5000 / 50)
    [begin
        l = ToolipsSVG.line("t", x1 = xcoord, y1 = 0, x2 = xcoord, y2 = 5000)
        style!(l, "stroke" => "darkgray", "stroke" => "333333", "stroke-width" => 1px, "transition" => "500ms")
        l2 = ToolipsSVG.line("t", x1 = 0, y1 = ycoord, x2 = 5000, y2 = ycoord)
        style!(l2, "stroke" => "darkgray", "stroke" => "333333", "stroke-width" => 1px, "transition" => "500ms")
        push!(lines, l, l2)
    end for (xcoord, ycoord) in zip(
    range(1, 5000,
    step = division_amountx), range(1, 5000, step = division_amounty))]
    lines
end

function build_quickstart(c::Connection)
    quickstart_main = circle("labcirc", cx = 50, cy = 175, r = 20)
    style!(quickstart_main, "fill" => "#000000", "transition" => 1700ms, "transform" => "translateX(1500px)")
    doc = circle("docmodule", cx = 100, cy = 175, r = 20)
    style!(doc, "fill" => module_color(LabModule{:doc}()), "transition" => 2seconds, "transform" => "translateX(1500px)")
    [quickstart_main, doc]
end

function build_quickstart(c::UserConnection)

end

function quickstart_loader()
    prea = a("loadpre", text = "quickstart | starting Laboratory in ")
    numberheading = a("qscounter", text = "1")
    style!(numberheading, "color" => "#79B7CE", "font-size" => 22pt, "font-weight" => "bold", 
    "transition" => 1seconds)
    na = a("enda", text = " / 5 ...")
    style!(prea, "color" => "#222222", "font-size" => 18pt)
    style!(na, "color" => "#222222", "font-size" => 18pt, "font-weight" => "bold")
    qsloader = div("qsloader")
    style!(qsloader, "opacity" => 0percent, "transition" => 3seconds)
    push!(qsloader, prea, numberheading, na)
    qsloader
end

theme_colors = ["#79B7CE", "#FE86C7", "#C178B5", "#F9C800", "#E24E40"]

function ql_load!(f::Function, c::Toolips.AbstractConnection, cm::ComponentModifier, ql::Component{:div}, n::Int64 = 5)
    n += 1
    if n == 6
        f(cm)
        return
    end
    set_text!(cm, "qscounter", string(n))
    style!(cm, "qscounter", "color" => theme_colors[n])
    next!(c, ql[:children]["qscounter"], cm, ["none"]) do cm2::ComponentModifier
        ql_load!(f, c, cm2, ql, n)
    end
end

function lab_in(c::Connection, cm::ComponentModifier, labcirc::Component{:circle},
    doccirc::Component{:circle})
    lab_text = img("labmin", src = "/images/labmin.png", width = 400)
    style!(lab_text, "position" => "absolute", "top" => 38percent, 
    "left" => 40percent, "transition" => 500ms, "opacity" => 0percent)
    style!(cm, "chi", "transition" => 0seconds)
    cm["chi"] = "height" => "300"
    append!(cm, "chimain", lab_text)
    cm["labcirc"] = "r" => 100
    center = 100 / 2
    radius = center - 10 
    arclen = 2 * π * radius
    arc = Int64(round(arclen * ((100 - 20)/100)))
    cm[doccirc] = "cx" => "185"
    cm[doccirc] = "r" => "100"
    style!(cm, doccirc, "fill" => "transparent", 
        "stroke-width" => 0px, "stroke" => "lightblue", "transition" => 2seconds, 
        "z-index" => "20", 
        "stroke-dasharray" => 251px, "stroke-dashoffset" => "$(arc)px")
    next!(c, labcirc, cm, ["none"]) do cm::ComponentModifier
        style!(cm, lab_text, "opacity" => 100percent)
        style!(cm, doccirc, "opacity" => 100percent, 
        "transition" => 1seconds)
        setting = true
        labspin(c, cm, doccirc, setting)
        append!(cm, "chimain", login_wind(c, setting))
        next!(c, lab_text, cm, ["none"]) do cm2::ComponentModifier
            style!(cm2, "login-window", "height" => 30percent, "opacity" => 100percent)
        end
    end
end

function login_wind(c::Toolips.AbstractConnection, setting::Bool)
    outerwind = div("login-window", align = "left")
    loginh = h("loginh", 2, text = "username")
    style!(loginh, "font-size" => 17pt, "color" => "white")
    pwdh = h("pwdh", 2, text = "password")
    style!(pwdh, "font-size" => 17pt, "color" => "white")
    keyh = h("keyh", 2, text = "key")
    style!(keyh, "font-size" => 17pt, "color" => "#79437d")
    style!(outerwind, "width" => 12percent, "height" => 0percent, "margin-left" => 44percent, 
    "opacity" => 0percent, "background-color" => "#1c1c1b",
    "transition" => 700ms, "padding" => 4px, "border-radius" => 2px, "padding" => 6px)
    requestb = button("requestb", text = "request key")
    style!(requestb, "width" => 50percent)
    helpb = button("helpb", text = "?")
    style!(helpb, "width" => 50percent)
    submb = button("submitb", text = "submit")
    style!(submb, "width" => 100percent)
    push!(outerwind, loginh, pwdh, Component("", "hr"), keyh,  Component("", "hr"), helpb, requestb,
    br(), submb)
    outerwind
end

function labspin(c::Connection, cm::ComponentModifier, docc::Component{:circle}, setting::Bool)
    rot = rand(200:280)
    color = theme_colors[rand(1:5)]
    arclen = 2 * π * (50 - 10)
    perc = rand(1:100)
    strk = rand(8:20)
    arc = Int64(round(arclen * ((100 - perc)/100)))
    darray = rand(150:300)
    style!(cm, docc, "transform" => "rotate($(rot)deg)", "stroke" => color, 
    "stroke-dashoffset" => "$(arc)px", "stroke-dasharray" => "$(darray)px", 
    "stroke-width" => "$(strk)px")
    if setting == false
        return
    end
    next!(c, docc, cm) do cm::ComponentModifier
        labspin(c, cm, docc, setting)
    end
end

function quickstart_splash(c::Connection)
    mainbody = body("chimain", align = "center")
    style!(mainbody, "opacity" => 0percent, "overflow" => "hidden", 
    "transition" => 1500ms)
    splash_chitext::Component{:svg} = chilogo()
    quicklaunch = build_quickstart(c)
    splash_chitext[:children] = vcat(splash_chitext[:children], quicklaunch)
    linesb = lines_bg()
    push!(mainbody, linesb, splash_chitext, br(), chi_footer())
    on(c, mainbody, "load", ["none"]) do cm::ComponentModifier
        style!(cm, "chimain", "opacity" => 100percent)
        style!(cm, splash_chitext, "opacity" => 100percent, "transform" => "translateY(0%)")
        ql = quickstart_loader()
        append!(cm, "chimain", ql)
        next!(c, splash_chitext, cm, ["none"]) do cm1::ComponentModifier
            style!(cm1, "linesbg", "transform" => "translateX(-8000px)")
            style!(cm1, "qsloader", "opacity" => 100percent)
            [style!(cm1, launch, "transform" => "translateX(0%)") for launch in quicklaunch]
            responded = false
            next!(c, ql, cm1, ["none"]) do cm2::ComponentModifier
                if responded
                    return
                end
                ql_load!(c, cm2, ql, 1) do cm::ComponentModifier
                    style!(cm, "chimain", "background-color" => "#222222")
                    [begin
                        cm[comp] = "cx" => "185"
                        style!(cm, comp, "transition" => 1200ms)
                        if e > 1
                            style!(cm, comp, "opacity" => 0percent)
                        end
                    end for (e, comp) in enumerate(quicklaunch)]
                    style!(cm, splash_chitext[:children][1], "opacity" => 0percent, "transform" => "translateY(-4%)")
                    remove!(cm, "loadpre")
                    remove!(cm, "enda")
                    set_text!(cm, "qscounter", "loading laboratory")
                    next!(c, quicklaunch[1], cm, ["none"]) do cm2::ComponentModifier
                        style!(cm2, "qscounter", "opacity" => 0percent)
                        remove!(cm2, "chimin")
                        lab_in(c, cm2, quicklaunch[1], quicklaunch[2])
                    end
                end
                responded = true
            end
        end
    end
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
    style!(srclnk, "color" => "green")
    push!(footdiv, srclnk)
    footdiv
end

function login_container()

end

function build_lab(c::Connection)

end

function save_lab(s::String, lab::Laboratory)

end

function home(c::Connection)
    write!(c, make_styles())
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
        