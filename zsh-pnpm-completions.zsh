_pnpm_recursively_look_for() {
  local dir
  local filename="$1"
  local workspace_path="$2"

  if [[ -z $workspace_path ]]; then
    dir="$PWD"
  elif [[ -n $workspace_path ]]; then
    dir="$PWD/$workspace_path"
  fi

  while [ ! -e "$dir/$filename" ]; do
    dir=${dir%/*}
    [[ "$dir" = "" ]] && break
  done

  [[ ! "$dir" = "" ]] && echo "$dir/$filename"
}

_pnpm_get_package_json_property_object() {
  local package_json="$1"
  local property="$2"

  # cat command prints package.json file
  # first sed command grabs scripts object
  # second sed command removes first & last lines
  # third sed command parses into key=>value
  cat "$package_json" |
    sed -nE "/^[  ]+\"$property\": \{$/,/^[  ]+\},?$/p" |
    sed '1d;$d' |
    sed -E 's/[  ]+"([^"]+)": "(.+)",?/\1=>\2/'
}

_pnpm_get_package_json_property_object_keys() {
  local package_json="$1"
  local property="$2"

  _pnpm_get_package_json_property_object "$package_json" "$property" | cut -f 1 -d "="
}

_pnpm_parse_package_json_for_script_suggestions() {
  local package_json="$1"

  # first sed command parses commands info suggestions
  # second sed command escapes ":" in commands
  # third sed command escapes ":$" without a space in commands
  _pnpm_get_package_json_property_object "$package_json" scripts |
    sed -E 's/(.+)=>(.+)/\1:$ \2/' |
    sed 's/\(:\)[^$]/\\&/g' |
    sed 's/\(:\)$[^ ]/\\&/g'
}

_pnpm_parse_package_json_for_deps() {
  local package_json="$1"

  _pnpm_get_package_json_property_object_keys "$package_json" dependencies
  _pnpm_get_package_json_property_object_keys "$package_json" devDependencies
  _pnpm_get_package_json_property_object_keys "$package_json" optionalDependencies
}

_pnpm_get_scripts_from_package_json() {
  local package_json
  package_json="$(_pnpm_recursively_look_for package.json)"

  [[ "$package_json" = "" ]] && return

  local -a options
  options=(
    ${(f)"$(_pnpm_parse_package_json_for_script_suggestions $package_json)"} \
    env:"Prints list of environment variables available to the scripts at runtime" \
  )

  _describe -t package-scripts "package scripts" options
}

_pnpm_get_scripts_from_workspace_package_json() {
  local -a options

  package_json="$(_pnpm_recursively_look_for package.json "$location")"

  [[ "$package_json" = "" ]] && return

  options=(
    ${(f)"$(_pnpm_parse_package_json_for_script_suggestions $package_json)"} \
    env:"Prints list of environment variables available to the scripts at runtime" \
  )

  _describe -t package-scripts "package scripts" options
}

_pnpm_get_packages_from_package_json() {
  local package_json
  package_json="$(_pnpm_recursively_look_for package.json)"

  # Return if we can't find package.json
  [[ "$package_json" = "" ]] && return

  _values \
  "description" \
  $(_pnpm_parse_package_json_for_deps "$package_json")
}

_pnpm_get_packages_from_global_package_json() {
  local global_dir
  global_dir="$(pnpm store path)"
  local package_json
  package_json="$global_dir/../global/5/package.json"

  # Fallback to alternative global location
  if [[ ! -f "$package_json" ]]; then
    package_json="$(pnpm root -g)/package.json"
  fi

  # Return if we can't find package.json
  [[ ! -f "$package_json" ]] && return

  _values \
  "description" \
  $(_pnpm_parse_package_json_for_deps "$package_json")
}

_pnpm_get_packages_from_workspace_package_json() {
  local package_json

  package_json="$(_pnpm_recursively_look_for package.json $location)"

  # Return if we can't find package.json
  [[ "$package_json" = "" ]] && return

  _values $(_pnpm_parse_package_json_for_deps "$package_json")
}

_pnpm_completion_global_commands() {
  case $words[2] in
    add)
      _values $(_pnpm_get_cached_packages) \
    ;;
    remove|rm)
      _pnpm_get_packages_from_global_package_json
    ;;
    update|up|upgrade)
      _pnpm_get_packages_from_global_package_json
    ;;
  esac
}

_pnpm_get_cached_packages() {
  local search_term="${words[CURRENT]}"
  local packages=""
  
  # If user has typed something, search npm registry for matching packages
  if [[ -n "$search_term" && ${#search_term} -ge 2 ]]; then
    # Use npm search to find packages matching the search term
    packages=$(timeout 3 npm search "$search_term" --json 2>/dev/null | jq -r '.[].name' 2>/dev/null | head -20)
    
    # If npm search fails or returns nothing, try a broader search
    if [[ -z "$packages" ]]; then
      packages=$(timeout 3 npm search "${search_term}*" --json 2>/dev/null | jq -r '.[].name' 2>/dev/null | head -15)
    fi
  fi
  
  # If no search term or search failed, provide popular packages that match the prefix
  if [[ -z "$packages" ]]; then
    local popular_packages="react vue angular express lodash axios moment typescript eslint prettier webpack babel jest mocha chai next nuxt svelte solid react-dom react-router-dom @types/node @types/react vite nodemon cors dotenv uuid bcrypt jsonwebtoken"
    
    # Filter popular packages by search term if provided
    if [[ -n "$search_term" ]]; then
      packages=$(echo "$popular_packages" | tr ' ' '\n' | grep -i "^$search_term" | head -10)
    else
      packages="$popular_packages"
    fi
  fi
  
  # Try to get recently used packages from pnpm store if available
  local store_path
  store_path=$(pnpm store path 2>/dev/null)
  if [[ -n "$store_path" ]] && [[ -d "$store_path" ]]; then
    # Extract package names from store directory structure
    local recent_packages
    recent_packages=$(find "$store_path" -name "package.json" -exec jq -r '.name // empty' {} \; 2>/dev/null | sort -u | head -10)
    if [[ -n "$recent_packages" ]]; then
      # Filter recent packages by search term if provided
      if [[ -n "$search_term" ]]; then
        recent_packages=$(echo "$recent_packages" | grep -i "^$search_term")
      fi
      if [[ -n "$recent_packages" ]]; then
        packages="$packages $recent_packages"
      fi
    fi
  fi
  
  # Return unique sorted packages
  echo "$packages" | tr ' ' '\n' | sort -u | grep -v '^$' | head -30
}

_pnpm_get_workspaces() {
  local -a workspaces
  local pnpm_workspace_file
  
  # Look for pnpm-workspace.yaml file
  pnpm_workspace_file="$(_pnpm_recursively_look_for pnpm-workspace.yaml)"
  
  if [[ -n "$pnpm_workspace_file" ]]; then
    # Parse workspace packages from pnpm-workspace.yaml
    for workspace in $(grep -E "^\s*-\s+" "$pnpm_workspace_file" | sed 's/^\s*-\s*//' | tr -d '"'"'"''); do
      workspaces+=($workspace)
    done
    
    _describe -t workspace-names "workspace names" workspaces
  fi
}

_pnpm_workspace_commands() {
  local location workspace_name package_json

  workspace_name="$(echo $1 | sed 's/\(\/\)[^$]/\\&/g')"

  # For pnpm, we need to find the workspace location differently
  location="$workspace_name"

  case $words[3] in
    add)
      _values $(_pnpm_get_cached_packages) \
      && return
    ;;
    remove|rm)
      _pnpm_get_packages_from_workspace_package_json \
      && return
    ;;
    update|up|upgrade)
      _pnpm_get_packages_from_workspace_package_json \
      && return
    ;;
    run)
      [[ $CURRENT == 5 ]] && return
      _pnpm_get_scripts_from_workspace_package_json \
      && return
    ;;
    exec)
      [[ $CURRENT == 5 ]] && return
      _command_names \
      && return
    ;;
  esac

  _alternative \
    "global-commands:global:_pnpm_global_commands" \
    "common-workspace-commands:workspace:_pnpm_common_workspace_commands" \
    "package-scripts:scripts:_pnpm_get_scripts_from_workspace_package_json"\;
}

_pnpm_common_flags() {
  local -a list

  list=(
    -C:"working directory to use]:directory:_directories"
    --dir:"working directory to use]:directory:_directories"
    -w:"run as if pnpm was started in the root of the workspace"
    --workspace-root:"run as if pnpm was started in the root of the workspace"
    --filter:"filter packages]:package:_values"
    --reporter:"choose the reporter]:reporter:(default append-only ndjson silent)"
    --stream:"stream output from child processes immediately"
    --parallel:"run command in parallel on all workspaces"
    --recursive:"run command on every package in subdirectories"
    -r:"run command on every package in subdirectories"
    --if-present:"don't fail if script is missing"
    --resume-from:"resume execution from a particular project]:package:_values"
    --force:"force reinstall dependencies"
    --offline:"use only packages already available in the store"
    --prefer-offline:"prefer offline packages but fetch missing data"
    --prod:"install only production dependencies"
    -P:"install only production dependencies"
    --dev:"install only dev dependencies"
    -D:"install only dev dependencies"
    --no-optional:"don't install optional dependencies"
    --frozen-lockfile:"don't update lockfile"
    --lockfile-only:"only update lockfile"
    --no-lockfile:"don't read or generate lockfile"
    --shamefully-hoist:"create flat node_modules"
    --ignore-scripts:"don't execute scripts"
    --aggregate-output:"aggregate output from parallel processes"
    --json:"output in JSON format"
    --long:"show extended information"
    --parseable:"show parseable output"
    --global:"operate on global packages"
    -g:"operate on global packages"
    --depth:"max display depth]:number:"
    --silent:"no output"
    -s:"no output"
    --verbose:"verbose output"
    --help:"show help"
    -h:"show help"
    --version:"show version"
    -v:"show version"
  )

  _describe -t common-flags "common flags" list
}

_pnpm_global_commands() {
  local -a list

  list=(
    add:"installs a package and any packages that it depends on"
    remove:"remove installed packages"
    rm:"remove installed packages"
    update:"updates packages to their latest version"
    up:"updates packages to their latest version"
    upgrade:"updates packages to their latest version"
    list:"list installed packages"
    ls:"list installed packages"
    outdated:"checks for outdated package dependencies"
    why:"show information about why a package is installed"
  )

  _describe -t global-commands "global commands" list
}

_pnpm_common_workspace_commands() {
  local -a list

  list=(
    audit:"perform a vulnerability audit against installed packages"
    install:"install all dependencies for a project"
    i:"install all dependencies for a project"
    update:"updates packages to their latest version"
    up:"updates packages to their latest version"
    upgrade:"updates packages to their latest version"
    remove:"remove packages"
    rm:"remove packages"
    add:"installs a package and any packages that it depends on"
    link:"symlink a package folder during development"
    unlink:"unlink a previously created symlink for a package"
    run:"runs a defined package script"
    exec:"execute a shell command in scope of a project"
    dlx:"fetch a package from the registry and execute its default command"
    test:"run the test script"
    start:"run the start script"
    build:"run the build script"
    dev:"run the dev script"
    serve:"run the serve script"
    create:"create a new project from a template"
    init:"create a package.json file"
    publish:"publishes a package to the npm registry"
    pack:"creates a tarball from a package"
    rebuild:"rebuild a package"
    prune:"remove extraneous packages"
    import:"generates pnpm-lock.yaml from another package manager's lockfile"
    fetch:"fetch packages from lockfile into store"
    list:"list installed packages"
    ls:"list installed packages"
    outdated:"checks for outdated package dependencies"
    why:"show information about why a package is installed"
    licenses:"list licenses for installed packages"
    config:"manage the pnpm configuration files"
    store:"manage the pnpm store"
    patch:"prepare a package for patching"
    patch-commit:"generate a patch out of a directory"
    patch-remove:"remove a patch for a package"
    env:"manage Node.js environments"
    server:"manage background pnpm server"
  )

  _describe -t common-workspace-commands "common workspace commands" list
}

_pnpm_common_commands() {
  local -a list

  list=(
    add:"installs a package and any packages that it depends on"
    install:"install all dependencies for a project"
    i:"install all dependencies for a project"
    update:"updates packages to their latest version"
    up:"updates packages to their latest version"
    upgrade:"updates packages to their latest version"
    remove:"remove packages"
    rm:"remove packages"
    link:"symlink a package folder during development"
    unlink:"unlink a previously created symlink for a package"
    run:"runs a defined package script"
    exec:"execute a shell command in scope of a project"
    dlx:"fetch a package from the registry and execute its default command"
    test:"run the test script"
    start:"run the start script"
    build:"run the build script"
    dev:"run the dev script"
    serve:"run the serve script"
    create:"create a new project from a template"
    init:"create a package.json file"
    publish:"publishes a package to the npm registry"
    pack:"creates a tarball from a package"
    rebuild:"rebuild a package"
    prune:"remove extraneous packages"
    import:"generates pnpm-lock.yaml from another package manager's lockfile"
    fetch:"fetch packages from lockfile into store"
    list:"list installed packages"
    ls:"list installed packages"
    outdated:"checks for outdated package dependencies"
    why:"show information about why a package is installed"
    licenses:"list licenses for installed packages"
    audit:"perform a vulnerability audit against installed packages"
    config:"manage the pnpm configuration files"
    store:"manage the pnpm store"
    patch:"prepare a package for patching"
    patch-commit:"generate a patch out of a directory"
    patch-remove:"remove a patch for a package"
    env:"manage Node.js environments"
    server:"manage background pnpm server"
    setup:"setup pnpm"
    completions:"generate shell completions"
  )

  _describe -t common-commands "common commands" list
}

_pnpm_completion() {
  local curcontext="$curcontext" state state_descr line
  typeset -A opt_args val_args
  local -a orig_words
  local package_json="$(_pnpm_recursively_look_for package.json)"

  orig_words=( ${words[@]} )

  _arguments -C \
    "-C[working directory to use]:directory:_directories" \
    "--dir[working directory to use]:directory:_directories" \
    "-w[run as if pnpm was started in the root of the workspace]" \
    "--workspace-root[run as if pnpm was started in the root of the workspace]" \
    "--filter[filter packages]:package:" \
    "--reporter[choose the reporter]:reporter:(default append-only ndjson silent)" \
    "--stream[stream output from child processes immediately]" \
    "--parallel[run command in parallel on all workspaces]" \
    "--recursive[run command on every package in subdirectories]" \
    "-r[run command on every package in subdirectories]" \
    "--if-present[don't fail if script is missing]" \
    "--resume-from[resume execution from a particular project]:package:" \
    "--force[force reinstall dependencies]" \
    "--offline[use only packages already available in the store]" \
    "--prefer-offline[prefer offline packages but fetch missing data]" \
    "--prod[install only production dependencies]" \
    "-P[install only production dependencies]" \
    "--dev[install only dev dependencies]" \
    "-D[install only dev dependencies]" \
    "--no-optional[don't install optional dependencies]" \
    "--frozen-lockfile[don't update lockfile]" \
    "--lockfile-only[only update lockfile]" \
    "--no-lockfile[don't read or generate lockfile]" \
    "--shamefully-hoist[create flat node_modules]" \
    "--ignore-scripts[don't execute scripts]" \
    "--aggregate-output[aggregate output from parallel processes]" \
    "--json[output in JSON format]" \
    "--long[show extended information]" \
    "--parseable[show parseable output]" \
    "--global[operate on global packages]" \
    "-g[operate on global packages]" \
    "--depth[max display depth]:number:" \
    "--silent[no output]" \
    "-s[no output]" \
    "--verbose[verbose output]" \
    "--help[show help]" \
    "-h[show help]" \
    "--version[show version]" \
    "-v[show version]" \
                "(-): :->command" \
                "(-)*:: :->arg"

  case $state in
    command)
      _alternative \
        "global-commands:global:_pnpm_global_commands" \
        "common-commands:common:_pnpm_common_commands" \
        "package-scripts:scripts:_pnpm_get_scripts_from_package_json" \
    ;;
    arg)
      if [[ "${words[-1]:0:1}" == "-" ]]; then # options should complete as option is typed
        _pnpm_common_flags \
        && return
      fi

      case $words[1] in
        add)
          _values $(_pnpm_get_cached_packages) \
        ;;
        remove|rm)
          _pnpm_get_packages_from_package_json \
          && return
        ;;
        update|up|upgrade)
          _pnpm_get_packages_from_package_json \
          && return
        ;;
        run)
          [[ $CURRENT == 3 ]] && return
          _pnpm_get_scripts_from_package_json
        ;;
        exec)
          [[ $CURRENT == 3 ]] && return
          _command_names
        ;;
        dlx)
          [[ $CURRENT == 3 ]] && return
          _values $(_pnpm_get_cached_packages)
        ;;
        create)
          [[ $CURRENT == 3 ]] && return
          _values "create templates" \
            "react-app" \
            "next-app" \
            "vue" \
            "svelte" \
            "solid" \
            "lit-element" \
            "vite"
        ;;
        -g|--global)
          [[ $CURRENT > 2 ]] \
          && _pnpm_completion_global_commands \
          && return

          _alternative \
            "global-commands:global:_pnpm_global_commands" \
        ;;
        config)
          [[ $CURRENT == 3 ]] && return
          local -a list

          list=(
            set:"sets the config key to a certain value"
            get:"echoes the value for a given key to stdout"
            delete:"deletes a given key from the config"
            list:"displays the current configuration"
          )

          _describe -t config-commands "config commands" list
        ;;
        store)
          [[ $CURRENT == 3 ]] && return
          local -a list

          list=(
            status:"returns a 0 exit code if packages in the store are not modified"
            add:"adds new packages to the store"
            prune:"removes unreferenced packages from the store"
            path:"returns the path to the active store directory"
            list:"lists all packages in the store"
          )

          _describe -t store-commands "store commands" list
        ;;
        env)
          [[ $CURRENT == 3 ]] && return
          local -a list

          list=(
            use:"installs and uses the specified version of Node.js"
            remove:"removes the specified version of Node.js"
            list:"lists Node.js versions available locally"
            "list-remote":"lists Node.js versions available remotely"
          )

          _describe -t env-commands "env commands" list
        ;;
        patch)
          [[ $CURRENT == 3 ]] && return
          _pnpm_get_packages_from_package_json
        ;;
        patch-commit)
          [[ $CURRENT == 3 ]] && return
          _directories
        ;;
        patch-remove)
          [[ $CURRENT == 3 ]] && return
          _pnpm_get_packages_from_package_json
        ;;
        audit)
          [[ $CURRENT == 3 ]] && return
          local -a list

          list=(
            --audit-level:"the minimum level of vulnerability to report]:level:(low moderate high critical)"
            --json:"output audit report in JSON format"
            --dev:"audit dev dependencies"
            --prod:"audit production dependencies"
          )

          _describe -t audit-options "audit options" list
        ;;
        licenses)
          [[ $CURRENT == 3 ]] && return
          local -a list

          list=(
            list:"list licenses for installed packages"
          )

          _describe -t licenses-commands "licenses commands" list
        ;;
        why)
          [[ $CURRENT == 3 ]] && return
          _pnpm_get_packages_from_package_json
        ;;
      esac
    ;;
  esac

}

compdef _pnpm_completion pnpm

# Set up completion for aliases
compdef _pnpm_completion p
compdef _pnpm_completion pa
compdef _pnpm_completion pi
compdef _pnpm_completion pad
compdef _pnpm_completion pga
compdef _pnpm_completion pr
compdef _pnpm_completion prm
compdef _pnpm_completion pgr
compdef _pnpm_completion pu
compdef _pnpm_completion pup
compdef _pnpm_completion pug
compdef _pnpm_completion pl
compdef _pnpm_completion pul
compdef _pnpm_completion px
compdef _pnpm_completion pdx
compdef _pnpm_completion prun
compdef _pnpm_completion pt
compdef _pnpm_completion ps
compdef _pnpm_completion pb
compdef _pnpm_completion pd
compdef _pnpm_completion pout
compdef _pnpm_completion pwhy
compdef _pnpm_completion pls
compdef _pnpm_completion paudit
compdef _pnpm_completion pstore
compdef _pnpm_completion pconfig
compdef _pnpm_completion penv
compdef _pnpm_completion ppatch
compdef _pnpm_completion ppub
compdef _pnpm_completion pinit
compdef _pnpm_completion pcreate
compdef _pnpm_completion pprune
compdef _pnpm_completion prefresh
compdef _pnpm_completion pcheck
compdef _pnpm_completion pclean 