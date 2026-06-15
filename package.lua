set_policy("package.install_only", false) -- 启用免编译策略，节省时间

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

-- 2. 根部显式引入对应的依赖包
if ssl_provider == "openssl" then
    -- 强制使用有 100% 预编译二进制支持的 3.0.x LTS 版本，确保 2 秒内直接解压安装
    add_requires("builtin-repo::openssl3 3.0.x") 
elseif ssl_provider == "quictls" then
    add_requires("quictls")
elseif ssl_provider == "libressl" then
    add_requires("libressl")
elseif ssl_provider == "wintls" then
    -- wintls 模式下，底层算法库指定搭配 libressl
    add_requires("libressl")
end

-- 3. 配置 libssh2 依赖（彻底移除未知参数 require_pack，解决警告和冲突问题）
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
