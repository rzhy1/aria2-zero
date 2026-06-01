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
    use_quictls = true
end

-- 2. 根部显式引入包
-- Xrepo 会通过 set_provides("openssl") 自动将下游依赖（如 libssh2）重定向到该包上
if ssl_external then
    if use_quictls then
        add_requires("quictls")
    else
        add_requires("libressl")
    end
else
    -- wintls (SChannel) 模式下，仍拉取 libressl 作为底层算法库
    add_requires("libressl")
end

-- 3. 配置 libssh2 依赖
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
