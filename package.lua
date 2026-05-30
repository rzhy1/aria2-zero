set_policy("package.install_only", true)

add_repositories("zeromake https://github.com/rzhy1/xrepo.git")

add_requires(
    "expat",
    "zlib",
    "sqlite3",
    "c-ares",
    "nonstd.string-view",
    "boost.intl"
)

local ssl_name = get_config("use_quictls") and "quictls" or "libressl"
add_requires(ssl_name, {configs = {asm = false}})
add_requires("ssh2", {configs = {[ssl_name] = true}})

if get_config("unit") then
    add_requires("cppunit", {optional = true})
end

if os.host() == "windows" then
    add_requires("gettext-tools", {optional = true})
end

if get_config("with_breakpad") then
    add_requires("breakpad")
end
