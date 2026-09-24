local a=getgenv()
local b=a["xQ7mP2"]

if type(a)~="table"
or type(b)~="table"
then
    return
end

local c=b.a
local d=b.b
local e=b.c

if type(c)~="string"
or type(d)~="string"
or type(e)~="string"
or c==""
or d==""
or e==""
then
    return
end

local f,h=pcall(function()
    return request({
        Url="https://YOUR-DOMAIN.vercel.app/api/loader",
        Method="POST",
        Headers={
            ["Content-Type"]="application/json"
        },
        Body=
            '{"a":"'..c..
            '","b":"'..d..
            '","c":"'..e..'"}'
    })
end)

if not f
or type(h)~="table"
or h.StatusCode~=200
or h.Body~="OK"
then
    return
end

print("pass")
