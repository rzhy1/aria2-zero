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

add_requires("libressl")

local ssl_external = get_config("ssl_external")
if type(ssl_external) == "string" then
    ssl_external = (ssl_external == "y" or ssl_external == "yes" or ssl_external == "true")
elseif ssl_external == nil then
    ssl_external = is_plat("linux", "android", "bsd")
end

if is_plat("macosx", "iphoneos") and not ssl_external then
    add_requires("libssh2", {configs = {crypto = "securetransport"}})
else
    add_requires("libssh2", {configs = {crypto = "openssl"}})
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
