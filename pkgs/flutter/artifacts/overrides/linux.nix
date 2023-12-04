{ gtk3,
  glib,
  fontconfig
}:

{ buildInputs ? [ ]
, ...
}:

{
  buildInputs = buildInputs ++ [ gtk3 glib fontconfig ];
}
