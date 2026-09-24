import crypto from "node:crypto"

const a=process.env.LOADER_SECRET
const b=60
const c=120

function d(x){
    return crypto.createHash("sha256").update(x).digest("hex")
}

function e(x){
    return crypto.createHmac("sha256",a).update(x).digest("base64url")
}

function f(x,y){
    const z=x.split(".")

    if(z.length!==6)
        return null

    const[q,r,s,t,u,v]=z

    if(
        q!==y||
        s!=="A"||
        !r||
        !u||
        !/^\d+$/.test(t)
    )
        return null

    const w=`${q}.${r}.${s}.${t}.${u}`
    const k=e(w)

    const m=Buffer.from(v)
    const n=Buffer.from(k)

    if(
        m.length!==n.length||
        !crypto.timingSafeEqual(m,n)
    )
        return null

    const age=Date.now()-Number(t)

    if(age<0||age>b*1000)
        return null

    return r
}

function g(x,y){
    const z=Date.now().toString()
    const q=crypto.randomBytes(64).toString("base64url")
    const r=`${x}.${y}.B.${z}.${q}`

    return `${r}.${e(r)}`
}

async function h(x){
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
        const x=String(req.query.id||"")
        const y=String(req.query.token||"")

        if(
            !a||
            !/^[A-Za-z0-9_-]+$/.test(x)
        )
            return res.status(404).send("")

        const z=f(y,x)

        if(!z)
            return res.status(404).send("")

        const q=`x:${z}`
        const r=await h(["GET",q])

        if(!r)
            return res.status(404).send("")

        const s=JSON.parse(r)

        if(
            s.a!==z||
            s.e!=="A"||
            s.c!==d(y)||
            Date.now()-Number(s.f)>c*1000
        )
            return res.status(404).send("")

        const t=g(x,z)

        await h([
            "SET",
            q,
            JSON.stringify({
                a:z,
                b:s.b,
                c:d(t),
                e:"B",
                f:Date.now()
            }),
            "EX",
            c
        ])

        const u=
            `https://${req.headers.host}/api/init`+
            `?id=${encodeURIComponent(x)}`+
            `&token=${encodeURIComponent(t)}`

        const lua=`
local a=getgenv()
local b=a["xQ7mP2"]

if type(b)~="table" then
    return
end

b.c="${t}"

local c,d=pcall(function()
    return request({
        Url="${u}",
        Method="GET"
    })
end)

if not c
or type(d)~="table"
or d.StatusCode~=200
or type(d.Body)~="string"
or #d.Body<1
then
    return
end

local e=loadstring(d.Body,"@y")

if type(e)~="function" then
    return
end

return e()
`

        res.setHeader("Content-Type","text/plain; charset=utf-8")
        res.setHeader("Cache-Control","no-store")

        return res.status(200).send(lua)
    }catch{
        return res.status(404).send("")
    }
}
