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

-- 2. 根部显式引入对应的依赖包
if ssl_provider == "openssl" then
    add_requires("openssl3 3.6.2") 
elseif ssl_provider == "quictls" then
    add_requires("quictls")
elseif ssl_provider == "libressl" then
    add_requires("libressl")
elseif ssl_provider == "wintls" then
    -- 【修改】不再引入任何外部加密库（原 add_requires("libressl") 已删除）
end

-- 3. 配置 libssh2 依赖
if is_plat("macosx", "iphoneos") and not ssl_external then
    add_requires("libssh2", {configs = {crypto = "securetransport"}})
elseif ssl_provider == "wintls" then
    -- 【新增】纯 wintls 模式下使用 Windows 原生 CNG 加密后端
    add_requireconfs("libssh2", {install = "source"})
    add_requires("libssh2", {configs = {crypto = "wincng"}})
else
    -- 其他所有外部 SSL 模式（openssl / quictls / libressl）使用 openssl 后端
    add_requireconfs("libssh2", {install = "source"})
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
