-- This module contains defaults for substitutions
-- hanlders get a config table with the following spec
-- config = {
--   filename  = <absolute path of buffer file>,
--   author    = <name provided in 'author' in setup config>,
--   email     = <email provided in "email" in setup config>,
--   <inserts any user defined config in here>
-- }

local Utils = require("skel-nvim.utils")
local M = {}

function M.get_filename(cfg)
	return vim.fs.basename(cfg.filename)
end

function M.get_author(cfg)
	return cfg.author
end

function M.get_email(cfg)
	return cfg.email
end

function M.get_date(cfg)
	return os.date("%x")
end

function M.get_year(cfg)
	return os.date("%Y")
end

-- cpp speficifics

-- given filename: "test.h" -> "TEST_H"
function M.get_cppheaderguard(cfg)
	local name, _, _ = Utils.get_basename_parts(cfg.filename)
	return string.gsub(name:upper(), "%.", "_")
end

-- given filename: "test.t.h" -> "TEST_T_H"
function M.get_testheaderguard(cfg)
	local name, _, _ = Utils.get_basename_parts(cfg.filename)
	return string.gsub(name:upper(), "%.", "_")
end

-- given filename: test.cpp, --> #include <testh.h>
function M.get_headerinclude(cfg)
	local _, base, _ = Utils.get_basename_parts(cfg.filename)
	return "<" .. base .. ".h>"
end

-- given filename: test.cpp, --> #include "testh.h"
function M.get_headerinclude_quote(cfg)
	local _, base, _ = Utils.get_basename_parts(cfg.filename)
	return '"' .. base .. '.h"'
end

-- given filename: test.cpp -> Test
function M.get_classname(cfg)
	local _, base, _ = Utils.get_basename_parts(cfg.filename)
	return Utils.title_case(base)
end

-- given filename: app_xyz_test.cpp -> Test
function M.get_classname2(cfg)
	local _, base, _ = Utils.get_basename_parts(cfg.filename)
	if base:find("_") ~= nil then
		-- strip all leading <word>_
		base = base:match(".*_([^_]*)$")
	end
	return Utils.title_case(base)
end

return M
