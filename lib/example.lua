--[[
    The following import is not required since in LuaTeX's `\directlua` environment,
    `token` etc. is already available. However, this is nice to keep linters from
    complaining about an undefined variable.
--]]
local token = require("token")
local texio = require("texio")
local status = require("status")

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

local function get_cmd_stdout(cmd)
    -- See: https://stackoverflow.com/a/326715/11477374
    local fh = assert(io.popen(cmd))
    local first_line = assert(fh:read())
    fh:close()
    return first_line
end

-- Environment variables as used e.g. in GitLab CI.
-- Otherwise, e.g. when developing locally, use commands as a fallback.
local macro_content_sources = {
    GitRefName = {
        env = "CI_COMMIT_REF_NAME",
        cmd = "git rev-parse --abbrev-ref HEAD",
    },
    GitShortSHA = {
        env = "CI_COMMIT_SHORT_SHA",
        cmd = "git rev-parse --short HEAD",
    },
}

for macro_name, content_sources in pairs(macro_content_sources) do
    -- Default: check for environment variable:
    local env = content_sources.env
    local cmd = content_sources.cmd
    local content = "n.a."  -- Default value
    local env_content = os.getenv(env)

    if env_content and env_content ~= "" then  -- Empty string evaluates to true
        texio.write_nl("Found and will be using environment variable '"..env.."'.")
        content = env_content
    else
        texio.write_nl("Environment variable '"..env.."' undefined or empty, trying fallback command.")
        -- luatex reference for shell escape:
        -- "0 means disabled, 1 means anything is permitted, and 2 is restricted"
        if status.shell_escape == 1 then
            local cmd_success, cmd_stdout = pcall(get_cmd_stdout, cmd)
            if cmd_success then
                texio.write_nl("Fallback command '"..cmd.."' succeeded.")
                content = cmd_stdout
            else
                texio.write_nl("Fallback command '"..cmd.."' unsuccessful.")
            end
        else
            texio.write_nl("shell-escape is disabled, cannot use fallback command.")
        end
    end

    -- Shouldn't happen, would be programmer error, therefore assert Python-style
    assert(content, "Content not defined (neither success nor fallback present)")

    --[[
        The `content` can contain unprintable characters, like underscores in git branch
        names. Towards this end, use detokenize in the macro itself, which will make all
        characters printable (assigns category code 12). See also:
        https://www.overleaf.com/learn/latex/Articles/An_Introduction_to_LuaTeX_(Part_2):_Understanding_%5Cdirectlua
    --]]
    local escaped_content = "\\detokenize{"..content.."}"

    texio.write_nl("Providing new macro '"..macro_name.."' with contents: '"..escaped_content.."'.")
    --  Set a macro (`\newcommand`) see also: https://tex.stackexchange.com/a/450892/120853
    token.set_macro(macro_name, escaped_content)
end
