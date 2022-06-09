function main(routes::Vector{Route})
    server = ServerTemplate(IP, PORT, routes, extensions = extensions)
    server.start()
end
logo = img("logo",
src = "https://miro.medium.com/max/1400/1*g8occ41KmaUIAdBuU9uXig.jpeg")

header = Toolips.div("header", [logo])
header[:align] = "center"
github_browser = route("/") do c
    write!(c, header)
end
fourofour = route("404", p("404", text = "404, not found!"))
rs = routes(github_browser, fourofour)
main(rs)
