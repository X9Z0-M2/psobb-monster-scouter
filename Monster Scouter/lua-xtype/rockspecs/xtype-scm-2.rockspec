package = "xtype"
version = "scm-2"
source = {
  url = "git://github.com/ImagicTheCat/lua-xtype",
}

description = {
  summary = "A dynamic type system library for Lua.",
  detailed = [[
xtype, or Extended Type, is a dynamic type system library for Lua.
  ]],
  homepage = "https://github.com/ImagicTheCat/lua-xtype",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1, <= 5.4"
}

build = {
  type = "builtin",
  modules = {
    xtype = "src/xtype.lua"
  }
}
