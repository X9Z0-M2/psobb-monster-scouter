-- Set this to a number above 0 to hide monsters farther
-- away than this distance. Recommended value 750-1000,
-- but play with it and see what you like!
local maxDistance = 0

-- Standard enemy colors are white, rare enemies are yellow, bosses are red.
-- Minibosses are a less threatening red. 8)
-- Changing the second value to "false" makes the enemy not appear on the monster
-- reader.
local m = {}
m[0] =      { color = 0xFFFFFFFF, display = false } -- Unknown

-- Forest
local segment = "Forest"
m[1] =      { color = 0xFFFFFFFF, display = true, height = 20, width = 5, cate = "Hildebear / Hildelt",    seg = segment } -- Hildebear / Hildelt
m[2] =      { color = 0xFFFFFF00, display = true, height = 20, width = 5, cate = "Hildeblue / Hildetorr",  seg = segment } -- Hildeblue / Hildetorr
m[3] =      { color = 0xFFFFFFFF, display = true, height = 2.6, width = 5, cate = "Mothmant / Mothvert",    seg = segment } -- Mothmant / Mothvert
m[4] =      { color = 0xFFFFFFFF, display = true, height = 10, width = 5, cate = "Monest / Mothvist",      seg = segment } -- Monest / Mothvist
m[5] =      { color = 0xFFFFFFFF, display = true, height = 8, width = 5, cate = "Rag Rappy / El Rappy",   seg = segment } -- Rag Rappy / El Rappy
m[6] =      { color = 0xFFFFFF00, display = true, height = 8, width = 5, cate = "Al Rappy / Pal Rappy",   seg = segment } -- Al Rappy / Pal Rappy
m[7] =      { color = 0xFFFFFFFF, display = true, height = 5, width = 5, cate = "Savage Wolf / Gulgus",   seg = segment } -- Savage Wolf / Gulgus
m[8] =      { color = 0xFFFFFFFF, display = true, height = 5, width = 5, cate = "Barbarous Wolf / Gulgus-gue",     seg = segment } -- Barbarous Wolf / Gulgus-gue
m[9] =      { color = 0xFFFFFFFF, display = true, height = 8, width = 5, cate = "Booma / Bartle",         seg = segment } -- Booma / Bartle
m[10] =     { color = 0xFFFFFFFF, display = true, height = 8, width = 5, cate = "Gobooma / Barble",       seg = segment } -- Gobooma / Barble
m[11] =     { color = 0xFFFFFFFF, display = true, height = 8, width = 5, cate = "Gigobooma / Tollaw",     seg = segment } -- Gigobooma / Tollaw

-- Cave
segment = "Cave"
m[12] =     { color = 0xFFFFFFFF, display = true, height = 26, width = 5, cate = "Grass Assassin / Crimson Assassin", seg = segment } -- Grass Assassin / Crimson Assassin
m[13] =     { color = 0xFFFFFFFF, display = true, height = 27, heightTarg = 15, width = 5, cate = "Poison Lily / Ob Lily",  seg = segment } -- Poison Lily / Ob Lily
m[14] =     { color = 0xFFFFFF00, display = true, height = 27, heightTarg = 15, width = 5, cate = "Nar Lily / Mil Lily",    seg = segment } -- Nar Lily / Mil Lily
m[15] =     { color = 0xFFFFFFFF, display = true, height = 5, width = 5, cate = "Nano Dragon",            seg = segment } -- Nano Dragon
m[16] =     { color = 0xFFFFFFFF, display = true, height = 12, width = 5, cate = "Evil Shark / Vulmer",    seg = segment } -- Evil Shark / Vulmer
m[17] =     { color = 0xFFFFFFFF, display = true, height = 12, width = 5, cate = "Pal Shark / Govulmer",   seg = segment } -- Pal Shark / Govulmer
m[18] =     { color = 0xFFFFFFFF, display = true, height = 12, width = 5, cate = "Guil Shark / Melqueek",  seg = segment } -- Guil Shark / Melqueek
m[19] =     { color = 0xFFFFFFFF, display = true, height = 21, width = 5, cate = "Pofuilly Slime",         seg = segment } -- Pofuilly Slime
m[20] =     { color = 0xFFFFFF00, display = true, height = 21, width = 5, cate = "Pouilly Slime",          seg = segment } -- Pouilly Slime
m[21] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Pan Arms",               seg = segment } -- Pan Arms
m[22] =     { color = 0xFFFFFFFF, display = true, height = 19, width = 5, cate = "Migium",                 seg = segment } -- Migium
m[23] =     { color = 0xFFFFFFFF, display = true, height = 19, width = 5, cate = "Hidoom",                 seg = segment } -- Hidoom

-- Mine
segment = "Mine"
m[24] =     { color = 0xFFFFFFFF, display = true, height = 13, width = 5, cate = "Dubchic / Dubchich", seg = segment } -- Dubchic / Dubchich
m[25] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Garanz / Baranz",         seg = segment } -- Garanz / Baranz
m[26] =     { color = 0xFFFFFFFF, display = true, height = 11, width = 5, cate = "Sinow Beat / Sinow Blue", seg = segment } -- Sinow Beat / Sinow Blue
m[27] =     { color = 0xFFFFFFFF, display = true, height = 11, width = 5, cate = "Sinow Gold / Sinow Red",  seg = segment } -- Sinow Gold / Sinow Red
m[28] =     { color = 0xFFFFFFFF, display = true, height = 5, width = 5, cate = "Canadine / Canabin",      seg = segment } -- Canadine / Canabin
m[29] =     { color = 0xFFFFFFFF, display = true, height = 5, width = 5, cate = "Canane / Canune",         seg = segment } -- Canane / Canune
m[49] =     { color = 0xFFFFFFFF, display = true, height = 3, width = 5, cate = "Dubwitch",                seg = segment } -- Dubwitch
m[50] =     { color = 0xFFFFFFFF, display = true, height = 13, width = 5, cate = "Gillchic / Gillchich",    seg = segment } -- Gillchic / Gillchich

-- Ruins
segment = "Ruins"
m[30] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Delsaber",                seg = segment } -- Delsaber
m[31] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Chaos Sorcerer / Gran Sorcerer",  seg = segment } -- Chaos Sorcerer / Gran Sorcerer
m[32] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Bee R / Gee R",           seg = segment } -- Bee R / Gee R
m[33] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Bee L / Gee L",           seg = segment } -- Bee L / Gee L
m[34] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Dark Gunner",             seg = segment } -- Dark Gunner
m[35] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Death Gunner",            seg = segment } -- Death Gunner
m[36] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Dark Bringer",            seg = segment } -- Dark Bringer
m[37] =     { color = 0xFFFFFFFF, display = true, height = 18, width = 5, cate = "Indi Belra",              seg = segment } -- Indi Belra
m[38] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Claw",                    seg = segment } -- Claw
m[39] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Bulk",                    seg = segment } -- Bulk
m[40] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Bulclaw",                 seg = segment } -- Bulclaw
m[41] =     { color = 0xFFFFFFFF, display = true, height = 13, width = 5, cate = "Dimenian / Arlan",        seg = segment } -- Dimenian / Arlan
m[42] =     { color = 0xFFFFFFFF, display = true, height = 13, width = 5, cate = "La Dimenian / Merlan",    seg = segment } -- La Dimenian / Merlan
m[43] =     { color = 0xFFFFFFFF, display = true, height = 13, width = 5, cate = "So Dimenian / Del-D",     seg = segment } -- So Dimenian / Del-D

-- Episode 1 Bosses
m[44] =     { color = 0xFFFF0000, display = true, height = 14, width = 5, cate = "Dragon / Sil Dragon",     seg = "Forest", boss = true } -- Dragon / Sil Dragon
m[45] =     { color = 0xFFFF0000, display = true, height = 14, width = 5, cate = "De Rol Le / Dal Ral Lie", seg = "Cave",   boss = true } -- De Rol Le / Dal Ral Lie
m[46] =     { color = 0xFFFF0000, display = true, height = 14, width = 5, cate = "Vol Opt / Vol Opt ver.2", seg = "Mine",   boss = true } -- Vol Opt / Vol Opt ver.2
m[47] =     { color = 0xFFFF0000, display = true, height = 14, width = 5, cate = "Dark Falz",               seg = "Ruins",  boss = true } -- Dark Falz

-- VR Temple
segment = "VR Temple"
m[51] =     { color = 0xFFFFFF00, display = true, height = 8, width = 5, cate = "Love Rappy",      seg = segment } -- Love Rappy
m[73] =     { color = 0xFFFF0000, display = true, height = 36, width = 5, cate = "Barba Ray",       seg = segment,  boss = true } -- Barba Ray
m[74] =     { color = 0xFFFFFFFF, display = true, height = 20, width = 5, cate = "Pig Ray",         seg = segment } -- Pig Ray
m[75] =     { color = 0xFFFFFFFF, display = true, height = 20, width = 5, cate = "Ul Ray",          seg = segment } -- Ul Ray
m[79] =     { color = 0xFFFFFFFF, display = true, height = 8, width = 5, cate = "St. Rappy",       seg = segment } -- St. Rappy
m[80] =     { color = 0xFFFFFF00, display = true, height = 8, width = 5, cate = "Hallo Rappy",     seg = segment } -- Hallo Rappy
m[81] =     { color = 0xFFFFFF00, display = true, height = 8, width = 5, cate = "Egg Rappy",       seg = segment } -- Egg Rappy

-- VR Spaceship
segment = "VR Spaceship"
m[76] =     { color = 0xFFFF0000, display = true, height = 14, width = 5, cate = "Gol Dragon",      seg = segment, boss = true } -- Gol Dragon

-- Central Control Area
segment = "Central Control Area"
m[52] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Merillia",        seg = segment } -- Merillia
m[53] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Meriltas",        seg = segment } -- Meriltas
m[54] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Gee",             seg = segment } -- Gee
m[55] =     { color = 0xFFFF8080, display = true, height = 14, width = 5, cate = "Gi Gue",          seg = segment } -- Gi Gue
m[56] =     { color = 0xFFFF8080, display = true, height = 14, width = 5, cate = "Mericarol",       seg = segment } -- Mericarol
m[57] =     { color = 0xFFFF8080, display = true, height = 14, width = 5, cate = "Merikle",         seg = segment } -- Merikle
m[58] =     { color = 0xFFFF8080, display = true, height = 14, width = 5, cate = "Mericus",         seg = segment } -- Mericus
m[59] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Ul Gibbon",       seg = segment } -- Ul Gibbon
m[60] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Zol Gibbon",      seg = segment } -- Zol Gibbon
m[61] =     { color = 0xFFFF8080, display = true, height = 14, width = 5, cate = "Gibbles",         seg = segment } -- Gibbles
m[62] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Sinow Berill",    seg = segment } -- Sinow Berill
m[63] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Sinow Spigell",   seg = segment } -- Sinow Spigell
m[77] =     { color = 0xFFFF0000, display = true, height = 14, width = 5, cate = "Gal Gryphon",     seg = segment, boss = true } -- Gal Gryphon
m[82] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Ill Gill",        seg = segment } -- Ill Gill
m[83] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Del Lily",        seg = segment } -- Del Lily
m[84] =     { color = 0xFFFF8080, display = true, height = 14, width = 5, cate = "Epsilon",         seg = segment } -- Epsilon
m[87] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Epsigard",        seg = segment } -- Epsigard

-- Seabed
segment = "Seabed"
m[64] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Dolmolm",     seg = segment } -- Dolmolm
m[65] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Dolmdarl",    seg = segment } -- Dolmdarl
m[66] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Morfos",      seg = segment } -- Morfos
m[67] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Recobox",     seg = segment } -- Recobox
m[68] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Recon",       seg = segment } -- Recon
m[69] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Sinow Zoa",   seg = segment } -- Sinow Zoa
m[70] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Sinow Zele",  seg = segment } -- Sinow Zele
m[71] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Deldepth",    seg = segment } -- Deldepth
m[72] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Delbiter",    seg = segment } -- Delbiter
m[78] =     { color = 0xFFFF0000, display = true, height = 14, width = 5, cate = "Olga Flow",   seg = segment, boss = true } -- Olga Flow
m[85] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Gael",        seg = segment } -- Gael
m[86] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Giel",        seg = segment } -- Giel

-- Crater
segment = "Crater"
m[88] =     { color = 0xFFFFFFFF, display = true, height = 14, width = 5, cate = "Astark",      seg = segment } -- Astark
m[89] =     { color = 0xFFFFFFFF, display = true, height = 5, width = 5, cate = "Yowie",       seg = segment } -- Yowie
m[90] =     { color = 0xFFFFFFFF, display = true, height = 5, width = 5, cate = "Satellite Lizard", seg = segment } -- Satellite Lizard
m[94] =     { color = 0xFFFFFFFF, display = true, height = 70, width = 5, cate = "Zu",          seg = segment } -- Zu
m[95] =     { color = 0xFFFFFF00, display = true, height = 14, width = 5, cate = "Pazuzu",      seg = segment } -- Pazuzu
m[96] =     { color = 0xFFFFFFFF, display = true, height = 5, width = 5, cate = "Boota",       seg = segment } -- Boota
m[97] =     { color = 0xFFFFFFFF, display = true, height = 10, width = 5, cate = "Ze Boota",    seg = segment } -- Ze Boota
m[98] =     { color = 0xFFFFFFFF, display = true, height = 12, width = 5, cate = "Ba Boota",    seg = segment } -- Ba Boota
m[99] =     { color = 0xFFFFFFFF, display = true, height = 32, width = 5, cate = "Dorphon",     seg = segment } -- Dorphon
m[100] =    { color = 0xFFFFFF00, display = true, height = 32, width = 5, cate = "Dorphon Eclair", seg = segment } -- Dorphon Eclair
m[104] =    { color = 0xFFFFFFFF, display = true, height = -1, width = 5, cate = "Sand Rappy",  seg = segment } -- Sand Rappy
m[105] =    { color = 0xFFFFFF00, display = true, height = -1, width = 5, cate = "Del Rappy",   seg = segment } -- Del Rappy

-- Desert
segment = "Desert"
m[91] =     { color = 0xFFFFFFFF, display = true, height = 15, width = 5, cate = "Merissa A",   seg = segment } -- Merissa A
m[92] =     { color = 0xFFFFFF00, display = true, height = 15, width = 5, cate = "Merissa AA",  seg = segment } -- Merissa AA
m[93] =     { color = 0xFFFFFFFF, display = true, height = 24, width = 5, cate = "Girtablulu",  seg = segment } -- Girtablulu
m[101] =    { color = 0xFFFFFFFF, display = true, height = 9, width = 5, cate = "Goran",       seg = segment } -- Goran
m[102] =    { color = 0xFFFFFFFF, display = true, height = 33, width = 5, cate = "Goran Detonator", seg = segment } -- Goran Detonator
m[103] =    { color = 0xFFFFFFFF, display = true, height = 9, width = 5, cate = "Pyro Goran",  seg = segment } -- Pyro Goran
m[106] =    { color = 0xFFFF0000, display = true, height = 14, width = 5, cate = "Saint-Milion",seg = segment, boss = true } -- Saint-Milion
m[107] =    { color = 0xFFFF0000, display = true, height = 14, width = 5, cate = "Shambertin",  seg = segment, boss = true } -- Shambertin
m[108] =    { color = 0xFFFF8000, display = true, height = 14, width = 5, cate = "Kondrieu",    seg = segment, boss = true } -- Kondrieu

-- Other
m[48] =     { color = 0xFFFFFFFF, display = true } -- Container

return
{
    maxDistance = maxDistance,
    m = m,
}
