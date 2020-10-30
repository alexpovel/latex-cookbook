--[[
    The following import is not required since in LuaTeX's `\directlua` environment,
    `token` is already available. However, this is nice to keep linters from complaining
    about an undefined variable.
--]]
local token = require("token")

--[[
    Trying to incorporate dynamic values into certain newcommand macros. Their
    contents are set at build-time according to environment variables. This is useful
    for automatic workflows in CI environments. See also:
    https://tex.stackexchange.com/a/1739/120853.
    An alternative to using environment variables are command line arguments:
    https://tex.stackexchange.com/a/18813/120853
    However, this seems more error-prone and requires more steps, e.g. piping arguments
    to `lualatex` through `latexmk` first, etc.
    The previous approach was to `sed` for certain `newcommand` definitions in an
    additional CI job. This was much more error-prone (bash scripting) and less
    easily expanded than the below approach.
    LuaTeX provides excellent access to TeX, making this implementation much easier.
--]]

local missing = "n.a."

--  Environment variables as used e.g. in GitLab CI:
local macros_to_envvars = {
    GitRefName = "CI_COMMIT_REF_NAME",
    GitShortSHA = "CI_COMMIT_SHORT_SHA",
}

for macro_name, env_var in pairs(macros_to_envvars) do
    local content = os.getenv(env_var)
    if content == nil then
        content = missing
    end
    --[[
        The `content` can contain unprintable characters, like underscores in git branch
        names. Towards this end, use detokenize in the macro itself, which will make all
        characters printable (assigns category code 12). See also:
        https://www.overleaf.com/learn/latex/Articles/An_Introduction_to_LuaTeX_(Part_2):_Understanding_%5Cdirectlua
    --]]
    local escaped_content = "\\detokenize{"..content.."}"

    --  Set a macro (`\newcommand`) see also: https://tex.stackexchange.com/a/450892/120853
    token.set_macro(macro_name, escaped_content)
end
