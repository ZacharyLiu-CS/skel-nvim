<div align="left">

# skel-nvim
##### nevoim skeleton plugin.
[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.5+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)
</div>

## Overview
A skeleton plugin for nvim inspired by [vim-skeleton](https://github.com/noahfrederick/vim-skeleton) written in lua.
* Load boilerplate templates when a new file is created
* Configurable mapping between templates and filename patterns
* Can replace placeholder tokens in templates with either configurable strings or dynamic population using lua functions
* Supports concept of global/per-project config and templates.

## Preinstallion
Recommand UI section library to replace native ui.
Dressing is tested, telescope-ui-select has bugs.

Using [lazy](https://github.com/folke/lazy.nvim):
```lua
{
  'stevearc/dressing.nvim',
  opts = {},
}
```
## Installation
Using [plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'zacharyliu-cs/skel-nvim'
```

Using [packer](https://github.com/wbthomason/packer.nvim):

```lua
use "zacharyliu-cs/skel-nvim"
```
Using [lazy](https://github.com/folke/lazy.nvim)
```lua
"zacharyliu-cs/skel-nvim"
```

## Configuration
basic config
```lua
require("skel-nvim").setup{
  -- file pattern -> template mappings
  mappings = {
    ['*.cpp'] = "cpp.skel",
    ['*.h']   = "h.skel",
    -- patterns can map to multiple templates
    ['LICENSE'] = {"license.mit.skel", "license.gpl.skel" }
}
```
by default, the plugin 
* expects template files to be under XDG\_CONFIG\_HOME/skeleton/, i.e. ~/.config/nvim/skeleton/  
* for filenames matching `*.cpp` pattern it will look for ~/.config/nvim/skeleton/cpp.skel file
* for filenames matching `*.h` pattern it will look for ~/.config/nvim/skeleton/h.skel file  

If multiple templates are specified, `vim.ui.select` is used to allow user to choose which template to use.  
\
Example config for C/C++ development  
```lua
-- import basic default placeholder callbacks
local skeld = require("skel-nvim.defaults")

require("skel-nvim").setup{
  -- dir containing skeleton files (default)
  templates_dir = vim.fn.stdpath("config") .. "/skeleton",

  -- enable/disable plugin, this supercedes disable_for_empty_file (default)
  skel_enabled = true,

  -- enable/disable processing for bufread + empty file case (default)
  apply_skel_for_empty_file = true,

  -- file pattern -> template mappings (default)
  mappings = {
		["LICENSE"] = { "BSD_3Clause.license", "GNU_GPLv3.license", "MIT.license"},
		["*.cpp"] = "skel.cc",
		["*.cc"] = "skel.cc",
		["*.hpp"] = "skel.h",
		["*.h"] = "skel.h",
		["*.hh"] = "skel.h",
    ["*.go"] = "skel.go",
		["*.c"] = "skel.c",
		["*.py"] = "skel.py",
		["*.rs"] = "skel.rs",
		["*.lua"] = "skel.lua",
		["*.sh"] = "skel.sh",
  },

  -- substitutions in templates (default)
  -- can be a string or a callback function
  -- these are the set of default placeholders provided by the plugin
  substitutions = {
    ['FILENAME']             = skeld.get_filename,
    ['NAME']                 = skeld.get_author,
    ['EMAIL']                = skeld.get_email,
    ['DATE']                 = skeld.get_date,
    ['YEAR']                 = skeld.get_year,
    ['CPP_HDR_GUARD']        = skeld.get_cppheaderguard,
    ['CPP_TEST_HDR_GUARD']   = skeld.get_testheaderguard,
    ['CPP_HDR_INCLUDE']      = skeld.get_headerinclude,
    ['CLASS_NAME']           = skeld.get_classname2,
  },

  -- Misc global config available to substitution callback functions
  author = "MyName",
  email = "MyEmail@mail.com",
  -- Supports user varaibles too
  my_user_variable = "my_user_value",

  }
```
Here we have a gobal config and 2 project overrides where some configurations are overriden.
Projects are determined by `path`, that is 
```
:edit ~/home/dev/proj1/test.cpp  // will match `path` of project1 and will apply project1 config
:edit ~/home/dev/proj2/test.cpp  // will match `path` of project2 and will apply project1 config
:edit ~/home/dev/my_other_proj/test.cpp  // doens't match any project paths so will use default global config
```
## Commands
|Command      | Description                                                          |
|-------------|----------------------------------------------------------------------|
| SkelEnable  | Enable auto loading of templates when pattern is matched (default)   |
| SkelDisable | Disable auto loading of templates when pattern is matched            |
| SkelStatus  | Check if auto loading is enabled                                     |
| SkelEdit    | If template auto loading is disabled, `:SkelEdit <filename>` can be used to create file and apply template |
| SkelRun     | If template auto loading is disabled, `:SkelRun` can be used to apply template on empty buffer with a filename, this covers use cases such as nvim-tree used to create a new empty file and then loaded into vim as two operations |


## Usage
### Templates
By default, templates are expected to be found under ~/.config/nvim/skeleton/ folder.  
Placeholder variables need to be surrounded by '@', i.e. @FILENAME@  
Here's an example template file for C++, more examples are referenced in [skeletons](https://github.com/ZacharyLiu-CS/neovim_luafiles/tree/master/skeletons)
```cpp
//
//  @FILENAME@ 
//
//  Created by @NAME@ on @DATE@.
//  Copyright (c) @YEAR@ @EMAIL@.
//
#ifndef @CPP_HDR_GUARD@
#define @CPP_HDR_GUARD@


//------------------------------------------------------------------------------

class @CLASS_NAME@
{

public:
    @CLASS_NAME@() = default;
    ~@CLASS_NAME@() = default; 

private:

};

//------------------------------------------------------------------------------

#endif /* @CPP_HDR_GUARD@ */
```

### Placeholder callbacks functions
placeholder callback functions are called with single `table` argument
```lua
config = {
  filename  = <absolute path of buffer file>,
  author    = <name provided in 'author' in setup config>,
  email     = <email provided in 'email' in setukp config>,
  <user defined values>
}

``` 
below example shows how to write your own callbacks

```lua
-- calbacks take single `table` argument as described in previous section
local function my_filename_callback(config)
  return vim.fs.basename(config.filename)
end

-- using user defined key/val `my_user_key="my user value"`
local function my_placeholder1_callback(config)
  return strings.uppper(config.my_user_key)
end

require("skel-nvim").setup{
  -- user defined key/value
  my_user_key = "my user value",     -- user defined key/vals are avilable in placeholder callbacks

  mappings = {
    ['main.cpp'] = "main.cpp.skel",
    ['*.cpp'] = "cpp.skel",
    ['*.h'] = "h.skel",
  },
  substitutions = {
    ['FILENAME']             = my_filename_callback,    -- user callback
    ['NAME']                 = "My Name",               -- can use hard-coded string 
    ['MYPLACEHOLDER1']       = my_placeholder1_callback -- in the template @MYPLACEHOLDER1@ will be replaced with "MY USER VALUE"
  }
}

```
### Project support

`skel-nvim` supports per project configration overrides and per project templates if needed

let's say we have a basic template file cpp.skel
```
// filename: @FILENAME@
// author:   @NAME@

@PLACEHOLDER1@  // some usage of placeholder1 

@PLACEHOLDER2@  // some usage of placeholder2
```

and we want to have different values of PLACEHOLDER1/2 depending on the project we're in

```lua
-- `skel-nvim` default callbacks
local skel_defaults = require("skel-nvim.defaults")

-- user defined callback
local function my_filename_callback(config)
  return vim.fs.basename(config.filename)
end

-- user defined callback to provide a value for @PLACEHOLDER1@
local function default_placeholder1_callback(config)
  return "MY PLACEHOLDER1 VALUE"
end

-- user defined callback to provide a value for @PLACEHOLDER1@ for project1
local function project1_placeholder1_callback(config)
  return "MY PROJECT1 PLACEHOLDER1 VALUE"
end

-- user defined callback to provide a value for @PLACEHOLDER2@
local function placeholder2_callback(config)
  -- the value of user defined custom_key will be different in global/project1
  return config.custom_key
end

require("skel-nvim").setup {

  mappings = {
    ['main.cpp'] = "main.cpp.skel",
    ['*.cpp'] = "cpp.skel",
    ['*.h'] = "h.skel",
  },
  substitutions = {
    ['FILENAME']             = skel_defaults.get_filename,
    ['NAME']                 = "My Name",
    ['PLACEHOLDER1']         = default_placeholder1_callback, -- user defined
    ['PLACEHOLDER2']         = placeholder2_callback, -- user defined
  },
  custom_key = "default value",  -- this what we want output in @PLACEHOLDER2@

  projects = {
    -- By default templates are to be placesd under ~/.config/nvim/skeleton/
    -- but with projects, an addtional folder ~/.config/nvim/nvim/skeleton/project1/
    -- is also searched, if the required template is found under project template folder
    -- it will use that. If no project template file is found it will 
    -- attempt find one under the root template folder.
    project1 = {              
        -- `path` to project is a required for each project
        path = "absolute/path/to/my/project1/"

        -- we can override all configuration in here, i.e.

        -- different mappings
        mappings = {
            ['*.cpp'] = "alternate_cpp.skel"  -- can also provide per project root level template files
        },

        -- override placeholder substitutions
        substitutions = {
            ['FILENAME']             = my_filename_callback,    -- user callback
            ['NAME']                 = "My Name",               -- can use hard-coded string 
            ['PLACEHOLDER1']         = project1_placeholder1_callback, -- user defined and overridden from global config
        },

        -- override custom_key for project1
        custom_key = "my project1 value",
    }
  }
}
```
As you can see from this example the configuration very flexible to support per project customisation.
* we can have different per project template files under root ../skeleton/ folder by overriding per project mappings or
* we can use the default mappings across all but handle any custom per project templates by placing them under
subfolders with named after the project, i.e. 
    * ~/.config/nvim/skeleton/            // default 
    * ~/.config/nvim/skeleton/project1/   // project 1 templates
    * ~/.config/nvim/skeleton/project2/   // project 2 templates
* project identification is based on path of new buffer being created and thus must provide key/val `path` for each per
project configuration.

