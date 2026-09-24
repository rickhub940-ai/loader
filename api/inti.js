import crypto from "node:crypto"
import fs from "node:fs"
import path from "node:path"

const a=process.env.LOADER_SECRET
const b=60

function c(x){
    return crypto.createHash("sha256").update(x).digest("hex")
}

function d(x){
    return crypto.createHmac("sha256",a).update(x).digest("base64url")
}

function e(x,y){
    const z=x.split(".")

    if(z.length!==6)
        return null

    const[q,r,s,t,u,v]=z

    if(
        q!==y||
        s!=="B"||
        !r||
        !u||
        !/^\d+$/.test(t)
    )
        return null

    const w=`${q}.${r}.${s}.${t}.${u}`
    const k=d(w)

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

async function f(x){
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

        const z=e(y,x)

        if(!z)
            return res.status(404).send("")

        const q=`x:${z}`
        const r=await f(["GET",q])

        if(!r)
            return res.status(404).send("")

        const s=JSON.parse(r)

        if(
            s.a!==z||
            s.e!=="B"||
            s.c!==c(y)||
            Date.now()-Number(s.f)>b*1000
        )
            return res.status(404).send("")

        const t=path.join(
            process.cwd(),
            "scripts",
            `${x}.lua`
        )

        if(!fs.existsSync(t))
            return res.status(404).send("")

        const u=fs.readFileSync(t,"utf8")

        res.setHeader("Content-Type","text/plain; charset=utf-8")
        res.setHeader("Cache-Control","no-store")

        return res.status(200).send(u)
    }catch{
        return res.status(404).send("")
    }
      }
