# Build with LuaLaTeX. luaotfload (used by LuaLaTeX) sees both TeX Live's
# Libertinus fonts (needed by acmart's math setup) and Fandol fonts
# (used here for Chinese characters in the author block). Plain pdflatex
# can't render Chinese; XeLaTeX's fontspec doesn't find LibertinusMath
# via fontconfig on this macOS setup.
$pdf_mode = 4;
