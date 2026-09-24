import crypto from "node:crypto"

const a=process.env.LOADER_SECRET
const b=120

function c(n=32){
    return crypto.randomBytes(n).toString("base64url")
}

function d(x){
    return crypto.createHash("sha256").update(x).digest("hex")
}

function e(x){
    return crypto.createHmac("sha256",a).update(x).digest("base64url")
}

function f(x,y){
    const z=Date.now().toString()
    const q=c(48)
    const r=`${x}.${y}.A.${z}.${q}`
    return `${r}.${e(r)}`
}

async function g(x){
    const y=await fetch(
        `${process.env.UPSTASH_REDIS_REST_URL}/pipeline`,
        {
            method:"POST",
            headers:{
                Authorization:`Bearer ${process.env.UPSTASH_REDIS_REST_TOKEN}`,
                "Content-Type":"application/json"
            },
            body:JSON.stringify([x])
        }
    )

    if(!y.ok)throw new Error()

    const z=await y.json()
    return z[0]?.result
}

export default async function handler(req,res){
    try{
        if(req.method==="POST"){
            const x=req.body||{}
            const y=String(x.a||"")
            const z=String(x.b||"")
            const q=String(x.c||"")

            if(!y||!z||!q)
                return res.status(404).send("")

            const r=await g(["GET",`x:${y}`])

            if(!r)
                return res.status(404).send("")

            const s=JSON.parse(r)

            if(
                s.a!==y||
                s.b!==d(z)||
                s.c!==d(q)||
                s.e!=="B"||
                Date.now()-Number(s.f)>b*1000
            )
                return res.status(404).send("")

            await g(["DEL",`x:${y}`])

            return res.status(200).send("OK")
        }

        const x=String(req.query.id||"")

        if(!/^[A-Za-z0-9_-]+$/.test(x))
            return res.status(404).send("")

        const y=c(32)
        const z=c(64)
        const q=f(x,y)

        await g([
            "SET",
            `x:${y}`,
            JSON.stringify({
                a:y,
                b:d(z),
                c:d(q),
                e:"A",
                f:Date.now()
            }),
            "EX",
            b
        ])

        const u=
            `https://${req.headers.host}/api/gate`+
            `?id=${encodeURIComponent(x)}`+
            `&token=${encodeURIComponent(q)}`

        const lua=`
local a=getgenv()

local b=game:GetService("CoreGui")
local c=game:GetService("Players")
local d=c.LocalPlayer

if not b
or not c
or not d
or typeof(b)~="Instance"
or typeof(c)~="Instance"
or typeof(d)~="Instance"
or b.ClassName~="CoreGui"
then
    return
end

a["xQ7mP2"]={
    a="${y}",
    b="${z}",
    c="${q}"
}

local e,h=pcall(function()
    return request({
        Url="${u}",
        Method="GET"
    })
end)

if not e
or type(h)~="table"
or h.StatusCode~=200
or type(h.Body)~="string"
or #h.Body<1
then
    return
end

local f=loadstring(h.Body,"@x")

if type(f)~="function" then
    return
end

return f()
`

        res.setHeader("Content-Type","text/plain; charset=utf-8")
        res.setHeader("Cache-Control","no-store")
        return res.status(200).send(lua)
    }catch{
        return res.status(404).send("")
    }
           }
