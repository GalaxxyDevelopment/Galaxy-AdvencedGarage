Config = {}

Config.Target = 'qb' -- "qb" / "ox" 
Config.Notify = 'ox' -- "qb" / "ox"
Config.NotifyKonum = 'top' -- oxlib notify pozisyonu ayarlıyorsun burdan top iyidir
Config.Progressbar = 'standalone' -- "standalone" / "ox"
Config.Menu = 'ox' -- "qb" / "ox"

Config.konumlar = {
    {
        npcKonumu = vector4(299.19, -324.34, 45.02, 155.67),
        AracKonum = vector4(297.21, -328.85, 44.92, 158.6),
        araclar = {'faggio', 't20', 'sanchez'},
        meslek = 'police',
        jobGereksinimi = true,
        data = true -- aracı kişinin datasına versin mi ( "true" / "false" )
    },
    {
        npcKonumu = vector4(291.06, -321.25, 45.02, 158.72),
        AracKonum = vector4(289.84, -324.58, 44.92, 160.96),
        araclar = {'faggio'},
        meslek = 'bennys',
        jobGereksinimi = false,
        data = false -- aracı kişinin datasına versin mi ( "true" / "false" )
    },
}