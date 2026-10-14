{
  lib,
  stdenvNoCC,
  makeWrapper,
  bash,
  coreutils,
  zellij,
  yazi,

  # Extra programs to make reachable from zide's panes -- another file picker
  # (lf), your editor, lazygit for the *_lazygit layouts, and so on.
  extraRuntimeInputs ? [ ],

  # Optional configuration, baked into the wrapper so it does not depend on the
  # caller's environment. Each maps to an env var zide already reads:
  #
  #   yaziConfigDir -> ZIDE_USE_YAZI_CONFIG   directory holding yazi.toml,
  #                                           keymap.toml and theme.toml for the
  #                                           picker pane
  #   layoutDir     -> ZIDE_LAYOUT_DIR        directory of .kdl layouts, used
  #                                           instead of the ones shipped here
  #   defaultLayout -> ZIDE_DEFAULT_LAYOUT    layout name to use with no argument
  #
  # Set these with .override rather than by editing this file, e.g.
  #   zide.override { defaultLayout = "compact"; }
  yaziConfigDir ? null,
  layoutDir ? null,
  defaultLayout ? null,
}:

let
  # PATH is extended with --suffix, not --prefix, on purpose. The failure this
  # guards against is a dependency being absent altogether: zide-edit's stderr
  # is swallowed by yazi's non-blocking opener, so a missing zellij makes it
  # silently do nothing at all. A suffix rules that out while still letting a
  # user's own zellij, yazi or editor take precedence.
  runtimePath = lib.makeBinPath ([ bash coreutils zellij yazi ] ++ extraRuntimeInputs);

  wrapperArgs = lib.concatStringsSep " " (
    [
      # --set, not --set-default: each wrapper must point at its own install,
      # even when invoked from a pane that inherited ZIDE_DIR from another one.
      # bin/zide honours a preset value rather than always resolving it from $0.
      ''--set ZIDE_DIR "$out"''
      ''--suffix PATH : "${runtimePath}"''
    ]
    ++ lib.optional (yaziConfigDir != null) ''--set ZIDE_USE_YAZI_CONFIG "${yaziConfigDir}"''
    ++ lib.optional (layoutDir != null) ''--set ZIDE_LAYOUT_DIR "${layoutDir}"''
    ++ lib.optional (defaultLayout != null) ''--set ZIDE_DEFAULT_LAYOUT "${defaultLayout}"''
  );
in

stdenvNoCC.mkDerivation {
  pname = "zide";
  version = "3.2.0";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [ makeWrapper ];

  # Nothing to build: bash scripts plus the data they read.
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r bin layouts yazi lf "$out/"

    install -Dm644 README.md "$out/share/doc/zide/README.md"
    install -Dm644 LICENSE "$out/share/doc/zide/LICENSE"

    # Wrap by moving the real scripts to libexec/ under the same names, rather
    # than with wrapProgram, which would rename them to .<name>-wrapped in
    # place. Linux takes a process's comm from the basename of the file it
    # execs, so that rename is visible: `ps` shows ".zide-wrapped", and anything
    # keying off the process name stops recognising zide. (A taskbar mapping the
    # terminal's foreground process to an icon is a real example.) Keeping the
    # name means bin/zide and libexec/zide both give comm "zide".
    #
    # makeWrapper's --argv0 does not solve this, and neither would it fix the
    # name in --help: these are #! scripts, so the kernel discards the caller's
    # argv[0] and substitutes the script path.
    mkdir -p "$out/libexec"
    for script in "$out"/bin/zide*; do
      name="$(basename "$script")"
      mv "$script" "$out/libexec/$name"
      makeWrapper "$out/libexec/$name" "$out/bin/$name" ${wrapperArgs}
    done

    runHook postInstall
  '';

  meta = {
    description = "Zellij, a file picker and your $EDITOR arranged as an IDE layout";
    homepage = "https://github.com/guttermonk/zide";
    license = lib.licenses.mit;
    mainProgram = "zide";
    platforms = lib.platforms.unix;
  };
}
