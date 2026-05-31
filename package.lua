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
local ssl_external = get_config("ssl_external")
if ssl_external == nil then
    ssl_external = is_plat("linux", "android", "bsd")
end

if ssl_external then
    local ssl_name = get_config("use_quictls") and "quictls" or "libressl"
    add_requires(ssl_name)
    add_requires("ssh2", {configs = {[ssl_name] = true}})
else
    if is_plat("windows", "mingw") then
        add_requires("ssh2", {configs = {crypto = "wincng"}})
    elseif is_plat("macosx", "iphoneos") then
        add_requires("ssh2", {configs = {crypto = "securetransport"}})
    else
        -- 将此处的 raise 替换为 error
        error("ssl_external=false is not supported on Linux/BSD. Please use --ssl_external=true")
    end
end

if get_config("unit") then
    add_requires("cppunit", {optional = true})
end

if os.host() == "windows" then
    add_requires("gettext-tools", {optional = true})
end

if get_config("with_breakpad") then
    add_requires("breakpad")
end
