push @extra_pdflatex_options, '-synctex=1' ;
$pdf_mode = 4;
$pdf_previewer = "zathura";
$out_dir = 'build';
add_cus_dep('glo', 'gls', 0, 'makeglossaries');
add_cus_dep('acn',' acr', 0, 'makeglossaries');
sub makeglossaries{
  $dir = dirname($_[0]);
  $file = basename($_[0]);
  system( "makeglossaries -d '$dir' '$file'");
}
add_cus_dep('idx', 'ind', 0, 'texindy');
sub texindy{
  system("texindy $_[0].idx");
}
push @generated_exts, 'glo', 'gls', 'glg';
push @generated_exts, 'acn', 'acr', 'alg';
$clean_ext .= ' %R.ist %R.xdy';
