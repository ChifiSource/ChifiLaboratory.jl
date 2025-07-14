module ChifiSource
using Toolips
using Toolips.Components
using ToolipsSession
using ToolipsSVG
using ToolipsORM

mutable struct User
    username::String
    picture_url::String
    quickstart::Vector{String}
    fi::Int64
end

mutable struct Laboratory
    name::String
    color::String
    plates::Matrix
    user::User
    level::Int64
end

function make_styles()
    stylebody = Component{:sheet}("chisheet")
    txtboxes = Style("div.txtboxes", "border-radius" => 2px, 
    "background-color" => "#000000", "color" => "white", "font-size" => 17pt, "font-weight" => "semi-bold", "outline" => "transparent", 
    "overflow" => "hidden", "padding" => 4px, "transition" => 500ms)
    txtboxes:"focus":["border-bottom" => "2px solid #FA9EBC"]
    bttns = Style("button", "background-color" => "#39293d", "color" => "#9f93a1", 
    "font-size" => 14pt, "font-weight" => "bold", "padding" => 4px, "pointer" => "cursor", 
    "transition" => 400ms, "outline" => "transparent")
    bttns:"hover":["border-bottom" => "4px solid #FA9EBC"]
    bttns:"focus":["background-color" => "#FA9EBC"]
    paragraphs = Style("p", "font-size" => 15pt, "color" => "white")
    maintitle = title("met-title", text = "chifi laboratory")
    push!(stylebody, txtboxes, bttns, paragraphs, maintitle)
    stylebody
end

function chilogo()
    chiwindow = svg("chi", width = 100percent, height = 210, align = "center")
                                                               # lol or &chi; &phi;
    chitxt = Component{:text}("chimin", x = "0", y = "105", text = "&#967;&#966;")
    style!(chitxt, "transition" => 500ms, "stroke" => "#1e1e1e", "stroke-width" => 2pt, "font-size" => 75pt, "fill" => "white")
    push!(chiwindow, chitxt)
    style!(chiwindow, "margin-top" => 10percent, "opacity" => 0percent, "transform" => "translateY(10%)", 
    "transition" => 2seconds, "margin-left" => 40percent)
    chiwindow
end

function lines_bg()
    lines = svg("linesbg", width = 8000, height = 1800, align = "center")
    style!(lines, "position" => "absolute", "top" => 0px, "left" => 0px, "pointer-events" => "none", 
    "z-index" => "-7", "opacity" => 20percent, "transition" => 3000seconds)
    xnum = 10000
    ynum = 10000
    division_amountx::Int64 = round(xnum / 50)
    division_amounty::Int64 = round(ynum / 50)
    [begin
        l = ToolipsSVG.line("t", x1 = xcoord, y1 = 0, x2 = xcoord, y2 = 5000)
        style!(l, "stroke" => "darkgray", "stroke" => "333333", "stroke-width" => 1px, "transition" => "500ms")
        l2 = ToolipsSVG.line("t", x1 = 0, y1 = ycoord, x2 = 5000, y2 = ycoord)
        style!(l2, "stroke" => "darkgray", "stroke" => "333333", "stroke-width" => 1px, "transition" => "500ms")
        push!(lines, l, l2)
    end for (xcoord, ycoord) in zip(
    range(1, xnum,
    step = division_amountx), range(1, ynum, step = division_amounty))]
    lines
end

theme_colors = ["#79B7CE", "#FE86C7", "#C178B5", "#F9C800", "#E24E40"]

function ql_load!(f::Function, c::Toolips.AbstractConnection, cm::ComponentModifier, ql::Component{:div}, n::Int64 = 5)
    n += 1
    if n == 6
        f(cm)
        style!(cm, "qscounter", "transition" => 0seconds)
        cm["qscounter"] = "ontransitionend" => "nothing"
        set_text!(cm, "met-title", "laboratory")
        return
    end
    set_text!(cm, "met-title", "quickstart | $(6 - n)")
    set_text!(cm, "qscounter", string(n))
    style!(cm, "qscounter", "color" => theme_colors[n])
    next!(c, cm, ql[:children]["qscounter"]) do cm2::ComponentModifier
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
    next!(c, cm, labcirc) do cm::ComponentModifier
        style!(cm, lab_text, "opacity" => 100percent)
        style!(cm, doccirc, "opacity" => 100percent, 
        "transition" => 1seconds)
        labspin(c, cm, doccirc)
        log = login_wind(c, cm)
        append!(cm, "chimain", log)
        next!(c, cm, lab_text) do cm2::ComponentModifier
            style!(cm2, "login-window", "height" => 45percent, "opacity" => 93percent)
            focus!(cm2, "loginbox")
        end
    end
end

standard_txtbind!(c::Toolips.AbstractConnection, cm::ComponentModifier, comp::Component{<:Any}, 
nextcomp::Component{<:Any}, lastcomp::Any = nothing; only::Vector{String} = Vector{String}()) = begin
    km = ToolipsSession.KeyMap()
    bind!(km, "Enter", prevent_default = true) do cm::ComponentModifier
        focus!(cm, nextcomp)
    end
    if ~(isnothing(lastcomp))
        bind!(km, "ArrowUp", prevent_default = true) do cm::ComponentModifier
            focus!(cm, lastcomp)
        end
    end
    bind!(c, cm, comp, km, only)
end

function login_wind(c::Toolips.AbstractConnection, cm::ComponentModifier)
    outerwind = div("login-window", align = "left")
    loginh = h("loginh", 2, text = "username")
    loginbox = textdiv("loginbox", text = "")
    loginbox[:class] = "txtboxes"
    pwdbox = textdiv("pwdbox", text = "")
    standard_txtbind!(c, cm, loginbox, pwdbox)
    pwdbox[:class] = "txtboxes"
    keybox = textdiv("keybox", text = "")
    on(c, keybox, "paste", ["rawkeybox"]) do cm::ComponentModifier
        focus!(cm, submb)
    end
    keybox[:class] = "txtboxes"
    style!(keybox, "color" => "#331e38")
    style!(loginh, "font-size" => 17pt, "color" => "white")
    pwdh = h("pwdh", 2, text = "password")
    style!(pwdh, "font-size" => 17pt, "color" => "white")
    keyh = h("keyh", 2, text = "key")
    style!(keyh, "font-size" => 17pt, "color" => "#d696d1")
    style!(outerwind, "width" => 20percent, "height" => 0percent, "top" => 32percent,
    "opacity" => 0percent, "background-color" => "#28282B", "position" => "absolute", "left" => 39percent,
    "transition" => 750ms, "border-radius" => 2px, "padding" => 20px)
    requestb = button("requestb", text = "request key")
    style!(requestb, "width" => 50percent)
    helpb = button("helpb", text = "?")
    style!(helpb, "width" => 50percent)
    submb = button("submitb", text = "submit")
    standard_txtbind!(c, cm, pwdbox, submb, loginbox, only = ["loginbox", "pwdbox"])
    standard_txtbind!(c, cm, keybox, submb, pwdbox, only = ["keybox"])
    style!(submb, "width" => 100percent)
    on(c, submb, "focus") do cm::ComponentModifier
        [println(c.name) for c in cm.rootc]
        rawname = cm["loginbox"]["text"]
        if length(rawname) < 3
            key = cm["keybox"]["text"]
            alert!(cm, key)
            return
        end
        alert!(cm, rawname)
        blur!(cm, sumbmb)
    end
    rule = Component{:hr}()
    style!(rule, "margin-bottom" => 12px)
    ortxt = p("ortxt", text = "or", align = "center")
    style!(ortxt, "font-weight" => "bold")
    style!(ortxt, "margin-top" => 8px, "margin-bottom" => 0px)
    push!(outerwind, loginh, loginbox, pwdh, pwdbox, ortxt, rule, keyh, keybox, rule, helpb, requestb,
    br(), submb)
    outerwind
end

function labspin(c::Connection, cm::ComponentModifier, docc::Component{:circle})
    rot = rand(230:252)
    color = theme_colors[rand(1:5)]
    arclen = 2 * π * (50 - 10)
    perc = rand(15:65)
    strk = rand(8:28)
    arc = Int64(round(arclen * ((100 - perc)/100)))
    darray = rand(150:300)
    style!(cm, docc, "transform" => "rotate($(rot)deg)", "stroke" => color, 
    "stroke-dashoffset" => "$(arc)px", "stroke-dasharray" => "$(darray)px", 
    "stroke-width" => "$(strk)px")
    next!(c, cm, docc) do cm::ComponentModifier
        labspin(c, cm, docc)
    end
end

function quickstart_splash(c::Connection)
    mainbody = body("chimain", align = "center")
    style!(mainbody, "opacity" => 0percent, "overflow" => "hidden", 
    "transition" => 1500ms)
    splash_chitext::Component{:svg} = chilogo()
    linesb = lines_bg()
    push!(mainbody, linesb, splash_chitext, br(), chi_footer())
    on(c, mainbody, "load") do cm::ComponentModifier
        style!(cm, "chimain", "opacity" => 100percent)
        style!(cm, splash_chitext, "opacity" => 100percent, "transform" => "translateY(0%)")
        next!(c, cm, splash_chitext) do cm1::ComponentModifier
            style!(cm1, "linesbg", "transform" => "translateX(-15000px)")
            next!(c, cm1, "linesbg") do cm::ComponentModifier
                #TODO timeout easter egg?
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

function keysearch(c::Connection)
    nothing
end

function home(c::Connection)
    write!(c, make_styles())
    args = get_args(c)
    key = ""
    if ~(:key in keys(args))
        key = keysearch(c)
        if isnothing(key)
            initbody::Component{:body} = quickstart_splash(c)
            write!(c, initbody)
            return
        end
    else
        key = args[:key]
    end
    name = c[:Laboratories][args[:key]]
    initbody = quickstart_splash(c)
end

fourofour = route("404") do c
    write!(c, p("404message", text = "404, not found!"))
end
home_r = route(home, "/")
"""
start(IP::String, PORT::Integer, ) -> ::ToolipsServer
--------------------
The start function starts the WebServer.
"""
function start(IP::String = "127.0.0.1", PORT::Integer = 8000)
     start!(ChifiSource, IP:PORT)
end
logg = Toolips.Logger()

SES = Session()
files = mount("/" => "public")

export files, home_r, fourofour, logg, SES
end # - module
        