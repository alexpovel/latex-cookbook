--[[
    The following import is not required since in LuaTeX's `\directlua` environment,
    `texio` etc. is already available. However, this is nice to keep linters from
    complaining about an undefined variable.
--]]
local texio = require("texio")
local tex = require("tex")

PREFIXES = {"", "kilo", "milli", "giga", "nano"}

UNITS = {"meter", "degreeCelsius", "kelvin", "gram", "bar", "pascal", "newton", "candela", "ampere", "ohm", "volt",
         "watt"}

TEXTS = {"This is a longer text that will probably span multiple lines in the table because it is overly wide.",
         "Hello World", "A", "B", "C", "Foo", "Bar", "Baz", "Yeet"}

MATH_OPS = {"+", "-", "/", "^"}
MATH_SYMBOLS = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u",
                "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
                "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}

-- Seed with `os.time()` for true randomness; keep a constant seed for
-- reproducibility:
RANDOM_SEED = RANDOM_SEED or os.time()
math.randomseed(RANDOM_SEED)

local function choice(table)
    -- Imitating Python's `random.choice` to pick a random element from a table.
    return table[math.random(#table)]
end

local function random_int(n_digits)
    -- Returns a random integer with the specified number of digits
    if n_digits < 1 then
        -- `min` can be `0 <= min <= 1` from e.g. 10^(0 - 1), which cannot be fed to
        -- `math.random` properly, so return early here.
        return 0
    end

    local min = 10 ^ (n_digits - 1) -- e.g. 2 -> 10
    local max = (10 ^ n_digits) - 1 -- e.g. 2 -> 100 - 1 -> 99
    return math.random(min, max)
end

local function latex_table_row()
    local max_n_digits_left, max_n_digits_right = 3, 3
    local n_digits_left = math.random(0, max_n_digits_left)
    local n_digits_right = math.random(0, max_n_digits_right)
    local left, right = random_int(n_digits_left), random_int(n_digits_right)
    -- We could do some super cool bit logic to achieve the desired floating decimal
    -- points but I'm not smart enough, so cast to string like a monkey.
    local number = left .. "." .. right

    local prefix = choice(PREFIXES)
    if prefix ~= "" then
        -- Do not allow `\\` to pass, aka prefix is empty string
        prefix = "\\" .. prefix
    end
    local unit = "\\" .. choice(UNITS)

    local text = choice(TEXTS)

    local math = choice(MATH_SYMBOLS) .. choice(MATH_OPS) .. choice(MATH_SYMBOLS) .. "=" .. choice(MATH_SYMBOLS)

    local row_eol = "\\\\"
    local column_sep = " & "
    local row = table.concat({number, prefix .. unit, text, math}, column_sep) .. row_eol
    texio.write_nl("Generated new table row: " .. row)
    return row
end

-- See if defined, else fallback to default:
N_ROWS = N_ROWS or 75

for _ = 1, N_ROWS do
    tex.print(latex_table_row())
end
