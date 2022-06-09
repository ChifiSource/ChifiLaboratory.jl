function main(routes::Vector{Route})
    server = ServerTemplate(IP, PORT, routes, extensions = extensions)
    server.start()
end

include("ProjectElement.jl")

logo = img("logo",
src = "https://miro.medium.com/max/1400/1*g8occ41KmaUIAdBuU9uXig.jpeg")

# Header
header = Toolips.div("header", [logo])
header[:align] = "center"

# Main organization browser
github_browser = route("/") do c
    write!(c, header)
end

# Errors:
fourofour = route("404") do

end

# Overview:
overview = route("/overview") do c

end
rs = routes(github_browser, fourofour, overview)
main(rs)
