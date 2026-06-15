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

-- 1. 解析新的 ssl_provider 参数
local ssl_provider = get_config("ssl_provider") or "quictls"
local ssl_external = (ssl_provider ~= "wintls")

-- 2. 根部显式引入对应的依赖包（消除冲突）
if ssl_provider == "openssl" then
    add_requires("openssl")
elseif ssl_provider == "quictls" then
    add_requires("quictls")
elseif ssl_provider == "libressl" then
    add_requires("libressl")
elseif ssl_provider == "wintls" then
    -- wintls 模式下，底层算法库指定搭配 libressl
    add_requires("libressl")
end

-- 3. 配置 libssh2 依赖
-- 如果是 macOS 且使用系统 TLS 模式，则 libssh2 使用 securetransport 后端
-- 否则（包括 Windows/MinGW 的所有模式），libssh2 使用 openssl 后端（将自动绑定到上面声明的具体包）
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
