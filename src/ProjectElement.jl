using HTTP

function rdata(url::String = "https://api.github.com/orgs/ChifiSource/repos")
    r = HTTP.request("GET", url)
    rds = [RepoData(d) for d in items]
end

function string_to_array(s::String)
    s = replace(s, "[" => "")
    s = replace(s, "]" => "")
    split(s, ",")
end


mutable struct RepoData
    name::Any
    desc::Any
    url::Any
    language::Any
    stars::Any
    tags::Array
end
