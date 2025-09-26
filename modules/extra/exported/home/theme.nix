{ inputs, pkgs, ... }:
let
  noctaliaColors = {
    mError = "#dddddd";
    mOnError = "#111111";
    mOnPrimary = "#111111";
    mOnSecondary = "#111111";
    mOnSurface = "#828282";
    mOnSurfaceVariant = "#5d5d5d";
    mOnTertiary = "#111111";
    mOutline = "#3c3c3c";
    mPrimary = "#aaaaaa";
    mSecondary = "#a7a7a7";
    mShadow = "#000000";
    mSurface = "#111111";
    mSurfaceVariant = "#191919";
    mTertiary = "#cccccc";
  };
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
    colors = noctaliaColors;
  };
}
