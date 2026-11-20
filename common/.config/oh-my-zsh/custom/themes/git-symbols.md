- symbol bracket open - `｢` (U+FF62) - yellow `ffeb3b` `$fg[yellow]` -> whenever the module is non-empty

- dirty marker - `` (U+E4D0) - orange `ff9800` `%F{9}` -> `git status --porcelain` is non-empty; dirty submodules excluded

- untracked - `` (U+F11D) - cyan `00bcd4` `$fg[cyan]` -> a file git does not track yet (`?? `)

- added - `` (U+F196) - green `4caf50` `$fg[green]` -> a new file is staged (`A  `)

- modified - `` (U+F0AD) - violet `d7afff` `%F{183}` -> a tracked file changed (`M  `, `MM `, ` M `, `AM `, ` T `)

- renamed - `` (U+F101) - blue `2196f3` `$fg[blue]` -> a staged rename (`R  `)

- deleted - `` (U+F1F8) - red `ff4081` `$fg[red]` -> a file was removed (` D `, `D  `)

- stashed - `` (U+F187) - magenta `9c27b0` `$fg[magenta]` -> `refs/stash` exists, independent of the working tree

- unmerged - `` (U+F12A) - red `ff4081` `$fg[red]` -> both sides changed one file, conflict to resolve (`UU `)

- ahead - `` (U+F062) - mint `00e676` `%F{10}` -> local commits the upstream does not have

- behind - `` (U+F063) - deep orange `ff5722` `%F{8}` -> upstream commits you do not have

- diverged - `` (U+F0EC) - deep orange `ff5722` `%F{8}` -> never: git reports ahead and behind separately, so both arrows show instead. Kept set because the upstream function reads it

- symbol bracket close - `｣` (U+FF63) - yellow `ffeb3b` `$fg[yellow]` -> whenever the module is non-empty




    clean repo, no venv      ｢main｣
    clean repo, venv         ｢main｣ ｢ myenv ｣
    dirty repo, no venv      ｢main｣ ｢       ｣
    dirty repo, venv         ｢main｣ ｢       ｣ ｢ myenv ｣
    outside a repo           nothing, venv module still shows if one is active
