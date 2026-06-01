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

-- 1. 标准化配置参数
local ssl_external = get_config("ssl_external")
if type(ssl_external) == "string" then
    ssl_external = (ssl_external == "y" or ssl_external == "yes" or ssl_external == "true")
elseif ssl_external == nil then
    ssl_external = is_plat("linux", "android", "bsd")
end

local use_quictls = get_config("use_quictls")
if type(use_quictls) == "string" then
    use_quictls = (use_quictls == "y" or use_quictls == "yes" or use_quictls == "true")
elseif use_quictls == nil then
    use_quictls = true  -- 保持与 xmake.lua 选项默认值一致
end

-- 2. 引入对应的 SSL 包
if use_quictls then
    add_requires("quictls")
else
    add_requires("libressl")
end

-- 3. 处理 libssh2 的加密后端及其内部依赖重定向
if is_plat("macosx", "iphoneos") and not ssl_external then
    add_requires("libssh2", {configs = {crypto = "securetransport"}})
else
    if use_quictls then
        -- 强制重定向 libssh2 内部的 openssl 依赖到 quictls
        add_requireconfs("libssh2.openssl", {override = true, version = "quictls"})
    else
        -- 强制重定向 libssh2 内部的 openssl 依赖到 libressl
        add_requireconfs("libssh2.openssl", {override = true, version = "libressl"})
    end
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
